#!/bin/bash

#----------------------------------------------------------------------------------------------
#file secdevhand.sh
# Script Name: secdevhand
# Description: Security and system configuration handler for checking, fixing, and restoring
#              system deviations (idempotent, fully logged).
# Author: OK 
# Date: 2025-11-12
# Version: 0.2
#----------------------------------------------------------------------------------------------




#Set enviroment and variable


DATE=$(date '+%F_%H-%M-%S')
GLOBLOGFILE="/var/log/secdevhand_sles15.log"
touch $GLOBLOGFILE
ENVDIR=/var/secdevhand



# Ensure log file exists and is writable
if ! touch "$GLOBLOGFILE" 2>/dev/null; then
    echo "ERROR: Cannot write to $GLOBLOGFILE"
    exit 1
fi

# Redirect all outputs (stdout + stderr) in log. 
exec > >(tee -a "$GLOBLOGFILE") 2>&1

if [ ! -d "$ENVDIR" ]; then
    mkdir -p $ENVDIR 
fi

#----------------------------------------------------------------------------------------------
# Control ID: 7343
# Description: Check, fix, remediate, and restore /etc/cron.hourly directory
#----------------------------------------------------------------------------------------------


# Function: check /etc/cron.hourly
7343_scan_cron_hourly() {
    local dir="/etc/cron.hourly"
    touch "$ENVDIR/7343_cron.hourly_$DATE.bck" 
    local BCKLOGFILE="$ENVDIR/7343_cron.hourly_$DATE.bck"
    if ! touch "$BCKLOGFILE" 2>/dev/null; then
        echo "ERROR: Cannot write backup file: $BCKLOGFILE"
        return 1
    fi 

    local owner group perms
    owner=$(stat -c %U "$dir")
    group=$(stat -c %G "$dir")
    perms=$(stat -c %a "$dir")

    echo "$(date '+%F %T') - Checking $dir:" >> "$BCKLOGFILE"
    echo "    Owner: $owner" >> "$BCKLOGFILE"
    echo "    Group: $group" >> "$BCKLOGFILE"
    echo "    Permissions: $perms" >> "$BCKLOGFILE"
    echo "----------------------------------------" >> "$BCKLOGFILE"
}

# Function: fix /etc/cron.hourly ownership and permissions
7343_fix_cron_hourly() {
    local dir="/etc/cron.hourly"

    # Ensure directory exists
    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist" >> "$GLOBLOGFILE"
        return 1
    fi

    # Backup current state
    7343_scan_cron_hourly 

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)" >> "$GLOBLOGFILE"
}

# Function: restore /etc/cron.hourly from backup
7343_restore_cron_hourly() {
    local dir="/etc/cron.hourly"
    local backup_file="$ENVDIR/7343_cron.hourly_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" >> "$GLOBLOGFILE"
        return 1
    fi

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    # Validate values
    if [[ -z "$owner" || -z "$group" || -z "$perms" ]]; then
        echo "ERROR: Invalid backup file format: $backup_file" >> "$GLOBLOGFILE"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" >> "$GLOBLOGFILE"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)" >> "$GLOBLOGFILE"
}






#----------------------------------------------------------------------------------------------
# Control ID: 7341 
# Description: Check, fix, remediate, and restore /etc/cron.daily directory
#----------------------------------------------------------------------------------------------


# Function: check /etc/cron.daily
7341_scan_cron_daily() {
    local dir="/etc/cron.daily"
    touch "$ENVDIR/7341_cron.daily_$DATE.bck"
    local BCKLOGFILE="$ENVDIR/7341_cron.daily_$DATE.bck"
    if ! touch "$BCKLOGFILE" 2>/dev/null; then
        echo "ERROR: Cannot write backup file: $BCKLOGFILE"
        return 1
    fi

    local owner group perms
    owner=$(stat -c %U "$dir")
    group=$(stat -c %G "$dir")
    perms=$(stat -c %a "$dir")

    echo "$(date '+%F %T') - Checking $dir:" >> "$BCKLOGFILE"
    echo "    Owner: $owner" >> "$BCKLOGFILE"
    echo "    Group: $group" >> "$BCKLOGFILE"
    echo "    Permissions: $perms" >> "$BCKLOGFILE"
    echo "----------------------------------------" >> "$BCKLOGFILE"
}

# Function: fix /etc/cron.daily ownership and permissions
7341_fix_cron_daily() {
    local dir="/etc/cron.daily"

    # Ensure directory exists
    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist" >> "$GLOBLOGFILE"
        return 1
    fi

    # Backup current state
    7341_scan_cron_daily

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)" >> "$GLOBLOGFILE"
}

# Function: restore /etc/cron.daily from backup
7341_restore_cron_daily() {
    local dir="/etc/cron.daily"
    local backup_file="$ENVDIR/7341_cron.daily_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" >> "$GLOBLOGFILE"
        return 1
    fi

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    # Validate values
    if [[ -z "$owner" || -z "$group" || -z "$perms" ]]; then
        echo "ERROR: Invalid backup file format: $backup_file" >> "$GLOBLOGFILE"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" >> "$GLOBLOGFILE"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)" >> "$GLOBLOGFILE"
}


#----------------------------------------------------------------------------------------------
# Control ID: 7345 
# Description: Check, fix, remediate, and restore /etc/cron.weekly directory
#----------------------------------------------------------------------------------------------


# Function: check /etc/cron.weekly
7345_scan_cron_weekly() {
    local dir="/etc/cron.weekly"
    touch "$ENVDIR/7345_cron.weekly_$DATE.bck"
    local BCKLOGFILE="$ENVDIR/7345_cron.weekly_$DATE.bck"
    if ! touch "$BCKLOGFILE" 2>/dev/null; then
        echo "ERROR: Cannot write backup file: $BCKLOGFILE"
        return 1
    fi

    local owner group perms
    owner=$(stat -c %U "$dir")
    group=$(stat -c %G "$dir")
    perms=$(stat -c %a "$dir")

    echo "$(date '+%F %T') - Checking $dir:" >> "$BCKLOGFILE"
    echo "    Owner: $owner" >> "$BCKLOGFILE"
    echo "    Group: $group" >> "$BCKLOGFILE"
    echo "    Permissions: $perms" >> "$BCKLOGFILE"
    echo "----------------------------------------" >> "$BCKLOGFILE"
}

# Function: fix /etc/cron.weekly ownership and permissions
7345_fix_cron_weekly() {
    local dir="/etc/cron.weekly"

    # Ensure directory exists
    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist" >> "$GLOBLOGFILE"
        return 1
    fi

    # Backup current state
    7345_scan_cron_weekly

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)" >> "$GLOBLOGFILE"
}

# Function: restore /etc/cron.weekly from backup
7345_restore_cron_weekly() {
    local dir="/etc/cron.weekly"
    local backup_file="$ENVDIR/7345_cron.weekly_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" >> "$GLOBLOGFILE"
        return 1
    fi

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    # Validate values
    if [[ -z "$owner" || -z "$group" || -z "$perms" ]]; then
        echo "ERROR: Invalid backup file format: $backup_file" >> "$GLOBLOGFILE"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" >> "$GLOBLOGFILE"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)" >> "$GLOBLOGFILE"
}

#----------------------------------------------------------------------------------------------
# Control ID: 7347 
# Description: Check, fix, remediate, and restore /etc/cron.monthly directory
#----------------------------------------------------------------------------------------------


# Function: check /etc/cron.monthly
7347_scan_cron_monthly() {
    local dir="/etc/cron.monthly"
    touch "$ENVDIR/7347_cron.monthly_$DATE.bck"
    local BCKLOGFILE="$ENVDIR/7347_cron.monthly_$DATE.bck"
    if ! touch "$BCKLOGFILE" 2>/dev/null; then
        echo "ERROR: Cannot write backup file: $BCKLOGFILE"
        return 1
    fi

    local owner group perms
    owner=$(stat -c %U "$dir")
    group=$(stat -c %G "$dir")
    perms=$(stat -c %a "$dir")

    echo "$(date '+%F %T') - Checking $dir:" >> "$BCKLOGFILE"
    echo "    Owner: $owner" >> "$BCKLOGFILE"
    echo "    Group: $group" >> "$BCKLOGFILE"
    echo "    Permissions: $perms" >> "$BCKLOGFILE"
    echo "----------------------------------------" >> "$BCKLOGFILE"
}

# Function: fix /etc/cron.monthly ownership and permissions
7347_fix_cron_monthly() {
    local dir="/etc/cron.monthly"

    # Ensure directory exists
    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist" >> "$GLOBLOGFILE"
        return 1
    fi

    # Backup current state
    7347_scan_cron_monthly

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)" >> "$GLOBLOGFILE"
}

# Function: restore /etc/cron.monthly from backup
7347_restore_cron_monthly() {
    local dir="/etc/cron.monthly"
    local backup_file="$ENVDIR/7347_cron.monthly_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" >> "$GLOBLOGFILE"
        return 1
    fi

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    # Validate values
    if [[ -z "$owner" || -z "$group" || -z "$perms" ]]; then
        echo "ERROR: Invalid backup file format: $backup_file" >> "$GLOBLOGFILE"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" >> "$GLOBLOGFILE"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)" >> "$GLOBLOGFILE"
}


#----------------------------------------------------------------------------------------------
# Control ID: 7349 
# Description: Check, fix, remediate, and restore /etc/cron.d directory
#----------------------------------------------------------------------------------------------


# Function: check /etc/cron.d
7349_scan_cron_d() {
    local dir="/etc/cron.d"
    touch "$ENVDIR/7349_cron.d_$DATE.bck"
    local BCKLOGFILE="$ENVDIR/7349_cron.d_$DATE.bck"
    if ! touch "$BCKLOGFILE" 2>/dev/null; then
        echo "ERROR: Cannot write backup file: $BCKLOGFILE"
        return 1
    fi

    local owner group perms
    owner=$(stat -c %U "$dir")
    group=$(stat -c %G "$dir")
    perms=$(stat -c %a "$dir")

    echo "$(date '+%F %T') - Checking $dir:" >> "$BCKLOGFILE"
    echo "    Owner: $owner" >> "$BCKLOGFILE"
    echo "    Group: $group" >> "$BCKLOGFILE"
    echo "    Permissions: $perms" >> "$BCKLOGFILE"
    echo "----------------------------------------" >> "$BCKLOGFILE"
}

# Function: fix /etc/cron.d ownership and permissions
7349_fix_cron_d() {
    local dir="/etc/cron.d"

    # Ensure directory exists
    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist" >> "$GLOBLOGFILE"
        return 1
    fi

    # Backup current state
    7349_scan_cron_d

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)" >> "$GLOBLOGFILE"
}

# Function: restore /etc/cron.d from backup
7349_restore_cron_d() {
    local dir="/etc/cron.d"
    local backup_file="$ENVDIR/7349_cron.d_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" >> "$GLOBLOGFILE"
        return 1
    fi

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    # Validate values
    if [[ -z "$owner" || -z "$group" || -z "$perms" ]]; then
        echo "ERROR: Invalid backup file format: $backup_file" >> "$GLOBLOGFILE"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" >> "$GLOBLOGFILE"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)" >> "$GLOBLOGFILE"
}


####################################################
# MAIN                        
####################################################

# Default values
MODE=""
ID_LIST=()
RESTOREDATE=""

usage() {
    echo "Usage: $0 -m <mode> -i <id_list> [-r <backup_file>]"
    echo "  -m <mode>      scan | fix | restore"
    echo "  -i <id_list>   comma-separated deviation IDs, e.g., 7343,7344"
    echo "  -r <backup_file>  required only for restore"
    exit 1
}

log() {
    echo "$(date '+%F %T') - $*"
}

#------------------------------
# Parse command-line parameters
#------------------------------
while getopts "m:i:r:" opt; do
    case $opt in
        m) MODE="$OPTARG" ;;
        i) IFS=',' read -r -a ID_LIST <<< "$OPTARG" ;;
        r) RESTOREDATE="$OPTARG" ;;
        *) usage ;;
    esac
done

#-------------------------------
# Check mandatory parameters
#-------------------------------
if [ -z "$MODE" ] || { [ "$MODE" != "restore" ] && [ ${#ID_LIST[@]} -eq 0 ]; }; then
    usage
fi

if [ "$MODE" = "restore" ] && [ -z "$RESTOREDATE" ]; then
    usage
fi

#-------------------------------
# Deviation mapping: ID -> name
#------------------------------- 
declare -A DEVIATIONS
DEVIATIONS=(
    [7343]="cron.hourly"
    [7341]="cron.daily"
    [7345]="cron.weekly"
    [7347]="cron.monthly"
    [7349]="cron.d"
    [7344]="example_ssh_config"
    [10356]="example_sysctl"
)

#------------------------------------
# Iterate over provided deviation IDs
#------------------------------------
for id in "${ID_LIST[@]}"; do
    dev_name="${DEVIATIONS[$id]}"

    if [ -z "$dev_name" ]; then
        log "Unknown deviation ID: $id"
        continue
    fi

    # Build function name dynamically: <ID>_<mode>_<deviation_name>
    func_name="${id}_${MODE}_$(echo "$dev_name" | tr '.' '_')"

    if declare -f "$func_name" > /dev/null; then
        log "Executing $func_name for deviation $dev_name (ID $id)"
        "$func_name"
    else
        log "Function $func_name not found for ID $id, deviation $dev_name, MODE $MODE"
    fi
done

#--------------------------------
# Cleaning
#--------------------------------

#sed -i '/^$/d' "$GLOBLOGFILE"

exit 0

