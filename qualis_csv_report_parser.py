import os
import pandas as pd
import io

# --- Konfigurace cest ---
SOURCE_FOLDER = "Here_put_dir_with_source_csv_files"
VULN_FOLDER = "Here__put_voulnerability_list"

# Mapování: klíčové slovo v názvu souboru -> název souboru s vulnerabilitami
VULN_MAPPING = {
    "Scheduled-Report-SAP-AIX": "AIX_Vulnerabilities_list.xlsx",
    "Scheduled-Report-SAP-AWS": "SLES_Vulnerabilities_list.xlsx",
    "Scheduled-Report-SAP-SUSE": "SLES_Vulnerabilities_list.xlsx"
}

SELECTED_COLUMNS = [
    "Control ID", "Count", "Operating System", "Control",
    "Criticality Label", "Rationale", "Evidence", "Cause of Failure"
]


def parse_sections(file_path):
    """Rozdělí Qualys CSV na bloky textu podle názvů sekcí."""
    sections = {}
    known_sections = ["SUMMARY", "Host Statistics", "ASSET TAGS", "Control Statistics", "RESULTS"]
    current_name = "HEADER"
    current_lines = []

    # Čtení s ošetřením kódování a chyb v textu (errors='replace')
    with open(file_path, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            line_strip = line.strip()
            new_sec = next((s for s in known_sections if line_strip.startswith(s)), None)
            if new_sec:
                if current_lines: sections[current_name] = "".join(current_lines)
                current_name = new_sec
                current_lines = []
            else:
                current_lines.append(line)
        if current_lines: sections[current_name] = "".join(current_lines)
    return sections


# --- HLAVNÍ CYKLUS PRO ZPRACOVÁNÍ SLOŽKY ---

if not os.path.exists(SOURCE_FOLDER):
    print(f"❌ Složka {SOURCE_FOLDER} neexistuje.")
    exit()

csv_files = [f for f in os.listdir(SOURCE_FOLDER) if f.lower().endswith('.csv')]

if not csv_files:
    print(f"ℹ️ Ve složce {SOURCE_FOLDER} nebyly nalezeny žádné CSV soubory.")

for filename in csv_files:
    vuln_file_name = None
    for key, val in VULN_MAPPING.items():
        if key in filename:
            vuln_file_name = val
            break

    if not vuln_file_name:
        print(f"⚠️ Přeskakuji {filename}: Neodpovídá žádné kategorii v mapování.")
        continue

    vuln_path = os.path.join(VULN_FOLDER, vuln_file_name)
    input_path = os.path.join(SOURCE_FOLDER, filename)
    output_name = f"{os.path.splitext(filename)[0]}_kyndryl_report.xlsx"
    output_path = os.path.join(SOURCE_FOLDER, output_name)

    print(f"\n🚀 Zpracovávám: {filename}")
    print(f"   Používám Vulnerability list: {vuln_file_name}")

    try:
        df_vulnerabilities = pd.read_excel(vuln_path)
    except Exception as e:
        print(f"   ❌ Chyba při načítání {vuln_path}: {e}")
        continue

    raw_sections = parse_sections(input_path)

    with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
        for name, content in raw_sections.items():
            if not content.strip():
                continue

            try:
                # --- ROBUSTNÍ NAČÍTÁNÍ SEKCE ---
                # Přečteme řádky, abychom zjistili nejširší řádek (vyřeší AIX chybu "Expected X, saw Y")
                lines = content.strip().split('\n')
                # Zjistíme max počet sloupců (čárky mimo uvozovky jsou složité, proto engine='python' v read_csv)

                # Načteme s engine='python' a quotechar, což si poradí s čárkami v uvozovkách
                df = pd.read_csv(
                    io.StringIO(content),
                    skipinitialspace=True,
                    engine='python',
                    quotechar='"',
                    on_bad_lines=lambda x: x  # Tato funkce se pokusí řádek nerozbít, pokud je to možné
                )

                if not df.empty:
                    # Uložení základního listu
                    sheet_name = name[:30].replace("/", "_")
                    df.to_excel(writer, sheet_name=sheet_name, index=False)

                    # --- ANALÝZA RESULTS ---
                    if name == "RESULTS":
                        # Filtrace Failed (case insensitive pro jistotu)
                        df_failed = df[df['Status'].astype(str).str.contains('Failed', case=False, na=False)].copy()

                        if not df_failed.empty:
                            counts = df_failed['Control ID'].value_counts().reset_index()
                            counts.columns = ['Control ID', 'Count']

                            df_unique = df_failed.drop_duplicates(subset=['Control ID']).copy()
                            # Pokud tam už Count je, odstraníme ho před mergem
                            if 'Count' in df_unique.columns:
                                df_unique = df_unique.drop(columns=['Count'])

                            df_unique = df_unique.merge(counts, on='Control ID', how='left')

                            # Merge s externím listem
                            df_unique = df_unique.merge(
                                df_vulnerabilities[['Control ID', 'Impl. impact risk', 'Impl. Impact risk rationale']],
                                on='Control ID', how='left'
                            )

                            cols_to_use = [c for c in SELECTED_COLUMNS if c in df_unique.columns]
                            cols_to_use += [c for c in ['Impl. impact risk', 'Impl. Impact risk rationale'] if
                                            c in df_unique.columns]

                            df_failed.to_excel(writer, sheet_name="Failed_Records", index=False)
                            df_unique[cols_to_use].to_excel(writer, sheet_name="Uniq_Control_ID", index=False)
                            print(f"   ✅ Analýza RESULTS hotova.")

            except Exception as e:
                print(f"   ⚠️ Nepodařilo se zpracovat sekci '{name}': {e}")

    print(f"   💾 Uloženo: {output_name}")

print(f"\n✨ Hotovo! Všechny reporty byly zpracovány.")
