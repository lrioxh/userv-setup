#!/bin/bash

directory=$1
threshold=$2

# 检查目录是否存在
# if [ ! -d "$directory" ]; then
#     echo "错误：指定的目录不存在"
#     exit 1
# fi

# 解析软链接路径，获取实际目录路径
resolved_directory=$(readlink -f "$directory")

# 获取目录已占用空间的大小，以 GB 为单位
usage=$(du -sh --block-size=1G "$resolved_directory" | awk '{print $1}' | sed 's/G//')

# 检查是否超出阈值
if [ "$usage" -ge "$threshold" ]; then
    echo "提醒：目录 $resolved_directory 占用空间达到 ${usage}GB > ${threshold}GB"
# else
    # echo "目录 $resolved_directory 已占用空间为 ${usage}GB，未超过阈值 ${threshold}GB"
fi
