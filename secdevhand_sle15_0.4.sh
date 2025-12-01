#!/bin/bash

#--------------------------------------------------------------------------------------------------------
# file secdevhand.sh
# Script Name: secdevhand
# Description: Security deviation and system configuration handler for checking, fixing, and restoring
#              system deviations (idempotent, fully logged).
# Author: OK 
# Date: 2025-11-12
# Version 0.4
# Usage: ./secdevhand -m <mode> -i <id_list> [-r <backup_file_time_stamp>]"
#  -m <mode>      scan | fix | restore"
#  -i <id_list>   comma-separated deviation IDs, e.g., 7343,7344"
#  -r <backup_file_time_stamp>  required only for restore"
# 
# Example <backup_file_time_stamp>: 2025-11-25_21-36-59 
# /var/secdevhand
# -rw-r--r-- 1 root root 123 Nov 25 21:36 11327_gdm_package_2025-11-25_21-36-59.bck
# Timestamp is global it's created for whole list <-i> and can be used for whole <-i> list during restore.
# Global log file is in $GLOBLOGFILE
# Backup files are created in $ENVDIR
#---------------------------------------------------------------------------------------------------------

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
        echo "ERROR: Cannot write backup file: $BCKLOGFILE" >> "$GLOBLOGFILE"
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
        echo "$(date '+%F %T') - ERROR: $dir does not exist" 
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
        echo "ERROR: Backup file not found: $backup_file" 
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
        echo "ERROR: Invalid backup file format: $backup_file" 
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" >> "$GLOBLOGFILE"
        echo "ERROR: Failed to apply permissions '$perms' to $dir" 
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
        echo "ERROR: Cannot write backup file: $BCKLOGFILE" >> "$GLOBLOGFILE"
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
        echo "$(date '+%F %T') - ERROR: $dir does not exist"
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
        echo "ERROR: Backup file not found: $backup_file"
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
        echo "ERROR: Invalid backup file format: $backup_file"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" >> "$GLOBLOGFILE"
        echo "ERROR: Failed to apply permissions '$perms' to $dir"
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
        echo "ERROR: Cannot write backup file: $BCKLOGFILE"  >> "$GLOBLOGFILE"
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
        echo "$(date '+%F %T') - ERROR: $dir does not exist"
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
        echo "ERROR: Backup file not found: $backup_file"
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
        echo "ERROR: Invalid backup file format: $backup_file"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" >> "$GLOBLOGFILE"
        echo "ERROR: Failed to apply permissions '$perms' to $dir"
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
        echo "ERROR: Cannot write backup file: $BCKLOGFILE" >> "$GLOBLOGFILE"
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
        echo "$(date '+%F %T') - ERROR: $dir does not exist"
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
        echo "ERROR: Backup file not found: $backup_file"
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
        echo "ERROR: Invalid backup file format: $backup_file"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" >> "$GLOBLOGFILE"
        echo "ERROR: Failed to apply permissions '$perms' to $dir"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)" >> "$GLOBLOGFILE"
}


#----------------------------------------------------------------------------------------------
# Control ID: 7339 
# Description: Check, fix, remediate, and restore /etc/cron.d directory
#----------------------------------------------------------------------------------------------


# Function: check /etc/cron.d
7339_scan_cron_d() {
    local dir="/etc/cron.d"
    touch "$ENVDIR/7339_cron.d_$DATE.bck"
    local BCKLOGFILE="$ENVDIR/7339_cron.d_$DATE.bck"
    if ! touch "$BCKLOGFILE" 2>/dev/null; then
        echo "ERROR: Cannot write backup file: $BCKLOGFILE" >> "$GLOBLOGFILE"
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
7339_fix_cron_d() {
    local dir="/etc/cron.d"

    # Ensure directory exists
    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist" >> "$GLOBLOGFILE"
        echo "$(date '+%F %T') - ERROR: $dir does not exist"
        return 1
    fi

    # Backup current state
    7339_scan_cron_d

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)" >> "$GLOBLOGFILE"
}

# Function: restore /etc/cron.d from backup
7339_restore_cron_d() {
    local dir="/etc/cron.d"
    local backup_file="$ENVDIR/7339_cron.d_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" >> "$GLOBLOGFILE"
        echo "ERROR: Backup file not found: $backup_file"
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
        echo "ERROR: Invalid backup file format: $backup_file"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" >> "$GLOBLOGFILE"
        echo "ERROR: Failed to apply permissions '$perms' to $dir"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)" >> "$GLOBLOGFILE"
}


#----------------------------------------------------------------------------------------------
# Control ID: 7356 
# Description: Check, fix, remediate, and restore /etc/at.deny directory
#----------------------------------------------------------------------------------------------


# Function: check /etc/at.deny
7356_scan_at_deny() {
    local dir="/etc/at.deny"
    touch "$ENVDIR/7356_at.deny_$DATE.bck"
    local BCKLOGFILE="$ENVDIR/7356_at.deny_$DATE.bck"
    if ! touch "$BCKLOGFILE" 2>/dev/null; then
        echo "ERROR: Cannot write backup file: $BCKLOGFILE" >> "$GLOBLOGFILE"
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

# Function: fix /etc/at.deny ownership and permissions
7356_fix_at_deny() {
    local dir="/etc/at.deny"

    # Ensure directory exists
    if [ ! -f "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist" >> "$GLOBLOGFILE"
        echo "$(date '+%F %T') - ERROR: $dir does not exist"
        return 1
    fi

    # Backup current state
    7356_scan_at_deny

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 600 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)" >> "$GLOBLOGFILE"
}

# Function: restore /etc/at.deny from backup
7356_restore_at_deny() {
    local dir="/etc/at.deny"
    local backup_file="$ENVDIR/7356_at.deny_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" >> "$GLOBLOGFILE"
        echo "ERROR: Backup file not found: $backup_file"
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
        echo "ERROR: Invalid backup file format: $backup_file"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" >> "$GLOBLOGFILE"
        echo "ERROR: Failed to apply permissions '$perms' to $dir"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)" >> "$GLOBLOGFILE"
}


#----------------------------------------------------------------------------------------------
# Control ID: 9978
# Description: Check, fix, remediate, and restore CUPS service (systemd)
#----------------------------------------------------------------------------------------------

9978_scan_cups_service() {
    local service="cups.service"
    local BCKLOGFILE="$ENVDIR/9978_cups_$DATE.bck"

    if ! touch "$BCKLOGFILE" 2>/dev/null; then
        echo "ERROR: Cannot write backup file: $BCKLOGFILE" >> "$GLOBLOGFILE"
        echo "ERROR: Cannot write backup file: $BCKLOGFILE"
        return 1
    fi

    local enabled active
    enabled=$(systemctl is-enabled "$service" 2>/dev/null || echo "unknown")
    active=$(systemctl is-active "$service" 2>/dev/null || echo "unknown")

    echo "$(date '+%F %T') - Checking $service:" >> "$BCKLOGFILE"
    echo "    Enabled: $enabled" >> "$BCKLOGFILE"
    echo "    Active: $active" >> "$BCKLOGFILE"
    echo "----------------------------------------" >> "$BCKLOGFILE"
}


9978_fix_cups_service() {
    local service="cups.service"

    9978_scan_cups_service

    # If masked → unmask it first
    if systemctl is-enabled "$service" 2>/dev/null | grep -q "masked"; then
        if systemctl unmask "$service" &>/dev/null; then
            echo "$(date '+%F %T') - Unmasked $service" >> "$GLOBLOGFILE"
            echo "$(date '+%F %T') - Unmasked $service"
        else
            echo "$(date '+%F %T') - ERROR: Failed to unmask $service" >> "$GLOBLOGFILE"
            echo "$(date '+%F %T') - ERROR: Failed to unmask $service"
        fi
    fi

    # Disable service
    if systemctl disable "$service" &>/dev/null; then
        echo "$(date '+%F %T') - Disabled $service" >> "$GLOBLOGFILE"
        echo "$(date '+%F %T') - Disabled $service"

    else
        echo "$(date '+%F %T') - ERROR: Failed to disable $service" >> "$GLOBLOGFILE"
        echo "$(date '+%F %T') - ERROR: Failed to disable $service"
    fi

    # Stop service
    if systemctl stop "$service" &>/dev/null; then
        echo "$(date '+%F %T') - Stopped $service" >> "$GLOBLOGFILE"
        echo "$(date '+%F %T') - Stopped $service"
    else
        echo "$(date '+%F %T') - ERROR: Failed to stop $service" >> "$GLOBLOGFILE"
        echo "$(date '+%F %T') - ERROR: Failed to stop $service"
    fi
}


9978_restore_cups_service() {
    local service="cups.service"
    local backup_file="$ENVDIR/9978_cups_$RESTOREDATE.bck"

    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" >> "$GLOBLOGFILE"
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    local enabled active
    enabled=$(grep "Enabled" "$backup_file" | awk -F ':' '{print $2}' | xargs)
    active=$(grep "Active" "$backup_file" | awk -F ':' '{print $2}' | xargs)

    # Restore masked state
    if [[ "$enabled" == "masked" ]]; then
        systemctl stop "$service" &>/dev/null
        systemctl disable "$service" &>/dev/null
        systemctl mask "$service" &>/dev/null
        echo "$(date '+%F %T') - Restored $service (masked)" >> "$GLOBLOGFILE"
        return 0
    fi

    # Restore enabled/disabled
    if [[ "$enabled" == "enabled" ]]; then
        systemctl unmask "$service" &>/dev/null
        systemctl enable "$service" &>/dev/null
    elif [[ "$enabled" == "disabled" ]]; then
        systemctl unmask "$service" &>/dev/null
        systemctl disable "$service" &>/dev/null
    fi

    # Restore active state
    if [[ "$active" == "active" ]]; then
        systemctl start "$service" &>/dev/null
    elif [[ "$active" == "inactive" ]]; then
        systemctl stop "$service" &>/dev/null
    fi

    echo "$(date '+%F %T') - Restored $service state from backup $backup_file (Enabled: $enabled, Active: $active)" >> "$GLOBLOGFILE"
}

#----------------------------------------------------------------------------------------------
# Control ID: 13376
# Description: Check, fix, remediate, and restore /etc/profile.d/timeout.sh TMOUT
#----------------------------------------------------------------------------------------------

# Function: check /etc/profile.d/timeout.sh
13376_scan_profile_d_timeout_sh() {
    local file="/etc/profile.d/timeout.sh"
    local BCKLOGFILE="$ENVDIR/13376_profile.d_timeout.sh_$DATE.bck"

    if ! touch "$BCKLOGFILE" 2>/dev/null; then
        echo "ERROR: Cannot write backup file: $BCKLOGFILE"
        echo "ERROR: Cannot write backup file: $BCKLOGFILE" >> "$GLOBLOGFILE"
        return 1
    fi

    if [ ! -f "$file" ]; then
        echo "$(date '+%F %T') - ERROR: $file does not exist" >> "$GLOBLOGFILE"
        echo "$(date '+%F %T') - ERROR: $file does not exist" 
        return 1
    fi

    # Backup entire file
    cp "$file" "$BCKLOGFILE"
}

# Function: fix TMOUT
13376_fix_profile_d_timeout_sh() {
    local file="/etc/profile.d/timeout.sh"
    correct_tmout="readonly TMOUT=900"
    correct_export="export TMOUT"
    
    # Backup current state
    13376_scan_profile_d_timeout_sh

    # Read current file lines, strip leading/trailing spaces
    current_tmout=$(grep -E '^\s*readonly\s*TMOUT=' "$file" | awk '{$1=$1; print}')
    current_export=$(grep -E '^\s*export\s+TMOUT' "$file" | awk '{$1=$1; print}')

    if [ "$current_tmout" = "$correct_tmout" ] && [ "$current_export" = "$correct_export" ]; then
        # Already correct, do nothing
        echo "$(date '+%F %T') - $file already has correct TMOUT and export" >> "$GLOBLOGFILE"
    else
        # Remove any existing TMOUT lines or export
        sed -i '/TMOUT/d' "$file"

        # Add correct TMOUT and export
        {
            echo "$correct_tmout"
            echo "$correct_export"
        } >> "$file"

        echo "$(date '+%F %T') - Fixed $file: TMOUT set to 600 with readonly and export" >> "$GLOBLOGFILE"
    fi
}

# Function: restore TMOUT in /etc/profile.d/timeout.sh from backup
13376_restore_profile_d_timeout_sh() {
    local file="/etc/profile.d/timeout.sh"
    local backup_file="$ENVDIR/13376_profile.d_timeout.sh_$RESTOREDATE.bck"

    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" >> "$GLOBLOGFILE"
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    # Restore entire file from backup
    cp "$backup_file" "$file"
    if [ $? -eq 0 ]; then
        echo "$(date '+%F %T') - Restored $file from backup $backup_file" >> "$GLOBLOGFILE"
    else
        echo "$(date '+%F %T') - ERROR: Failed to restore $file from backup $backup_file" >> "$GLOBLOGFILE"
        echo "ERROR: Failed to restore $file from backup $backup_file"
        return 1
    fi
}

#----------------------------------------------------------------------------------------------
# Control ID: 11327 
# Description: Check, fix, remediate, and restore GDM packages
#----------------------------------------------------------------------------------------------

# Function: scan packages that would be removed with gdm
11327_scan_gdm_package() {
    local BCKLOGFILE="$ENVDIR/11327_gdm_package_$DATE.bck"

    # Create backup file
    if ! touch "$BCKLOGFILE" 2>/dev/null; then
        echo "ERROR: Cannot write backup file: $BCKLOGFILE" >> "$GLOBLOGFILE"
        echo "ERROR: Cannot write backup file: $BCKLOGFILE"
        return 1
    fi

    echo "$(date '+%F %T') - Scanning packages affected by gdm removal..." >> "$BCKLOGFILE"

    # Dry-run removal to determine affected packages
    local PACKAGES=$(zypper --non-interactive remove --dry-run gdm 2>&1 \
                     | awk '/The following .*packages are going to be REMOVED:/,/^[[:space:]]*$/{ \
                     if ($0 !~ /The following/ && $0 !~ /^[[:space:]]*$/) print}')
    if [[ -z "$PACKAGES" ]]; then
        echo "No packages would be removed with gdm." >> "$BCKLOGFILE"
        return 0
    fi

    echo "Packages to be removed:" >> "$BCKLOGFILE"
    echo "$PACKAGES" >> "$BCKLOGFILE"
}



# Function: fix (remove) gdm package and its dependencies
11327_fix_gdm_package() {
    # Run scan first
    11327_scan_gdm_package

    echo "$(date '+%F %T') - Removing gdm package and dependencies..." >> "$GLOBLOGFILE"

    if ! zypper --non-interactive remove gdm; then
        echo "ERROR: Failed to remove gdm package" >> "$GLOBLOGFILE"
        echo "ERROR: Failed to remove gdm package"
        return 1
    fi

    echo "$(date '+%F %T') - Successfully removed gdm package" >> "$GLOBLOGFILE"
}



# Function: restore previously removed gdm-related packages
11327_restore_gdm_package() {
    local backup_file="$ENVDIR/11327_gdm_package_$RESTOREDATE.bck"

    # Check backup file
    if [[ ! -f "$backup_file" ]]; then
        echo "ERROR: Backup file not found: $backup_file" >> "$GLOBLOGFILE"
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    # Load packages from backup
    local PACKAGES
    PACKAGES=$(grep -A100 "Packages to be removed:" "$backup_file" | tail -n +2)

    if [[ -z "$PACKAGES" ]]; then
        echo "ERROR: Backup file contains no package list: $backup_file" >> "$GLOBLOGFILE"
        echo "ERROR: Backup file contains no package list: $backup_file"
        return 1
    fi

    echo "$(date '+%F %T') - Restoring packages:" >> "$GLOBLOGFILE"
    echo "$PACKAGES" >> "$GLOBLOGFILE"

    if ! zypper --non-interactive install $PACKAGES; then
        echo "ERROR: Failed to restore packages from backup" >> "$GLOBLOGFILE"
        echo "ERROR: Failed to restore packages from backup"
        return 1
    fi

    echo "$(date '+%F %T') - Successfully restored packages from $backup_file" >> "$GLOBLOGFILE"
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
    [7339]="cron.d"
    [7356]="at.deny"
    [9978]="cups.service"
    [13376]="profile.d.timeout.sh"
    [11327]="gdm.package"
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

