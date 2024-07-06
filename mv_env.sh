#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "使用方法: $0 原环境路径 环境名"
    echo "例如: $0 /data/anaconda3/envs/ envexp"
    exit 1
fi

name=$1
env_path=$2
old_path=${env_path}${name}

mv $old_path/* ${HOME}/.conda/envs/${name}_cache

# conda activate ${name}_cache
# conda env export > ${name}.yml

# conda deactivate    
# conda env create -f ${name}.yml
conda activate base
conda pack -n ${name}_cache -o $name.tar.gz

mkdir -p ${HOME}/.conda/envs/${name}
tar -xzf $name.tar.gz -C ${HOME}/.conda/envs/${name}
source ${HOME}/.conda/envs/${name}/bin/activate
# conda install conda-pack -y
conda-unpack
# 指定要遍历的目录
target_directory=${HOME}/.conda/envs/${name}/bin

# 遍历目录下的所有文件并进行替换
new_path="${HOME}/.conda/envs/$name"
find "$target_directory" -type f -exec sed -i "s|$old_path|$new_path|g" {} +

echo "请检查环境无误后运行: conda remove -n ${name}_cache --all"
