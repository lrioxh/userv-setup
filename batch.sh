#!/bin/bash

# 获取输入参数
target=$1
# shift
# message="$*"

# 函数：用户批处理
# 参数：$1 用户名
function batch_user() {
    local user="$1"
    # local message="$2"
    user_home=$(eval echo ~$user)

    cp ./profile $user_home/.profile
    chown "$user:" $user_home/.profile

    echo "用户 $user 已完成"
}

# 检查目标是用户还是组
if id -u "$target" >/dev/null 2>&1; then
    # 是用户
    batch_user "$target"
elif getent group "$target" >/dev/null 2>&1; then
    # 是组
    for user in $(getent group "$target" | awk -F: '{print $4}' | tr ',' ' '); do
        batch_user "$user"
    done
else
    echo "用户或组 $target 不存在"
    exit 1
fi