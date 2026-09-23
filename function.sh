#!/bin/bash

is_prime() {

    num=$1

    if (( num < 2 )); then
        return 1
    fi

    for (( i=2; i*i<=num; i++ )); do
        if (( num%i == 0 )); then
            return 1
        fi
    done

    return 0
}

if [[ -n "$1" ]]; then
    num="$1"
else
    read -p "Enter a number: " num
fi

if [[ ! $num =~ ^[0-9]+$ ]]; then
    echo "Please enter a valid positive integer."
    exit 1
fi

if is_prime "$num"; then
    echo "$num is a prime number."
else
    echo "$num is not a prime number."
fi