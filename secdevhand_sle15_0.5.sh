#!/bin/bash

#--------------------------------------------------------------------------------------------------------
# file secdevhand.sh
# Script Name: secdevhand
# Description: Security deviation and system configuration handler for checking, fixing, and restoring
#              system deviations (idempotent, fully logged).
# Author: OK 
# Date: 2025-11-12
# Version 0.5
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
    # Ensure directory exists
    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist" 
        return 1
    fi
    
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

    # Backup current state
    7343_scan_cron_hourly 

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)"
}

# Function: restore /etc/cron.hourly from backup
7343_restore_cron_hourly() {
    local dir="/etc/cron.hourly"
    local backup_file="$ENVDIR/7343_cron.hourly_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" 
        return 1
    fi

    # Backup current state
    7343_scan_cron_hourly 

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    # Validate values
    if [[ -z "$owner" || -z "$group" || -z "$perms" ]]; then
        echo "ERROR: Invalid backup file format: $backup_file" 
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir" 
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)"
}






#----------------------------------------------------------------------------------------------
# Control ID: 7341 
# Description: Check, fix, remediate, and restore /etc/cron.daily directory
#----------------------------------------------------------------------------------------------


# Function: check /etc/cron.daily
7341_scan_cron_daily() {
    local dir="/etc/cron.daily"
    # Ensure directory exists
    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist"
        return 1
    fi
    
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

    # Backup current state
    7341_scan_cron_daily

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)"
}

# Function: restore /etc/cron.daily from backup
7341_restore_cron_daily() {
    local dir="/etc/cron.daily"
    local backup_file="$ENVDIR/7341_cron.daily_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    # Backup current state
    7341_scan_cron_daily

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    # Validate values
    if [[ -z "$owner" || -z "$group" || -z "$perms" ]]; then
        echo "ERROR: Invalid backup file format: $backup_file"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)"
}


#----------------------------------------------------------------------------------------------
# Control ID: 7345 
# Description: Check, fix, remediate, and restore /etc/cron.weekly directory
#----------------------------------------------------------------------------------------------


# Function: check /etc/cron.weekly
7345_scan_cron_weekly() {
    local dir="/etc/cron.weekly"
    # Ensure directory exists
    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist"
        return 1
    fi
    
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

    # Backup current state
    7345_scan_cron_weekly

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)"
}

# Function: restore /etc/cron.weekly from backup
7345_restore_cron_weekly() {
    local dir="/etc/cron.weekly"
    local backup_file="$ENVDIR/7345_cron.weekly_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    # Backup current state
    7345_scan_cron_weekly

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    # Validate values
    if [[ -z "$owner" || -z "$group" || -z "$perms" ]]; then
        echo "ERROR: Invalid backup file format: $backup_file"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)"
}

#----------------------------------------------------------------------------------------------
# Control ID: 7347 
# Description: Check, fix, remediate, and restore /etc/cron.monthly directory
#----------------------------------------------------------------------------------------------


# Function: check /etc/cron.monthly
7347_scan_cron_monthly() {
    local dir="/etc/cron.monthly"
    # Ensure directory exists
    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist"
        return 1
    fi
    
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

    # Backup current state
    7347_scan_cron_monthly

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)"
}

# Function: restore /etc/cron.monthly from backup
7347_restore_cron_monthly() {
    local dir="/etc/cron.monthly"
    local backup_file="$ENVDIR/7347_cron.monthly_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    # Backup current state
    7347_scan_cron_monthly

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    # Validate values
    if [[ -z "$owner" || -z "$group" || -z "$perms" ]]; then
        echo "ERROR: Invalid backup file format: $backup_file"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)"
}


#----------------------------------------------------------------------------------------------
# Control ID: 7339 
# Description: Check, fix, remediate, and restore /etc/cron.d directory
#----------------------------------------------------------------------------------------------


# Function: check /etc/cron.d
7339_scan_cron_d() {
    local dir="/etc/cron.d"
    # Ensure directory exists
    if [ ! -d "$dir" ]; then
        echo "$(date '+%F %T') - ERROR: $dir does not exist"
        return 1
    fi
    
    touch "$ENVDIR/7339_cron.d_$DATE.bck"
    local BCKLOGFILE="$ENVDIR/7339_cron.d_$DATE.bck"
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
7339_fix_cron_d() {
    local dir="/etc/cron.d"

    # Backup current state
    7339_scan_cron_d

    # Apply CIS recommended ownership and permissions
    #chown root:root "$dir"
    chmod 700 "$dir"

    echo "$(date '+%F %T') - Fixed $dir (owner:root, group:root, permissions:700)"
}

# Function: restore /etc/cron.d from backup
7339_restore_cron_d() {
    local dir="/etc/cron.d"
    local backup_file="$ENVDIR/7339_cron.d_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    # Backup current state
    7339_scan_cron_d

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    # Validate values
    if [[ -z "$owner" || -z "$group" || -z "$perms" ]]; then
        echo "ERROR: Invalid backup file format: $backup_file"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$dir"
    if ! chmod "$perms" "$dir"; then
        echo "ERROR: Failed to apply permissions '$perms' to $dir"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $dir from backup $backup_file (owner:$owner, group:$group, permissions:$perms)"
}


#----------------------------------------------------------------------------------------------
# Control ID: 7356 
# Description: Check, fix, remediate, and restore /etc/at.deny file 
#----------------------------------------------------------------------------------------------


# Function: check /etc/at.deny
7356_scan_at_deny() {
    local file="/etc/at.deny"
    # Ensure file exists
    if [ ! -f "$file" ]; then
        echo "$(date '+%F %T') - ERROR: $file does not exist"
        return 1
    fi
    
    touch "$ENVDIR/7356_at.deny_$DATE.bck"
    local BCKLOGFILE="$ENVDIR/7356_at.deny_$DATE.bck"
    if ! touch "$BCKLOGFILE" 2>/dev/null; then
        echo "ERROR: Cannot write backup file: $BCKLOGFILE"
        return 1
    fi

    local owner group perms
    owner=$(stat -c %U "$file")
    group=$(stat -c %G "$file")
    perms=$(stat -c %a "$file")

    echo "$(date '+%F %T') - Checking $file:" >> "$BCKLOGFILE"
    echo "    Owner: $owner" >> "$BCKLOGFILE"
    echo "    Group: $group" >> "$BCKLOGFILE"
    echo "    Permissions: $perms" >> "$BCKLOGFILE"
    echo "----------------------------------------" >> "$BCKLOGFILE"
}

# Function: fix /etc/at.deny ownership and permissions
7356_fix_at_deny() {
    local file="/etc/at.deny"

    # Backup current state
    7356_scan_at_deny

    # Apply CIS recommended ownership and permissions
    #chown root:root "$file"
    chmod 600 "$file"

    echo "$(date '+%F %T') - Fixed $file (owner:root, group:root, permissions:700)"
}

# Function: restore /etc/at.deny from backup
7356_restore_at_deny() {
    local file="/etc/at.deny"
    local backup_file="$ENVDIR/7356_at.deny_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    # Backup current state
    7356_scan_at_deny

    # Restore ownership and permissions from backup
    local perms owner group
    owner=$(grep "Owner" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    group=$(grep "Group" "$backup_file" | awk -F ':' '{print $2}'|xargs)
    perms=$(grep "Permissions" "$backup_file" | awk -F ':' '{print $2}'|xargs)

    # Validate values
    if [[ -z "$owner" || -z "$group" || -z "$perms" ]]; then
        echo "ERROR: Invalid backup file format: $backup_file"
        return 1
    fi

    # Apply restored values
    #chown "$owner:$group" "$file"
    if ! chmod "$perms" "$file"; then
        echo "ERROR: Failed to apply permissions '$perms' to $file"
        return 1
    fi

    echo "$(date '+%F %T') - Restored $file from backup $backup_file (owner:$owner, group:$group, permissions:$perms)"
}


#----------------------------------------------------------------------------------------------
# Control ID: 9978
# Description: Check, fix, remediate, and restore CUPS service (systemd)
#----------------------------------------------------------------------------------------------

9978_scan_cups_service() {
    local service="cups.service"
    local BCKLOGFILE="$ENVDIR/9978_cups_$DATE.bck"

    if ! touch "$BCKLOGFILE" 2>/dev/null; then
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

    # Backup current state
    9978_scan_cups_service

    # If masked → unmask it first
    if systemctl is-enabled "$service" 2>/dev/null | grep -q "masked"; then
        if systemctl unmask "$service" &>/dev/null; then
            echo "$(date '+%F %T') - Unmasked $service"
        else
            echo "$(date '+%F %T') - ERROR: Failed to unmask $service"
        fi
    fi

    # Disable service
    if systemctl disable "$service" &>/dev/null; then
        echo "$(date '+%F %T') - Disabled $service"

    else
        echo "$(date '+%F %T') - ERROR: Failed to disable $service"
    fi

    # Stop service
    if systemctl stop "$service" &>/dev/null; then
        echo "$(date '+%F %T') - Stopped $service"
    else
        echo "$(date '+%F %T') - ERROR: Failed to stop $service"
    fi
}


9978_restore_cups_service() {
    local service="cups.service"
    local backup_file="$ENVDIR/9978_cups_$RESTOREDATE.bck"

    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    # Backup current state
    9978_scan_cups_service

    local enabled active
    enabled=$(grep "Enabled" "$backup_file" | awk -F ':' '{print $2}' | xargs)
    active=$(grep "Active" "$backup_file" | awk -F ':' '{print $2}' | xargs)

    # Restore masked state
    if [[ "$enabled" == "masked" ]]; then
        systemctl stop "$service" &>/dev/null
        systemctl disable "$service" &>/dev/null
        systemctl mask "$service" &>/dev/null
        echo "$(date '+%F %T') - Restored $service (masked)"
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

    echo "$(date '+%F %T') - Restored $service state from backup $backup_file (Enabled: $enabled, Active: $active)"
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
        return 1
    fi

    if [ ! -f "$file" ]; then
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
        echo "$(date '+%F %T') - $file already has correct TMOUT and export"
    else
        # Remove any existing TMOUT lines or export
        sed -i '/TMOUT/d' "$file"

        # Add correct TMOUT and export
        {
            echo "$correct_tmout"
            echo "$correct_export"
        } >> "$file"

        echo "$(date '+%F %T') - Fixed $file: TMOUT set to 600 with readonly and export"
    fi
}

# Function: restore TMOUT in /etc/profile.d/timeout.sh from backup
13376_restore_profile_d_timeout_sh() {
    local file="/etc/profile.d/timeout.sh"
    local backup_file="$ENVDIR/13376_profile.d_timeout.sh_$RESTOREDATE.bck"

    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    # Backup current state
    13376_scan_profile_d_timeout_sh

    # Restore entire file from backup
    cp "$backup_file" "$file"
    if [ $? -eq 0 ]; then
        echo "$(date '+%F %T') - Restored $file from backup $backup_file"
    else
        echo "$(date '+%F %T') - ERROR: Failed to restore $file from backup $backup_file"
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

    # Backup current state
    11327_scan_gdm_package

    echo "$(date '+%F %T') - Removing gdm package and dependencies..."

    if ! zypper --non-interactive remove gdm; then
        echo "ERROR: Failed to remove gdm package"
        return 1
    fi

    echo "$(date '+%F %T') - Successfully removed gdm package"
}



# Function: restore previously removed gdm-related packages
11327_restore_gdm_package() {
    local backup_file="$ENVDIR/11327_gdm_package_$RESTOREDATE.bck"

    # Check backup file
    if [[ ! -f "$backup_file" ]]; then
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    # Backup current state
    11327_scan_gdm_package

    # Load packages from backup
    local PACKAGES
    PACKAGES=$(grep -A100 "Packages to be removed:" "$backup_file" | tail -n +2)

    if [[ -z "$PACKAGES" ]]; then
        echo "ERROR: Backup file contains no package list: $backup_file"
        return 1
    fi

    echo "$(date '+%F %T') - Restoring packages:"
    echo "$PACKAGES" >> "$GLOBLOGFILE"

    if ! zypper --non-interactive install $PACKAGES; then
        echo "ERROR: Failed to restore packages from backup"
        return 1
    fi

    echo "$(date '+%F %T') - Successfully restored packages from $backup_file"
}


#----------------------------------------------------------------------------------------------
# Control ID: 7513 
# Description: Check, fix, remediate, and restore asymmetrical routing
#----------------------------------------------------------------------------------------------

# Function: check net.ipv4.conf.all.rp_filter
7513_scan_rp_filter() {
    local key="net.ipv4.conf.all.rp_filter"
    local config_file="/etc/sysctl.conf"
    local required_value="1"

    # 1. Check active kernel setting
    local current_kernel_value
    current_kernel_value=$(sysctl -n "$key" 2>/dev/null)

    # 2. Check configuration file setting (using grep to find the key, ignoring comments)
    local current_config_setting
    current_config_setting=$(grep -E "^$key\s*=\s*[0-9]" "$config_file" | awk -F '=' '{print $2}' | tr -d '[:space:]')

    # Create backup log/state file
    touch "$ENVDIR/7513_rp_filter_$DATE.bck" 2>/dev/null
    local BCKLOGFILE="$ENVDIR/7513_rp_filter_$DATE.bck"
    if [ ! -f "$BCKLOGFILE" ]; then
        echo "ERROR: Cannot create backup file: $BCKLOGFILE"
        return 1
    fi

    # Log current state
    if [ -f "$config_file" ]; then
        echo "$(date '+%F %T') --- START FILE BACKUP: $config_file ---" >> "$BCKLOGFILE"
        cat "$config_file" >> "$BCKLOGFILE"
        echo "$(date '+%F %T') --- END FILE BACKUP: $config_file ---" >> "$BCKLOGFILE"
        echo "" >> "$BCKLOGFILE"
    else
        echo "$(date '+%F %T') - WARNING: Configuration file $config_file not found. Cannot backup full content." >> "$BCKLOGFILE"
        echo "" >> "$BCKLOGFILE"
    fi

    echo "$(date '+%F %T') - Checking $key:" >> "$BCKLOGFILE"
    echo "    Kernel Value: $current_kernel_value" >> "$BCKLOGFILE"
    echo "    Config File Setting: $current_config_setting" >> "$BCKLOGFILE"
    echo "----------------------------------------" >> "$BCKLOGFILE"

    # Determine compliance
    if [[ "$current_kernel_value" == "$required_value" ]] && [[ "$current_config_setting" == "$required_value" ]]; then
        echo "$(date '+%F %T') - INFO: $key is compliant (Value: $required_value)."
        return 0
    else
        echo "$(date '+%F %T') - WARNING: $key is NOT compliant. Fix needed."
        return 1
    fi
}

# Function: fix net.ipv4.conf.all.rp_filter to 1
7513_fix_rp_filter() {
    local key="net.ipv4.conf.all.rp_filter"
    local config_file="/etc/sysctl.conf"
    local target_value="1"

    # --- START CLUSTER CHECK ---
    if systemctl is-active --quiet pacemaker; then
        echo "$(date '+%F %T') - WARNING: Pacemaker service is ACTIVE. Fix skipped."
        echo "RPF ($key) must NOT be set to 1 on HA clusters due to potential asymmetric routing issues."
        return 2 # Fix skipped code
    fi
    # --- END CLUSTER CHECK ---

    # Backup current state before modification
    7513_scan_rp_filter

    # Check if key exists and replace/add
    if grep -qE "^$key\s*=" "$config_file"; then
        # Key exists: Replace the line
        sed -i "/^$key\s*=/c\\$key = $target_value" "$config_file"
        echo "$(date '+%F %T') - Changed setting in $config_file to $key = $target_value"
    else
        # Key does not exist: Append to file
        echo -e "\n# Set by Control 7513 for RPF hardening" >> "$config_file"
        echo "$key = $target_value" >> "$config_file"
        echo "$(date '+%F %T') - Added setting to $config_file as $key = $target_value"
    fi

    # Apply setting to active kernel
    if sysctl -w "$key=$target_value" && sysctl -w net.ipv4.route.flush=1; then
        echo "$(date '+%F %T') - Successfully applied $key = $target_value to active kernel."
        return 0
    else
        echo "$(date '+%F %T') - ERROR: Failed to apply setting to active kernel."
        return 1
    fi
}

# Function: restore net.ipv4.conf.all.rp_filter from backup
7513_restore_rp_filter() {
    local key="net.ipv4.conf.all.rp_filter"
    local config_file="/etc/sysctl.conf"
    local backup_file="$ENVDIR/7513_rp_filter_$RESTOREDATE.bck"

    # Check backup exists
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi

    # Read original values from backup file
    local original_kernel_setting
    local original_sysctl_file_setting
    original_kernel_setting=$(grep "Kernel Value" "$backup_file" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    original_sysctl_file_setting=$(grep "Config File Setting" "$backup_file" | awk -F ':' '{print $2}' | tr -d '[:space:]')

    # 2. Apply original setting to active kernel
    # Check if the value is a valid digit (0, 1, or 2)
    if ! [[ "$original_kernel_setting" =~ ^[0-2]$ ]]; then
        echo "ERROR: Original kernel value ($original_kernel_setting) is invalid. Skipping kernel restore."
        return 1
    fi 

    if sysctl -w net.ipv4.conf.all.rp_filter="$original_kernel_setting" > /dev/null 2>&1; then
        sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1
        echo "$(date '+%F %T') - Successfully applied RPF value $original_kernel_setting to kernel."
        return 0
    else
        echo "$(date '+%F %T') - ERROR: Failed to apply RPF value $original_kernel_value to kernel."
        return 1
    fi

    # 2. Restore original setting in /etc/sysctl.conf
    # Note: If original_config_setting was empty (no setting found), we remove the line.
    if [[ "$original_sysctl_file_setting" != "" ]]; then
        sed -i "/^$key\s*=/c\\$key = $original_sysctl_file_setting" "$config_file"
        echo "$(date '+%F %T') - Restored setting in $config_file to $key = $original_sysctl_file_setting"
    else
        # Original value was empty, meaning the line was added by fix -> remove it.
        sed -i "/^$key\s*=/d" "$config_file"
        echo "$(date '+%F %T') - Removed setting $key from $config_file (was not present initially)."
    fi
}


#----------------------------------------------------------------------------------------------
# Control ID: 12785 
# Description: Check, fix, remediate, and restore suid dumpable
#----------------------------------------------------------------------------------------------

# Variables defined outside the functions for ID 12785
KEY_12785="fs.suid_dumpable"
TARGET_VALUE_12785="0"
# Array of all potential configuration directories that may cause conflict
CONFIG_DIRS_12785=(
   "/lib/sysctl.d/"
   "/usr/lib/sysctl.d/"
   "/usr/local/lib/sysctl.d/"
   "/etc/sysctl.d/"
   "/run/sysctl.d/"
   "/etc/"

)

# Function: scan fs.suid_dumpable
12785_scan_suid_dumpable() {
    local key="$KEY_12785"
    local required_value="$TARGET_VALUE_12785"
    local config_dirs=("${CONFIG_DIRS_12785[@]}")
    local is_compliant=true

    # 1. Check active kernel setting
    local current_kernel_value
    current_kernel_value=$(sysctl -n "$key" 2>/dev/null)

    # Create backup log/state file
    touch "$ENVDIR/12785_suid_dumpable_$DATE.bck" 2>/dev/null
    local BCKLOGFILE="$ENVDIR/12785_suid_dumpable_$DATE.bck"
    echo "$(date '+%F %T') - Checking $key:" >> "$BCKLOGFILE"
    echo "    Kernel Value: $current_kernel_value" >> "$BCKLOGFILE"

    # Check active value compliance
    if [[ "$current_kernel_value" != "$required_value" ]]; then
        is_compliant=false
        echo "$(date '+%F %T') - WARNING: Kernel value is $current_kernel_value (expected $required_value)." >> "$BCKLOGFILE"
    fi

    # 2. Check configuration files for conflicting values (Target 1 or 2 is a conflict)
    for dir in "${config_dirs[@]}"; do
        find "$dir" -maxdepth 1 -name "*.conf" 2>/dev/null | while read -r file; do
        local file_setting
        if [ -f "$file" ] || [ -L "$file" ]; then
            # Use grep and xargs for robust reading, filtering comments
            # grep will follow the symlink automatically
            file_setting=$(grep -E "^$key\s*=\s*[0-2]" "$file" | cut -d '=' -f 2- | xargs)

            if [[ -n "$file_setting" ]]; then
                echo "" >> "$BCKLOGFILE"
                echo "--- START FILE BACKUP: $file ---" >> "$BCKLOGFILE"
                cat "$file" >> "$BCKLOGFILE"
                echo "--- END FILE BACKUP: $file ---" >> "$BCKLOGFILE"
                echo "" >> "$BCKLOGFILE" 
                # Log detected setting
                echo "    Config File Setting: $file ($file_setting)" >> "$BCKLOGFILE"
                    
                    # Check for non-compliant values (1 or 2)
                    if [[ "$file_setting" != "$required_value" ]]; then
                        is_compliant=false
                        # OPRAVA 3: Přidáno přesměrování do logu (chybělo '>> "$BCKLOGFILE"')
                        echo "$(date '+%F %T') - WARNING: $file contains conflicting value $file_setting." >> "$BCKLOGFILE"
                    fi
                fi
            fi
        done
    done
    
    echo "----------------------------------------" >> "$BCKLOGFILE"

    if $is_compliant; then
        echo "$(date '+%F %T') - INFO: $key is compliant (Value: $required_value)." >> "$BCKLOGFILE"
        return 0
    else
        echo "$(date '+%F %T') - WARNING: $key is NOT compliant. Fix needed." >> "$BCKLOGFILE"
        return 1
    fi
}

# Function: fix fs.suid_dumpable to 0
12785_fix_suid_dumpable() {
    local key="$KEY_12785"
    local target_value="$TARGET_VALUE_12785"
    local config_dirs=("${CONFIG_DIRS_12785[@]}")
    local fix_file="/etc/sysctl.d/99-secdevhand-core.conf" # New file with highest priority
    local changes_made=false

    # Backup current state before modification
    # (Assumes 12785_scan_suid_dumpable is updated to backup full files and find links)
    12785_scan_suid_dumpable

    # 1. Create/overwrite high-priority file (99) to enforce TARGET_VALUE_12785=0
    if ! grep -qE "^$key\s*=$target_value" "$fix_file" 2>/dev/null; then
        echo -e "\n# Set by Control 12785 for SUID hardening" > "$fix_file"
        echo "$key = $target_value" >> "$fix_file"
        echo "$(date '+%F %T') - Created high-priority file $fix_file with $key = $target_value"
        changes_made=true
    fi

    # 2. Neutralize conflicting files (overwrite values 1 or 2 to 0)
    for dir in "${config_dirs[@]}"; do
        # --- FIX: Removed '-type f' to include symbolic links (like 99-sysctl.conf) ---
        find "$dir" -maxdepth 1 -name "*.conf" 2>/dev/null | while read -r file; do
            
            # Check if the path found is a readable file or symbolic link
            if [ -f "$file" ] || [ -L "$file" ]; then
                # Search for settings that are 1 or 2 (non-compliant)
                if grep -qE "^$key\s*=\s*[1-2]" "$file"; then
                    # sed -i follows symbolic links and modifies the target file
                    sed -i "/^$key\s*=/c\\$key = $target_value" "$file"
                    echo "$(date '+%F %T') - Neutralized conflicting setting in $file to $key = $target_value"
                    changes_made=true
                fi
            fi
        done
    done

    # 3. Apply setting to active kernel (by reloading all sysctl files)
    if sysctl --system; then
        echo "$(date '+%F %T') - Successfully applied $key = $target_value to active kernel."
        return 0
    else
        echo "$(date '+%F %T') - ERROR: Failed to apply setting to active kernel via sysctl --system."
        return 1
    fi
}

# Function: restore fs.suid_dumpable using values stored in the backup log file
12785_restore_suid_dumpable() {
    local key="$KEY_12785"
    local fix_file_path="/etc/sysctl.d/99-secdevhand-core.conf" # Use this path directly for removal
    local config_dirs=("${CONFIG_DIRS_12785[@]}")
    local restore_timestamp="$RESTOREDATE" # Uses the global variable from the CLI argument -r

    if [[ -z "$restore_timestamp" ]]; then
        echo "$(date '+%F %T') - ERROR: RESTOREDATE variable is empty. Cannot proceed."
        return 1
    fi

    # 0. Identify files and their original values from the log file
    local log_file="$ENVDIR/12785_suid_dumpable_${restore_timestamp}.bck"

    if [ ! -f "$log_file" ]; then
         echo "$(date '+%F %T') - ERROR: Backup log file $log_file not found. Cannot determine original values."
         return 1
    fi

   # Backup current state before modification
   12785_scan_suid_dumpable
    

    
    # Extract the list of files and their original values from the log
    # Temporary file structure: "file_path original_value"
    local restore_count=0
    local restore_list_file=$(mktemp)
    # AWK prints $4 (path) and $5 (value in parenthesis), SED removes parentheses
    grep "Config File Setting:" "$log_file" | awk '{print $4, $5}' | sed 's/[()]//g' > "$restore_list_file"
    
    if [ ! -s "$restore_list_file" ]; then
        echo "$(date '+%F %T') - INFO: No configuration file settings found in log to restore. Continuing with fix file removal."
    fi

    # 1. Restore the specific original value to each identified file
    while read -r file original_value; do
        if [ -f "$file" ] || [ -L "$file" ]; then
            # Overwrite the specific setting in the file with the actual original value from the log
            sed -i "/^$key\s*=/c\\$key = $original_value" "$file"
            echo "$(date '+%F %T') - Restored $file setting to $key = $original_value."
            restore_count=$((restore_count + 1))
        else
            echo "$(date '+%F %T') - WARNING: Config file $file not found or unreadable. Skipping restoration."
        fi
    done < "$restore_list_file"

    # Clean up the temporary file
    rm -f "$restore_list_file"

    if [[ "$restore_count" -gt 0 ]]; then
        echo "$(date '+%F %T') - Successfully restored $restore_count configuration files using values from the log."
    fi

    # 2. Remove the high-priority fix file
    if [ -f "$fix_file_path" ]; then
        rm -f "$fix_file_path"
        echo "$(date '+%F %T') - Removed high-priority fix file: $fix_file_path"
    else
        echo "$(date '+%F %T') - INFO: Fix file $fix_file_path not found. Nothing to remove."
    fi

    # 3. Reload all configuration files (activates the restored values)
    if sysctl --system; then
        echo "$(date '+%F %T') - Successfully reloaded sysctl settings to active kernel. Original state restored."
        return 0
    else
        echo "$(date '+%F %T') - ERROR: Failed to reload sysctl settings. Manual review needed."
        return 1
    fi
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
    [7513]="rp_filter"
    [12785]="suid_dumpable"
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
