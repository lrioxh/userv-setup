#!/bin/bash

path="/"

space_info=$(df -h "$path" | tail -n 1)

# total_space=$(df -h $path | awk 'NR==2 {print $2}')

remaining_space=$(echo "$space_info" | awk '{print $4}')
total_space=$(echo "$space_info" | awk '{print $2}')

if [[ "$remaining_space" < "50G" ]]; then
    echo "! 路径$path 剩余空间: $remaining_space /$total_space (此提醒在剩余空间<50G 时出现)"
# else
    # echo "$path 剩余空间为：$remaining_space"
fi