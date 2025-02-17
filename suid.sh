#!/bin/bash

find packages/ -type d | while read dir; do
    if [ $(find "$dir" -type d | wc -l) -eq 1 ]; then
        random=$(printf "%06d" $((RANDOM % 1000000)))
        timestamp="$(date "+%s")${random}"
        echo "$timestamp" > "$dir/suid.txt"
        echo "Created suid.txt in $dir with timestamp $timestamp"
    fi
done
