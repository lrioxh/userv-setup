#!/bin/bash

# 检查输入参数
if [ "$#" -lt 2 ]; then
    echo "使用方法: $0 用户/组 消息"
    echo "例如: $0 user1 '这是一个离线通知消息。'"
    exit 1
fi

# 获取输入参数
target=$1
shift
message="$*"

# 函数：发送消息给指定用户
# 参数：$1 用户名，$2 消息内容
function send_message_to_user() {
    local user="$1"
    local message="$2"
    user_home=$(eval echo ~$user)
    if [ -f $user_home/.notified ];then
        rm -f $user_home/.notified
    fi    
    notify_script="$user_home/.profile_notify.sh"
    sudo echo -e "#!/bin/bash\nif [ ! -f ~/.notified ]; then\necho \"$message\"\ntouch ~/.notified\nfi" > "$notify_script"
    sudo chown "$user": "$notify_script"
    sudo chmod +x "$notify_script"
    echo "source $notify_script" | sudo tee -a "$user_home/.profile" > /dev/null
    echo "登录通知已添加到用户 $user 的 .profile"
}

# 检查目标是用户还是组
if id -u "$target" >/dev/null 2>&1; then
    # 是用户
    send_message_to_user "$target" "$message"
elif getent group "$target" >/dev/null 2>&1; then
    # 是组
    for user in $(getent group "$target" | awk -F: '{print $4}' | tr ',' ' '); do
        send_message_to_user "$user" "$message"
    done
else
    echo "用户或组 $target 不存在"
    exit 1
fi