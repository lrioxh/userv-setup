#!/bin/bash

# 函数：检查用户是否在线
# 参数：$1 用户名
function is_user_online() {
    local user="$1"
    who | grep -q "\<$user\>"
}

# 函数：发送消息给指定用户
# 参数：$1 用户名，$2 消息内容
function send_message_to_user() {
    local user="$1"
    local message="$2"
    echo "$message" | sudo write "$user"
}

# 主程序开始
if [ "$#" -lt 2 ]; then
    echo "使用方法: $0 [-u 用户名] [-g 用户组] [-a] 消息内容"
    echo "选项:"
    echo "  -u 用户名   向指定用户名发送消息"
    echo "  -g 用户组   向指定用户组发送消息"
    echo "  -a          向所有在线用户发送消息"
    echo "例如:"
    echo "  $0 -u user1 '这是一个在线通知。'"
    echo "  $0 -g group1 '这是一个在线通知。'"
    echo "  $0 -a '这是一个在线通知。'"
    exit 1
fi

target_user=""
target_group=""
message=""

# 解析参数
while getopts ":u:g:a" opt; do
    case $opt in
        u)
            target_user="$OPTARG"
            ;;
        g)
            target_group="$OPTARG"
            ;;
        a)
            send_to_all=true
            ;;
        \?)
            echo "无效的选项: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "选项 -$OPTARG 需要一个参数。" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))
message="$@"

# 检查参数和消息内容是否为空
if [[ -z "$message" ]]; then
    echo "消息内容不能为空。"
    exit 1
fi

# 发送消息给所有在线用户
if [ "$send_to_all" = true ]; then
    online_users=$(who | cut -d' ' -f1 | sort -u)
    for user in $online_users; do
        send_message_to_user "$user" "$message"
        echo "已向用户 $user 发送消息：$message"
    done
fi

# 发送消息给指定用户
if [[ -n "$target_user" ]]; then
    if ! id "$target_user" &>/dev/null; then
        echo "错误：用户 $target_user 不存在。"
        exit 1
    fi
    if is_user_online "$target_user"; then
        send_message_to_user "$target_user" "$message"
        echo "已向用户 $target_user 发送消息：$message"
    else
        echo "用户 $target_user 当前不在线，无法发送消息。"
    fi
fi

# 发送消息给指定用户组中的所有用户
if [[ -n "$target_group" ]]; then
    group_members=$(getent group "$target_group" | cut -d: -f4| tr ',' ' ')
    if [[ -z "$group_members" ]]; then
        echo "错误：用户组 $target_group 不存在或没有成员。"
        exit 1
    fi
    # IFS=',' read -r -a members_array <<< "$group_members"
    for user in $group_members; do
        user=$(echo "$user" | xargs)  # 去除用户名前后的空格
        if is_user_online "$user"; then
            send_message_to_user "$user" "$message"
            echo "已向用户 $user 发送消息：$message"
        else
            echo "用户 $user 当前不在线，无法发送消息。"
        fi
    done
fi
