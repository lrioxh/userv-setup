# ubuntu多人服务器配置手册
用于多用户服务器
#### 系统安装
不多赘述，预先准备启动盘 查清bios(`sudo dmidecode|less`查看主板信息) /分大一点

#### 基本配置
装git vsc等 ubuntu换源

[ubuntu | 镜像站使用帮助 | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/)

```bash
sudo apt update
sudo apt upgrade
sudo apt install gcc g++ vim
```

nv驱动，可能已预装，`nvidia-smi`查看
`apt install nvidia-driver-xxx`

ssh

``` bash
sudo apt install openssh-server
service sshd status/restart/... 
chkconfig --level 2345 sshd on #开机自启
# 配置文件 /etc/ssh/sshd_config 修改后需重启sshd
# 主要关注：
Port
PermitRootLogin
AuthorizedKeysFile
PasswordAuthentication
AllowUsers *
AllowGroups expgroup
```

挂载

```bash
sudo fdisk -l
mount /dev/xxx  #临时挂载分区
df -Th #查看分区情况
# 自动挂载
vim /etc/fstab
>/dev/xxx    /mnt/mydisk    ext4    defaults    0    2
sudo mount -a
```


*接下来可以远程操作了

关闭自动休眠
`systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target`

cuda cudnn

```bash
wget https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux.run
sudo sh cuda_11.7.1_515.65.01_linux.run [ --toolkit --override --silent]

#cudnn
sudo cp cuda/include/cudnn.h /usr/local/cuda-11.7/include
sudo cp cuda/lib64/libcudnn* /usr/local/cuda-11.7/lib64
sudo chmod a+r /usr/local/cuda-11.7/include/cudnn.h 
sudo chmod a+r /usr/local/cuda-11.7/lib64/libcudnn*
```

#### bash&用户&conda
接下来几步穿插进行，建议**先全看一遍**

账户, 注意修改个人配置模板aka本项目下的`./bashrc`, 主要为最后的conda和cuda路径, 新建账户会复制本项目模板为初始个人bash配置, 以及profile

`./bashrc`还包含以下功能：彩色终端

```
sudo groupadd stu #用户组
bash register_stu.sh
```

conda、pip、huggingface

[anaconda | 镜像站使用帮助 | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/)

[pypi | 镜像站使用帮助 | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirrors.tuna.tsinghua.edu.cn/help/pypi/)

conda安装时选择路径建议`/opt/anaconda3` 或 `/usr/local/anaconda3`
```bash
#为用户组stu安装共享的conda
chgrp -R stu /路径
chmod g+s /路径 #GID
find /opt/anaconda3 -type d -exec chmod g+s {} +
chmod -R g+w /opt/anaconda3/pkgs
setfacl -R -m d:g::rwx /opt/anaconda3/pkgs #新建文件默认有组写入权
```
修改全局conda配置，可以先conda info 查看/etc下有没有全局配置文件

没有则创建 `/etc/conda/.condarc`，写入以下内容

```bash
pkgs_dirs: #包缓存，按需更改
  - /data/anaconda3/pkgs
  - /opt/anaconda3/pkgs

channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  deepmodeling: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/
```

全局pip配置 配置文件`/etc/pip.conf`, 参考：
```bash
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
download-cache = /data/cache/pip
```

bash配置, 包括全局和个人配置，个人配置在建立账户时创建

全局bash 文件为`/etc/*bashrc`, 添加以下内容，注意更改conda路径：
```bash
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export CONDARC=/etc/conda/.condarc #for conda
export HF_HOME=/data/cache/huggingface #for huggingface
#其他全局配置...

# 附加功能：遍历并运行指定目录下的脚本
scripts_dir="/usr/local/bin/scripts"

# if [ -d "$scripts_dir" ]; then
#     for script in "$scripts_dir"/*.sh; do
#         # 检查是否确实存在脚本文件
#         if [ -f "$script" ]; then
#             # 确保脚本是可执行的
#             # chmod +x "$script"
#             # 运行脚本
#             "$script"
#         fi
#     done
# fi
```

conda环境(重难点)

环境迁移参考`./mv_env.sh`

#### 其他小功能/工具

- 个人目录容量限制警告：
  ```bash
  mkdir -p /usr/local/bin/scripts
  cp ./occu_alert.sh /usr/local/bin/scripts
  chmod +x /usr/local/bin/scripts/occu_alert.sh
  echo "${scripts_dir}/occu_alert.sh ${HOME} 100" >> /etc/*bashrc 
  ```
- `send_notice.sh` 向用户/组发送消息
- `send_notice_offline.sh` 向用户/组留言（离线消息）
- 服务器借用个人VPN代理：
  将个人`.bashrc`中proxy部分解注释, 
  ```bash
  export hostip=vpn宿主ip
  proxyon #在本终端内临时使用代理
  proxyoff #关闭代理
  ```
#### 危险操作

修改分区大小

diskgenius

```bash
fdisk -l
parted /dev/xxx
p
resizepart n
q
resize2fs
```

