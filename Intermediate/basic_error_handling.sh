#!/bin/bash

create_directory() {
    name=$1
    mkdir "$name"
}

if [[ -n "$1" ]]; then
    name="$1"
else
    read -p "Enter name of directory to create: " name
fi


if ! create_directory "$name"; then
    echo "Error: Failed to create directory. Directory already exists."
    exit 1
fi

echo "Directory created successfully."