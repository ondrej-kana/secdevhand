#!/bin/bash

#----------------------------------------------------------------------------------------------
#file secdevhand.sh
# Script Name: secdevhand
# Description: Security and system configuration handler for checking, fixing, and restoring
#              system deviations (idempotent, fully logged).
# Author: OK 
# Date: 2025-11-12
# Version: 0.1
#----------------------------------------------------------------------------------------------




#Set enviroment and variable


DATE=$(date '+%F_%H-%M-%S')
GLOBLOGFILE="/var/log/secdevhand_sles15.log"
ENVDIR=/var/secdevhand

# Redirect all outputs (stdout + stderr) in log. 
exec > >(tee -a "$GLOBLOGFILE") 2>&1

if [ ! -d "$ENVDIR" ]; then
    mkdir -p $ENVDIR 
fi

echo #----------------------------------------------------------------------------------------------
echo # Control ID: 7343
echo # Description: Check, fix, remediate, and restore /etc/cron.hourly directory
echo #----------------------------------------------------------------------------------------------


# Function: check /etc/cron.hourly
7343_scan_cron_hourly() {
    touch "$ENVDIR/cron.hourly_$DATE.bck" 
    BCKLOGFILE="$ENVDIR/cron.hourly_$DATE.bck"
    local dir="/etc/cron.hourly"

    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - $dir does not exist!" >> "$GLOBLOGFILE"
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

    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - $dir does not exist! Cannot fix." >> "$GLOBLOGFILE"
        return 1
    fi

    # Backup current state
    local backup="/tmp/cron_hourly_backup_$(date +%F_%T).txt"
    stat -Lc 'Access: (%a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' "$dir" > "$backup"
    echo "$(date '+%F %T') - Backup of current permissions: $backup" >> "$GLOBLOGFILE"

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)" >> "$GLOBLOGFILE"
}

# Function: restore /etc/cron.hourly from backup
7343_restore_cron_hourly() {
    local dir="/etc/cron.hourly"
    local backup_file="$ENVDIR/cron.hourly_$RESTOREDATE.bck"

    if [ ! -f "$backup_file" ]; then
        echo "$(date '+%F %T') - Backup file $backup_file does not exist! Cannot restore." >> "$GLOBLOGFILE"
        return 1
    fi

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    #chown "$owner:$group" "$dir"
    chmod "$perms" "$dir"

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

#-----------------------
# Parse command-line parameters
#-----------------------
while getopts "m:i:r:" opt; do
    case $opt in
        m) MODE="$OPTARG" ;;
        i) IFS=',' read -r -a ID_LIST <<< "$OPTARG" ;;
        r) RESTOREDATE="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check mandatory parameters
if [ -z "$MODE" ] || { [ "$MODE" != "restore" ] && [ ${#ID_LIST[@]} -eq 0 ]; }; then
    usage
fi

if [ "$MODE" = "restore" ] && [ -z "$RESTOREDATE" ]; then
    usage
fi

#-----------------------
# Deviation mapping: ID -> name
#-----------------------
declare -A DEVIATIONS
DEVIATIONS=(
    [7343]="cron.hourly"
    [7344]="example_ssh_config"
    [10356]="example_sysctl"
)

#-----------------------
# Iterate over provided deviation IDs
#-----------------------
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

exit 0

