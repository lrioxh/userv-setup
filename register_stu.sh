#!/bin/bash

# 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    echo "此脚本必须以 root 用户身份运行"
    exit 1
fi

# 检查是否提供了用户名、ID 和密码参数
if [ "$#" -ne 3 ]; then
    echo "使用方法: $0 用户名 用户ID 密码"
    exit 1
fi

# 获取参数
username=$1
userid=$2
passwd=$3
userdir="/data/sda/"

# 检查用户名是否已存在
if id "$username" &>/dev/null; then
    echo "用户 $username 已存在。"
    exit 1
fi

# 创建用户数据目录
mkdir -p "${userdir}${username}"
if [ $? -ne 0 ]; then
    echo "创建用户目录 ${userdir}${username} 失败。"
    exit 1
fi

# 创建符号链接到 /home
ln -s "${userdir}${username}" "/home/${username}"
if [ $? -ne 0 ]; then
    echo "创建符号链接 /home/${username} 失败。"
    exit 1
fi

# 创建用户并设置密码
useradd -d "/home/${username}" -g stu -G stu,sudo -u "$userid" -s /bin/bash "$username"
if [ $? -ne 0 ]; then
    echo "用户 $username 创建失败。"
    exit 1
fi

echo "$username:$passwd" | chpasswd
if [ $? -ne 0 ]; then
    echo "设置密码失败。"
    exit 1
fi

# 初始化用户配置文件
if [ -f "./bashrc" ]; then
    cp ./bashrc "/home/${username}/.bashrc"
fi

if [ -f "./profile" ]; then
    cp ./profile "/home/${username}/.profile"
fi

# 修改目录权限
chown -R "${username}" "${userdir}${username}"
if [ $? -ne 0 ]; then
    echo "更改目录权限失败。"
    exit 1
fi

# 发送离线通知
if [ -x "./send_notice_offline.sh" ]; then
    bash ./send_notice_offline.sh "$username" "NOTICE: conda & cuda have already been installed, please check via 'conda info; nvcc -V'."
else
    echo "send_notice_offline.sh 脚本未找到或不可执行。"
fi

# 显示创建结果
if id "$username" &>/dev/null; then
    echo "用户 $username 创建成功。"
    echo "新用户首次登录强制修改密码"
    passwd -e "$username"
else
    echo "用户 $username 创建失败。"
    exit 1
fi
