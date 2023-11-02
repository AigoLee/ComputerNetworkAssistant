#!/bin/bash

show_help(){
	echo "${line} 参数说明:（带*的为必填）
	[option]		[说明]
	-h      <null>		帮助
	-a*     <ftp地址>	ftp地址，i.g., localhost
	-p      <端口>		默认21 
	-u*     <user>		ftp用户名
	-w*     <pswd> 		ftp密码
	-o      <操作>		操作：upload, download, delete三选一; 默认为upload
	-s*     <filepath>	源文件路径 例如/home/Tom/src/1.txt
	-d      <filepath>	目的文件路径 例如/home/Tom/dst/1.txt 如果operation=delete，则不填"
}

line="================"
# 设置变量
need_help=""
address=""
port=21
user=""
pass=""
operation="upload"
src_path=""
dst_path=""


## 接收参数
while getopts "ha:p:u:w:o:s:d:" opt; do
	case $opt in
		h) need_help="true" ;;
		a) address=$OPTARG ;; 
		p) port=$OPTARG ;;
		u) user=$OPTARG ;;
		w) pass=$OPTARG ;;
		o) operation=$OPTARG ;;
		s) src_path=$OPTARG ;;
		d) dst_path=$OPTARG ;;
		?) echo "unknown param" 
			exit 1;;
	esac
done

## -h 帮助
# need_help非空则输入help
if [ $need_help ]; then
	show_help
	exit 0
fi

## 任务2 登录ftp并传文件
# 判断必要的参数是否为空
if [[ -z $address || -z $user || -z $pass || -z $src_path ]]; then
    echo "${line} 缺少必要的参数，请按照格式输入参数"
	show_help
    exit 1
fi

# 判断操作类型是否有效
if [ $operation != "upload" ] && [ $operation != "download" ] && [ $operation != "delete" ]; then
    echo "${line} ftp操作类型错误，请输入 upload, download 或 delete"
    exit 1
fi

if [[ $operation != "delete" && -z $dst_path ]]; then 
	echo "${line} 请输入 -d参数: 目的文件路径"
    exit 1
fi

echo "${line} 开始${operation}"

# # 开始操作

if [ $operation == "upload" ]; then
ftp -n -v $address $port << EOF
user $user $pass
put $src_path $dst_path
quit
EOF
fi

if [ $operation == "download" ]; then
ftp -n -v $address $port << EOF
user $user $pass
get $src_path $dst_path
EOF
fi

if [ $operation == "delete" ]; then
ftp -n -v $address $port << EOF
user $user $pass
delete $src_path
EOF
fi

# # 如果没有出错，则输出传输成功的信息
echo "${line} 执行结束"