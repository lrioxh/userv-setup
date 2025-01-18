#!/bin/bash

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo "此脚本必须以root用户身份运行" 
   exit 1
fi

# 检查参数是否传入
if [ -z "$1" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

# 定义变量
username=$1
userdir="/data/sda/"
newdir="/moredata/users/"
homedir="/home/"

# 检查源目录是否存在
if [ ! -d "${userdir}${username}" ]; then
  echo "Error: Source directory ${userdir}${username} does not exist."
  exit 1
fi

# 创建目标目录（如果不存在）
mkdir -p "${newdir}${username}"

# 复制用户数据到新目录
cp -r "${userdir}${username}" "${newdir}"

# 修改目标目录的权限和所属者
chown -R "${username}" "${newdir}${username}"

rm "${homedir}${username}"
# 创建符号链接到新目录
ln -s "${newdir}${username}" "${homedir}${username}"

echo "User $username data successfully copied to ${newdir}${username}."