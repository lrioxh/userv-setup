#!/bin/bash

# 定义日志文件路径
LOG_FILE="/data/userv-setup/gpu_occu.log"

# 获取当前时间
current_time=$(date '+%Y-%m-%d %H:%M:%S')

# 获取 GPU 占用百分比
gpu_utilization=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{sum+=$1} END {print sum/NR}')

# 初始化结果字符串，包含时间和 GPU 占用百分比
result="$current_time,${gpu_utilization}%"

# 使用 nvidia-smi 命令获取显存占用超过 1000MB 的进程信息
process_info=$(nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader,nounits | awk '$2 > 1000 {print $1, $2}')

# 检查是否有符合条件的进程
if [[ -n "$process_info" ]]; then
  # 遍历每个符合条件的进程
  while IFS= read -r line; do
    # 提取 PID 和 显存占用
    pid=$(echo $line | awk '{print $1}' | sed 's/,//g')
    memory=$(echo $line | awk '{print $2}')

    # 获取用户和命令信息，如果为空则填充为"unknown"
    user=$(ps -o user= -p $pid 2>/dev/null)
    user=${user:-unknown}
    # echo "$(ps -o user= -p $pid)"
    command=$(ps -o cmd= -p $pid 2>/dev/null)
    command=${command:-unknown}

    # 将信息追加到结果字符串
    result="$result,$pid,$user,\"$command\",${memory}MB"
  done <<< "$process_info"
else
  result="$result,404"
fi

# 将结果写入日志文件
echo "$result" >> "$LOG_FILE"