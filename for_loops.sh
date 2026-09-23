#!/bin/bash

# This script demonstrates the use of loops in bash

for i in {1..5} 
do
    echo "Folder dir$i created"
    mkdir "dir$i"
done