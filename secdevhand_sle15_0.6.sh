#!/bin/bash

#--------------------------------------------------------------------------------------------------------
# file secdevhand.sh
# Script Name: secdevhand
# Description: Security deviation and system configuration handler for checking, fixing, and restoring
#              system deviations (idempotent, fully logged).
# Author: OK 
# Date: 2025-11-12
# Version 0.6
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
# Description: Check, fix, remediate, and restore sysctl: net.ipv4.conf.all.rp_filter (uid dumpable)
#----------------------------------------------------------------------------------------------


7513_scan_sysctl_rp_filter() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    #Change also f(x) name itself (above)
    local ID="7513"
    local DESCRIPTION_SUFFIX="sysctl_rp_filter"
    local key="net.ipv4.conf.all.rp_filter"
    local required_value="1"
    local config_dirs=(
        "/lib/sysctl.d/"
        "/usr/lib/sysctl.d/"
        "/usr/local/lib/sysctl.d/"
        "/etc/sysctl.d/"
        "/run/sysctl.d/"
        "/etc/"
    )
    # -----------------------------------------------------------------------

    local is_compliant=true

    # 1. Check active kernel setting
    local current_kernel_value
    current_kernel_value=$(sysctl -n "$key" 2>/dev/null)

    # Create backup log/state file
    touch "$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck" 2>/dev/null
    local BCKLOGFILE="$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck"
    echo "$(date '+%F %T') - Checking $key (ID $ID):" >> "$BCKLOGFILE"
    echo "    Kernel Value: $current_kernel_value" >> "$BCKLOGFILE"

    # Check active value compliance
    if [[ "$current_kernel_value" != "$required_value" ]]; then
        is_compliant=false
        echo "$(date '+%F %T') - WARNING: Kernel value is $current_kernel_value (expected $required_value)." >> "$BCKLOGFILE"
    fi

    # 2. Check configuration files for conflicting values
    for dir in "${config_dirs[@]}"; do
        find "$dir" -maxdepth 1 -name "*.conf" 2>/dev/null | while read -r file; do
            local file_setting
            if [ -f "$file" ] || [ -L "$file" ]; then
                # Use grep and xargs for robust reading, filtering comments (Logic retained: [0-2])
                file_setting=$(grep -E "^$key\s*=\s*[0-2]" "$file" | cut -d '=' -f 2- | xargs)

                if [[ -n "$file_setting" ]]; then
                    echo "" >> "$BCKLOGFILE"
                    echo "--- START FILE BACKUP: $file ---" >> "$BCKLOGFILE"
                    cat "$file" >> "$BCKLOGFILE"
                    echo "--- END FILE BACKUP: $file ---" >> "$BCKLOGFILE"
                    echo "" >> "$BCKLOGFILE"
                    # Log detected setting (Critical for restore)
                    echo "    Config File Setting: $file ($file_setting)" >> "$BCKLOGFILE"

                    # Check for non-compliant values
                    if [[ "$file_setting" != "$required_value" ]]; then
                        is_compliant=false
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

7513_fix_sysctl_rp_filter() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    #Change also f(x) name itself (above)
    local ID="7513"
    local DESCRIPTION_SUFFIX="sysctl_rp_filter"
    local key="net.ipv4.conf.all.rp_filter"
    local target_value="1"
    local config_dirs=(
        "/lib/sysctl.d/"
        "/usr/lib/sysctl.d/"
        "/usr/local/lib/sysctl.d/"
        "/etc/sysctl.d/"
        "/run/sysctl.d/"
        "/etc/"
    )
    local changes_made=false

    # Backup current state before modification (Calls the ID-specific scan)
    7513_scan_sysctl_rp_filter
    # -----------------------------------------------------------------------

    # 1. Neutralize conflicting files (overwrite values 1 or 2 to target_value)
    for dir in "${config_dirs[@]}"; do
        find "$dir" -maxdepth 1 -name "*.conf" 2>/dev/null | while read -r file; do
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

    # 2. Apply setting to active kernel (by reloading all sysctl files)
    if sysctl --system; then
        echo "$(date '+%F %T') - Successfully applied $key = $target_value to active kernel."
        return 0
    else
        echo "$(date '+%F %T') - ERROR: Failed to apply setting to active kernel via sysctl --system."
        return 1
    fi
}

7513_restore_sysctl_rp_filter() {
    # -----------------------------------------------------------------------
    # --- CONFIGURATION BLOCK: EDIT FOR NEW ID ---
    local ID="7513"
    local DESCRIPTION_SUFFIX="sysctl_rp_filter"
    local key="net.ipv4.conf.all.rp_filter"

    # Backup current state before modification (CRITICAL STEP 0)
    # NOTE: Using the correct scan function name.
    7513_scan_sysctl_rp_filter
    #EXCEPTION TO BE CHANGED : # sysctl -w net.ipv4.route.flush=1
    # -----------------------------------------------------------------------

    local restore_timestamp="$RESTOREDATE"

    if [[ -z "$restore_timestamp" ]]; then
        echo "$(date '+%F %T') - ERROR: RESTOREDATE variable is empty. Cannot proceed."
        return 1
    fi

    local log_file="$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_${restore_timestamp}.bck"

    if [ ! -f "$log_file" ]; then
        echo "$(date '+%F %T') - ERROR: Backup log file $log_file not found. Cannot determine original values."
        return 1
    fi

    # 1. READ FILE VALUES FROM LOG (Preparation)
    local restore_count=0
    local restore_list_file=$(mktemp)

    # AWK prints $4 (path) and $5 (value in parenthesis), SED removes parentheses
    grep "Config File Setting:" "$log_file" | awk '{print $4, $5}' | sed 's/[()]//g' > "$restore_list_file"

    if [ ! -s "$restore_list_file" ]; then
        echo "$(date '+%F %T') - INFO: No configuration file settings found in log to restore. Continuing."
    fi

    # 2. WRITE FILE VALUES (Restore Permanent State)
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
        echo "$(date '+%F %T') - Successfully restored $restore_count configuration files."
    fi

    # 3. READ KERNEL VALUE FROM LOG
    local original_kernel_value
    # Find the 'Kernel Value:' line and extract the last field.
    original_kernel_value=$(grep "Kernel Value:" "$log_file" | head -n 1 | awk '{print $NF}' | tr -d '[:space:]')

    if [[ -z "$original_kernel_value" ]]; then
        echo "$(date '+%F %T') - WARNING: Could not extract original kernel value from log. Falling back to sysctl --system."
    fi

    # 4. WRITE KERNEL VALUE (Restore Active/Temporary State)
    if [[ -n "$original_kernel_value" ]]; then
        if sysctl -w "$key=$original_kernel_value"; then
            sysctl -w net.ipv4.route.flush=1
            echo "$(date '+%F %T') - Successfully restored active kernel setting to $key = $original_kernel_value."
            return 0
        else
            echo "$(date '+%F %T') - ERROR: Failed to restore active kernel setting $key. Manual review needed."
            return 1
        fi
    else
        # Fallback: If the original active value was unknown, use the safer sysctl --system 
        # to ensure the value restored in the files is applied to the kernel.
        echo "$(date '+%F %T') - WARNING: Original kernel value unknown. Running 'sysctl --system' as a fallback."
        if sysctl --system; then
            echo "$(date '+%F %T') - Fallback sysctl reload successful."
            return 0
        else
            echo "$(date '+%F %T') - ERROR: Fallback sysctl reload failed."
            return 1
        fi
    fi
}



#----------------------------------------------------------------------------------------------
# Control ID: 12785 
# Description: Check, fix, remediate, and restore sysctl: fs.suid_dumpable (uid dumpable)
#----------------------------------------------------------------------------------------------


12785_scan_sysctl_suid_dumpable() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    #Change also f(x) name itself (above)
    local ID="12785"
    local DESCRIPTION_SUFFIX="sysctl_suid_dumpable"
    local key="fs.suid_dumpable"
    local required_value="0"
    local config_dirs=(
        "/lib/sysctl.d/"
        "/usr/lib/sysctl.d/"
        "/usr/local/lib/sysctl.d/"
        "/etc/sysctl.d/"
        "/run/sysctl.d/"
        "/etc/"
    )
    # -----------------------------------------------------------------------
    
    local is_compliant=true

    # 1. Check active kernel setting
    local current_kernel_value
    current_kernel_value=$(sysctl -n "$key" 2>/dev/null)

    # Create backup log/state file
    touch "$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck" 2>/dev/null
    local BCKLOGFILE="$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck"
    echo "$(date '+%F %T') - Checking $key (ID $ID):" >> "$BCKLOGFILE"
    echo "    Kernel Value: $current_kernel_value" >> "$BCKLOGFILE"

    # Check active value compliance
    if [[ "$current_kernel_value" != "$required_value" ]]; then
        is_compliant=false
        echo "$(date '+%F %T') - WARNING: Kernel value is $current_kernel_value (expected $required_value)." >> "$BCKLOGFILE"
    fi

    # 2. Check configuration files for conflicting values
    for dir in "${config_dirs[@]}"; do
        find "$dir" -maxdepth 1 -name "*.conf" 2>/dev/null | while read -r file; do
            local file_setting
            if [ -f "$file" ] || [ -L "$file" ]; then
                # Use grep and xargs for robust reading, filtering comments (Logic retained: [0-2])
                file_setting=$(grep -E "^$key\s*=\s*[0-2]" "$file" | cut -d '=' -f 2- | xargs)

                if [[ -n "$file_setting" ]]; then
                    echo "" >> "$BCKLOGFILE"
                    echo "--- START FILE BACKUP: $file ---" >> "$BCKLOGFILE"
                    cat "$file" >> "$BCKLOGFILE"
                    echo "--- END FILE BACKUP: $file ---" >> "$BCKLOGFILE"
                    echo "" >> "$BCKLOGFILE"
                    # Log detected setting (Critical for restore)
                    echo "    Config File Setting: $file ($file_setting)" >> "$BCKLOGFILE"

                    # Check for non-compliant values
                    if [[ "$file_setting" != "$required_value" ]]; then
                        is_compliant=false
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


12785_fix_sysctl_suid_dumpable() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    #Change also f(x) name itself (above)
    local ID="12785"
    local DESCRIPTION_SUFFIX="sysctl_suid_dumpable"
    local key="fs.suid_dumpable"
    local target_value="0"
    local config_dirs=(
        "/lib/sysctl.d/"
        "/usr/lib/sysctl.d/"
        "/usr/local/lib/sysctl.d/"
        "/etc/sysctl.d/"
        "/run/sysctl.d/"
        "/etc/"
    )
    local changes_made=false

    # Backup current state before modification (Calls the ID-specific scan)
    12785_scan_sysctl_suid_dumpable
    # -----------------------------------------------------------------------

    # 1. Neutralize conflicting files (overwrite values 1 or 2 to target_value)
    for dir in "${config_dirs[@]}"; do
        find "$dir" -maxdepth 1 -name "*.conf" 2>/dev/null | while read -r file; do
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

    # 2. Apply setting to active kernel (by reloading all sysctl files)
    if sysctl --system; then
        echo "$(date '+%F %T') - Successfully applied $key = $target_value to active kernel."
        return 0
    else
        echo "$(date '+%F %T') - ERROR: Failed to apply setting to active kernel via sysctl --system."
        return 1
    fi
}


12785_restore_sysctl_suid_dumpable() {
    # -----------------------------------------------------------------------
    # --- CONFIGURATION BLOCK: EDIT FOR NEW ID ---
    local ID="12785"
    local DESCRIPTION_SUFFIX="sysctl_suid_dumpable"
    local key="fs.suid_dumpable"
    
    # Backup current state before modification (CRITICAL STEP 0)
    # NOTE: Using the correct scan function name.
    12785_scan_sysctl_suid_dumpable 
    # -----------------------------------------------------------------------

    local restore_timestamp="$RESTOREDATE"

    if [[ -z "$restore_timestamp" ]]; then
        echo "$(date '+%F %T') - ERROR: RESTOREDATE variable is empty. Cannot proceed."
        return 1
    fi

    local log_file="$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_${restore_timestamp}.bck"

    if [ ! -f "$log_file" ]; then
        echo "$(date '+%F %T') - ERROR: Backup log file $log_file not found. Cannot determine original values."
        return 1
    fi

    # 1. READ FILE VALUES FROM LOG (Preparation)
    local restore_count=0
    local restore_list_file=$(mktemp)

    # AWK prints $4 (path) and $5 (value in parenthesis), SED removes parentheses
    grep "Config File Setting:" "$log_file" | awk '{print $4, $5}' | sed 's/[()]//g' > "$restore_list_file"

    if [ ! -s "$restore_list_file" ]; then
        echo "$(date '+%F %T') - INFO: No configuration file settings found in log to restore. Continuing."
    fi

    # 2. WRITE FILE VALUES (Restore Permanent State)
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
        echo "$(date '+%F %T') - Successfully restored $restore_count configuration files."
    fi

    # 3. READ KERNEL VALUE FROM LOG
    local original_kernel_value
    # Find the 'Kernel Value:' line and extract the last field.
    original_kernel_value=$(grep "Kernel Value:" "$log_file" | head -n 1 | awk '{print $NF}' | tr -d '[:space:]')
    
    if [[ -z "$original_kernel_value" ]]; then
        echo "$(date '+%F %T') - WARNING: Could not extract original kernel value from log. Falling back to sysctl --system."
    fi
    
    # 4. WRITE KERNEL VALUE (Restore Active/Temporary State)
    if [[ -n "$original_kernel_value" ]]; then
        if sysctl -w "$key=$original_kernel_value"; then
            echo "$(date '+%F %T') - Successfully restored active kernel setting to $key = $original_kernel_value."
            return 0
        else
            echo "$(date '+%F %T') - ERROR: Failed to restore active kernel setting $key. Manual review needed."
            return 1
        fi
    else
        # Fallback: If the original active value was unknown, use the safer sysctl --system 
        # to ensure the value restored in the files is applied to the kernel.
        echo "$(date '+%F %T') - WARNING: Original kernel value unknown. Running 'sysctl --system' as a fallback."
        if sysctl --system; then
            echo "$(date '+%F %T') - Fallback sysctl reload successful."
            return 0
        else
            echo "$(date '+%F %T') - ERROR: Fallback sysctl reload failed."
            return 1
        fi
    fi
}


#----------------------------------------------------------------------------------------------
# Control ID: 10492 
# Description: Check and scan sysctl: net.ipv6.conf.all.disable_ipv6 (Disable IPv6)
# Expected Value: File not found OR match all equal to 1
#----------------------------------------------------------------------------------------------

10492_scan_sysctl_disable_ipv6() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    local ID="10492"
    local DESCRIPTION_SUFFIX="sysctl_disable_ipv6"
    local key="net.ipv6.conf.all.disable_ipv6"
    local required_value="1"
    local config_dirs=(
        "/lib/sysctl.d/"
        "/usr/lib/sysctl.d/"
        "/usr/local/lib/sysctl.d/"
        "/etc/sysctl.d/"
        "/run/sysctl.d/"
        "/etc/"
    )
    # -----------------------------------------------------------------------

    local is_compliant=true

    # 1. Check active kernel setting
    local current_kernel_value
    current_kernel_value=$(sysctl -n "$key" 2>/dev/null)

    # Create backup log/state file
    touch "$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck" 2>/dev/null
    local BCKLOGFILE="$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck"
    echo "$(date '+%F %T') - Checking $key (ID $ID):" >> "$BCKLOGFILE"
    echo "    Kernel Value: $current_kernel_value" >> "$BCKLOGFILE"

    # Check active value compliance
    if [[ "$current_kernel_value" != "$required_value" ]]; then
        is_compliant=false
        echo "$(date '+%F %T') - WARNING: Kernel value is $current_kernel_value (expected $required_value)." >> "$BCKLOGFILE"
    fi

    # 2. Check configuration files for conflicting values (any value not equal to 1)
    for dir in "${config_dirs[@]}"; do
        find "$dir" -maxdepth 1 -name "*.conf" 2>/dev/null | while read -r file; do
            local file_setting
            if [ -f "$file" ] || [ -L "$file" ]; then
                # Search for settings (Logic retained: [0-1], as only 0 conflicts with 1)
                file_setting=$(grep -E "^$key\s*=\s*[0-1]" "$file" | cut -d '=' -f 2- | xargs)

                if [[ -n "$file_setting" ]]; then
                    echo "" >> "$BCKLOGFILE"
                    echo "--- START FILE BACKUP: $file ---" >> "$BCKLOGFILE"
                    cat "$file" >> "$BCKLOGFILE"
                    echo "--- END FILE BACKUP: $file ---" >> "$BCKLOGFILE"
                    echo "" >> "$BCKLOGFILE"
                    # Log detected setting (Critical for restore)
                    echo "    Config File Setting: $file ($file_setting)" >> "$BCKLOGFILE"

                    # Check for non-compliant values (any value other than 1)
                    if [[ "$file_setting" != "$required_value" ]]; then
                        is_compliant=false
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

10492_fix_sysctl_disable_ipv6() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    local ID="10492"
    local DESCRIPTION_SUFFIX="sysctl_disable_ipv6"
    local key="net.ipv6.conf.all.disable_ipv6"
    local target_value="1"
    local config_dirs=(
        "/lib/sysctl.d/"
        "/usr/lib/sysctl.d/"
        "/usr/local/lib/sysctl.d/"
        "/etc/sysctl.d/"
        "/run/sysctl.d/"
        "/etc/"
    )
    local changes_made=false

    # Backup current state before modification (Calls the ID-specific scan)
    10492_scan_sysctl_disable_ipv6
    # -----------------------------------------------------------------------

    # 1. Neutralize conflicting files (overwrite value 0 to target_value 1)
    for dir in "${config_dirs[@]}"; do
        find "$dir" -maxdepth 1 -name "*.conf" 2>/dev/null | while read -r file; do
            if [ -f "$file" ] || [ -L "$file" ]; then
                # Search for settings that are 0 (non-compliant)
                if grep -qE "^$key\s*=\s*0" "$file"; then
                    # sed -i follows symbolic links and modifies the target file
                    sed -i "/^$key\s*=/c\\$key = $target_value" "$file"
                    echo "$(date '+%F %T') - Neutralized conflicting setting in $file to $key = $target_value"
                    changes_made=true
                fi
            fi
        done
    done
    
    # NOTE: If no file contained the setting, we must ensure it is present to enforce the policy.
    # The simplest way is to add it to a common configuration file (e.g., /etc/sysctl.conf)
    if ! $changes_made && ! grep -qE "^$key\s*=\s*$target_value" /etc/sysctl.conf; then
        echo "$key = $target_value" >> /etc/sysctl.conf
        echo "$(date '+%F %T') - Added $key = $target_value to /etc/sysctl.conf to ensure permanent compliance."
        changes_made=true
    fi

    # 2. Apply setting to active kernel (by reloading all sysctl files)
    if sysctl --system; then
        echo "$(date '+%F %T') - Successfully applied $key = $target_value to active kernel."
        return 0
    else
        echo "$(date '+%F %T') - ERROR: Failed to apply setting to active kernel via sysctl --system."
        return 1
    fi
}

10492_restore_sysctl_disable_ipv6() {
    # -----------------------------------------------------------------------
    # --- CONFIGURATION BLOCK: EDIT FOR NEW ID ---
    local ID="10492"
    local DESCRIPTION_SUFFIX="sysctl_disable_ipv6"
    local key="net.ipv6.conf.all.disable_ipv6"

    # Backup current state before modification (CRITICAL STEP 0)
    10492_scan_sysctl_disable_ipv6
    # -----------------------------------------------------------------------

    local restore_timestamp="$RESTOREDATE"

    if [[ -z "$restore_timestamp" ]]; then
        echo "$(date '+%F %T') - ERROR: RESTOREDATE variable is empty. Cannot proceed."
        return 1
    fi

    local log_file="$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_${restore_timestamp}.bck"

    if [ ! -f "$log_file" ]; then
        echo "$(date '+%F %T') - ERROR: Backup log file $log_file not found. Cannot determine original values."
        return 1
    fi
    
    # 1. READ FILE VALUES FROM LOG (Preparation)
    local restore_count=0
    local restore_list_file=$(mktemp)

    # AWK prints $4 (path) and $5 (value in parenthesis), SED removes parentheses
    grep "Config File Setting:" "$log_file" | awk '{print $4, $5}' | sed 's/[()]//g' > "$restore_list_file"

    # 2. WRITE FILE VALUES (Restore Permanent State)
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
        echo "$(date '+%F %T') - Successfully restored $restore_count configuration files."
    fi

    # --- SPECIFIC RESTORE LOGIC ---
    # Due to the FIX potentially adding the key to /etc/sysctl.conf (if not found initially),
    # we must ensure that if the original log showed "File not found", the added line is removed.
    
    # Check if the key was found in any config file BEFORE the fix (i.e., if restore_count > 0).
    if [[ "$restore_count" -eq 0 ]]; then
        # If restore_count is 0, it means the setting was NOT present in any config file 
        # that was previously scanned (Scenario: File not found). 
        # We must remove any line that 'fix' might have added to enforce compliance.
        
        # We target the common file used in the FIX function.
        if grep -qE "^$key\s*=\s*$target_value" /etc/sysctl.conf; then
            sed -i "/^$key\s*=\s*$target_value/d" /etc/sysctl.conf
            echo "$(date '+%F %T') - Removed enforced setting from /etc/sysctl.conf to restore 'File not found' state."
        fi
    fi
    
    # 3. READ KERNEL VALUE FROM LOG
    local original_kernel_value
    original_kernel_value=$(grep "Kernel Value:" "$log_file" | head -n 1 | awk '{print $NF}' | tr -d '[:space:]')
    
    if [[ -z "$original_kernel_value" ]]; then
        echo "$(date '+%F %T') - WARNING: Could not extract original kernel value from log. Falling back to sysctl --system."
    fi

    # 4. WRITE KERNEL VALUE (Restore Active/Temporary State)
    if [[ -n "$original_kernel_value" ]]; then
        if sysctl -w "$key=$original_kernel_value"; then
            echo "$(date '+%F %T') - Successfully restored active kernel setting to $key = $original_kernel_value."
            return 0
        else
            echo "$(date '+%F %T') - ERROR: Failed to restore active kernel setting $key. Manual review needed."
            return 1
        fi
    else
        # Fallback: Use sysctl --system to ensure the kernel value is synchronized with the restored config files.
        echo "$(date '+%F %T') - WARNING: Original kernel value unknown. Running 'sysctl --system' as a fallback."
        if sysctl --system; then
            echo "$(date '+%F %T') - Fallback sysctl reload successful."
            return 0
        else
            echo "$(date '+%F %T') - ERROR: Fallback sysctl reload failed."
            return 1
        fi
    fi
}

#----------------------------------------------------------------------------------------------
# Control ID: 10859 
# Description: Check and scan cron configuration for 'aide --check' task
# Expected Value: Contains regular expression ^.*(/usr/sbin|/sbin)/aide --check
#----------------------------------------------------------------------------------------------

10859_scan_aide_cron() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    local ID="10859"
    local DESCRIPTION_SUFFIX="aide_cron"
    local required_regex="^.*(/usr/sbin|/sbin)/aide --check"
    # Target files to check for the cron job (as mentioned in the volatility description)
    local target_files=(
        "/etc/crontab"
        "/etc/cron.d/"
        "/etc/cron.hourly/"
        "/etc/cron.daily/"
        "/etc/cron.weekly/"
        "/etc/cron.monthly/"
    )
    local is_compliant=false

    # Create backup log/state file
    touch "$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck" 2>/dev/null
    local BCKLOGFILE="$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck"
    echo "$(date '+%F %T') - Checking aide cron job (ID $ID):" >> "$BCKLOGFILE"

    # 1. Check all target files/directories for the required regex
    for target in "${target_files[@]}"; do
        if [ -f "$target" ]; then
            # Check individual files (like /etc/crontab)
            if grep -E "$required_regex" "$target" 2>/dev/null; then
                is_compliant=true
                echo "$(date '+%F %T') - INFO: Found compliant entry in $target." >> "$BCKLOGFILE"
                echo "    Found Setting: $target (Compliant)" >> "$BCKLOGFILE"
                # Back up the file where the setting was found, critical for restore context
                echo "--- START FILE BACKUP: $target ---" >> "$BCKLOGFILE"
                cat "$target" >> "$BCKLOGFILE"
                echo "--- END FILE BACKUP: $target ---" >> "$BCKLOGFILE"
                echo "" >> "$BCKLOGFILE"
            fi
        elif [ -d "$target" ]; then
            # Check files within cron directories
            
            # --- ZMĚNA ZDE: Použijeme find -exec grep -H, aby se zajistil výstup FILE:LINE_CONTENT ---
            find "$target" -maxdepth 1 -type f -exec grep -H -E "$required_regex" {} \; 2>/dev/null | while read -r line; do
                
                # Extrahujeme název souboru (před první ':') a obsah řádku (za první ':')
                # Toto řeší problém, kdy se celý řádek stává "No such file or directory"
                local file=$(echo "$line" | cut -d ':' -f 1)
                local entry=$(echo "$line" | cut -d ':' -f 2-)
                
                # Odstranění úvodních/koncových mezer z entry
                entry=$(echo "$entry" | xargs)
                
                is_compliant=true
                echo "$(date '+%F %T') - INFO: Found compliant entry in directory $target in file $file." >> "$BCKLOGFILE"
                echo "    Found Setting: $file ($entry)" >> "$BCKLOGFILE"
                
                # Back up the specific file
                echo "--- START FILE BACKUP: $file ---" >> "$BCKLOGFILE"
                cat "$file" >> "$BCKLOGFILE"
                echo "--- END FILE BACKUP: $file ---" >> "$BCKLOGFILE"
                echo "" >> "$BCKLOGFILE"
            done
        fi
    done

    echo "----------------------------------------" >> "$BCKLOGFILE"
    
    # 2. Final Compliance Check
    if $is_compliant; then
        echo "$(date '+%F %T') - INFO: Required aide cron job is present and compliant." >> "$BCKLOGFILE"
        return 0
    else
        echo "$(date '+%F %T') - WARNING: Required aide cron job NOT found. Fix needed." >> "$BCKLOGFILE"
        return 1
    fi
}


10859_fix_aide_cron() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    local ID="10859"
    local DESCRIPTION_SUFFIX="aide_cron"
    # The cron entry to enforce (using the example provided: 0 5 * * * /usr/sbin/aide --check)
    local target_cron_entry="0 5 * * * root /usr/sbin/aide --check"
    local target_cron_file="/etc/cron.d/aide_${ID}_check" # Unique file for easy restoration
    # -----------------------------------------------------------------------

    # Backup current state before modification
    10859_scan_aide_cron
    
    # Check if the job is already compliant before writing the fix
    if 10859_scan_aide_cron; then
        echo "$(date '+%F %T') - INFO: Aide cron job is already compliant. No fix applied."
        return 0
    fi
    
    # 1. Apply the fix: Write the required cron job to a dedicated file in /etc/cron.d/
    echo "$target_cron_entry" > "$target_cron_file"
    
    if [ $? -eq 0 ]; then
        echo "$(date '+%F %T') - Successfully added aide cron job to $target_cron_file."
        # The file name is logged for the restore function
        echo "FIXED_FILE: $target_cron_file" >> "$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck"
        return 0
    else
        echo "$(date '+%F %T') - ERROR: Failed to write aide cron job to $target_cron_file."
        return 1
    fi
}


10859_restore_aide_cron() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    local ID="10859"
    local DESCRIPTION_SUFFIX="aide_cron"
    # Target file that FIX function creates
    local target_cron_file="/etc/cron.d/aide_${ID}_check" 
    # -----------------------------------------------------------------------

    # Backup current state before modification
    10859_scan_aide_cron
    
    # 1. Check if the fixed file exists and remove it
    if [ -f "$target_cron_file" ]; then
        rm -f "$target_cron_file"
        if [ $? -eq 0 ]; then
            echo "$(date '+%F %T') - Successfully removed the fixed cron job file: $target_cron_file."
            return 0
        else
            echo "$(date '+%F %T') - ERROR: Failed to remove the fixed cron job file: $target_cron_file."
            return 1
        fi
    else
        echo "$(date '+%F %T') - INFO: Fixed cron job file $target_cron_file not found. Nothing to restore."
        return 0
    fi
}


#----------------------------------------------------------------------------------------------
# Control ID: 12884 
# Description: Check umask setting in /etc/profile and /etc/profile.d/*.sh files.
# Expected Value: matches regex ^\s*umask\s*[0-7]{1}[0-7]{1}[2367] (e.g., umask 022)
#----------------------------------------------------------------------------------------------

12884_scan_umask_profile() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    local ID="12884"
    local DESCRIPTION_SUFFIX="umask_profile"
    local required_regex="^\s*umask\s*[0-7]{1}[0-7]{1}[2367]" 
    local target_files=("/etc/profile" "/etc/profile.d/*.sh")
    local is_compliant=false
    # -----------------------------------------------------------------------

    # Create backup log/state file
    touch "$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck" 2>/dev/null
    local BCKLOGFILE="$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck"
    echo "$(date '+%F %T') - Checking umask profile setting (ID $ID):" >> "$BCKLOGFILE"

    # 1. Check all target files/directories for the required regex
    for target in "${target_files[@]}"; do
        # Use find/grep to find all relevant files and print the matches with filenames (-H)
        find $(dirname "$target") -maxdepth 1 -type f -name "$(basename "$target")" -exec grep -H -E "$required_regex" {} \; 2>/dev/null | while read -r line; do
            
            # Use IFS to reliably parse FILE:CONTENT
            local IFS=:
            local file entry
            read -r file entry <<< "$line"
            local IFS=$' \t\n' 
            entry=$(echo "$entry" | xargs)
            
            is_compliant=true
            echo "$(date '+%F %T') - INFO: Found compliant umask entry in $file." >> "$BCKLOGFILE"
            echo "    Found Setting: $file ($entry)" >> "$BCKLOGFILE"
            
            # Backup /etc/profile if found, although we don't modify it now, it's good for context
            if [ "$target" = "/etc/profile" ] && [ -f "$target" ]; then
                 echo "--- START FILE BACKUP: $target ---" >> "$BCKLOGFILE"
                 cat "$target" >> "$BCKLOGFILE"
                 echo "--- END FILE BACKUP: $target ---" >> "$BCKLOGFILE"
            fi
        done
    done

    echo "----------------------------------------" >> "$BCKLOGFILE"
    
    # 2. Final Compliance Check
    if $is_compliant; then
        echo "$(date '+%F %T') - INFO: Compliant umask setting found." >> "$BCKLOGFILE"
        return 0
    else
        echo "$(date '+%F %T') - WARNING: Compliant umask setting NOT found. Fix needed." >> "$BCKLOGFILE"
        return 1
    fi
}

12884_fix_umask_profile() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    local ID="12884"
    local DESCRIPTION_SUFFIX="umask_profile"
    # Target fix file in the profile directory
    local target_fix_file="/etc/profile.d/umask_${ID}_fix.sh" 
    local required_setting="umask 022"
    # -----------------------------------------------------------------------

    # Backup current state before modification
    12884_scan_umask_profile
    
    # Check if compliant (if the scan returns 0, no fix needed)
    if 12884_scan_umask_profile; then
        echo "$(date '+%F %T') - INFO: umask setting is already compliant. No fix applied."
        return 0
    fi
    
    # 1. Apply the fix: Create the dedicated script in /etc/profile.d/
    echo "#!/bin/bash" > "$target_fix_file"
    echo "# Set compliant umask for ID $ID, overriding any previous settings" >> "$target_fix_file"
    echo "$required_setting" >> "$target_fix_file"
    
    # Ensure execution permission so the script is sourced by /etc/profile
    chmod 755 "$target_fix_file" 
    
    if [ $? -eq 0 ]; then
        echo "$(date '+%F %T') - Successfully created fix script $target_fix_file with '$required_setting'."
        echo "ADDED_FILE: $target_fix_file" >> "$ENVDIR/${ID}_${DESCRIPTION_SUFFIX}_$DATE.bck"
        return 0
    else
        echo "$(date '+%F %T') - ERROR: Failed to create fix script $target_fix_file."
        return 1
    fi
}

12884_restore_umask_profile() {
    # --- LOCAL CONFIGURATION VARIABLES (Edit this block for each control) ---
    local ID="12884"
    local DESCRIPTION_SUFFIX="umask_profile"
    local target_fix_file="/etc/profile.d/umask_${ID}_fix.sh"
    # -----------------------------------------------------------------------
    
    # Backup current state (optional)
    12884_scan_umask_profile
    
    # 1. Check if the fixed file exists and remove it
    if [ -f "$target_fix_file" ]; then
        rm -f "$target_fix_file"
        if [ $? -eq 0 ]; then
            echo "$(date '+%F %T') - Successfully removed the fixed script: $target_fix_file."
            return 0
        else
            echo "$(date '+%F %T') - ERROR: Failed to remove the fixed script: $target_fix_file."
            return 1
        fi
    else
        echo "$(date '+%F %T') - INFO: Fixed script $target_fix_file not found. Nothing to restore."
        return 0
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
    [7513]="sysctl_rp_filter"
    [12785]="sysctl_suid_dumpable"
    [10492]="sysctl_disable_ipv6"
    [10859]="aide_cron"
    [12884]="umask_profile"
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
