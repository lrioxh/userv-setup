#!/bin/bash

## 注意：如果不清楚脚本逻辑，建议每条命令复制到命令行单独运行

# 输出脚本执行的每一条命令
set -x

if [ "$#" -ne 2 ]; then
    echo "使用方法: $0 原环境路径 环境名"
    echo "例如: $0 /data/anaconda3/envs/envname envname; 两envname可不同以重命名"
    exit 1
fi

# 获取输入参数
old_path=$1
name=$2

# 移动旧环境的所有文件到缓存目录
mv -p $old_path/* ${HOME}/.conda/envs/${name}_cache

## yaml方式
# conda activate ${name}_cache
# conda env export > ${name}.yml

# conda deactivate    
# conda env create -f ${name}.yml

## pack方式
# 打包缓存环境
conda pack -n ${name}_cache -o $name.tar.gz

# 创建新环境目录并解压打包文件
mkdir -p ${HOME}/.conda/envs/${name}
tar -xzf $name.tar.gz -C ${HOME}/.conda/envs/${name}

# 激活新环境并修复路径
source ${HOME}/.conda/envs/${name}/bin/activate
conda-unpack

# 指定要遍历的目录
target_directory=${HOME}/.conda/envs/${name}/bin
new_path="${HOME}/.conda/envs/$name"

# 遍历目录下的所有文件并进行替换
find "$target_directory" -type f -exec sed -i "s|$old_path|$new_path|g" {} +

# 提示用户检查环境
echo "请检查环境无误后运行: conda remove -n ${name}_cache --all"

# 恢复正常命令执行输出
set +x