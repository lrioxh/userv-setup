#!/bin/bash

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo "此脚本必须以root用户身份运行" 
   exit 1
fi

# 检查是否提供了用户名和密码参数
if [ "$#" -ne 2 ]; then
    echo "使用方法: $0 用户名 密码"
    exit 1
fi

username=$1
passwd=$2

# 检查用户名是否已存在
if id "$username" &>/dev/null; then
    echo "用户 $username 已存在。"
    exit 1
fi

# 创建用户并设置密码
mkdir -p /data/sda/$username
ln -s /data/sda/$username /home/$username
useradd -d /home/$username -g stu -G sudo -u $passwd -s /bin/bash "$username"
echo "$username:$passwd" | chpasswd
rm /home/$username/$username
chown -R $username /data/sda/$username
cp ./bashrc /home/$username/.bashrc

# 显示创建结果
if id "$username" &>/dev/null; then
    echo "用户 $username 创建成功。"
else
    echo "用户 $username 创建失败。"
fi
