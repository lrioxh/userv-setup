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

# 检查目标是用户还是组
if id -u "$target" >/dev/null 2>&1; then
    # 是用户
    user_home=$(eval echo ~$target)
    notify_script="$user_home/.profile_notify.sh"
    echo -e "#!/bin/bash\nif [ ! -f ~/.notified ]; then\necho \"$message\"\ntouch ~/.notified\nfi" > "$notify_script"
    sudo chown "$target":"$target" "$notify_script"
    sudo chmod +x "$notify_script"
    echo "source $notify_script" | sudo tee -a "$user_home/.profile" > /dev/null
    echo "登录通知已添加到用户 $target 的 .profile"
elif getent group "$target" >/dev/null 2>&1; then
    # 是组
    for user in $(getent group "$target" | awk -F: '{print $4}' | tr ',' ' '); do
        user_home=$(eval echo ~$user)
        notify_script="$user_home/.profile_notify.sh"
        echo -e "#!/bin/bash\nif [ ! -f ~/.notified ]; then\necho \"$message\"\ntouch ~/.notified\nfi" > "$notify_script"
        sudo chown "$user":"$user" "$notify_script"
        sudo chmod +x "$notify_script"
        echo "source $notify_script" | sudo tee -a "$user_home/.profile" > /dev/null
        echo "登录通知已添加到用户 $user 的 .profile"
    done
else
    echo "用户或组 $target 不存在"
    exit 1
fi