#!/bin/bash

<< readme
This is a script for backup with 5 days rotation period.

usage: ./backup.sh <source_directory> <destination_directory>
readme

display_usage() {
    echo "Usage: $0 <source_directory> <destination_directory>"
    exit 1
}

if [[ $# -eq 0 ]]; then
    display_usage
fi

source_dir="$1"
backup_dir="$2"
timestamp=$(date '+%Y-%m-%d_%H:%M:%S')

create_backup() {

    zip -r "${backup_dir}/backup_${timestamp}.zip" "${source_dir}" > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Error: Backup creation failed."
        exit 1
    fi
    echo "Backup created at ${backup_dir}/backup_${timestamp}.zip"
}

perform_rotation() {
    backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))
    if [[ "${#backups[@]}" -gt 5 ]]; then
        echo "Performing rotation for 5 days..."

        backups_remove=("${backups[@]:5}")

        echo "${backups_remove[@]}"

        for backup in "${backups_remove[@]}"; do
            rm -f ${backup}
        done

    fi

}   

create_backup
perform_rotation