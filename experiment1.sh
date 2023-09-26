#!/bin.bash

show_help(){
	echo "${line} 参数说明:（带*的为必填）
	[option]		[说明]
	-h      <null>		帮助
	-t*     <任务类型>	1: 打包任务2的/var/www;	2: 登录fpt操作文件; 如果选择1，后面参数不需要写
	-a*     <ftp地址>	ftp地址，i.g., localhost
	-p      <端口>		默认21 
	-u*     <user>		ftp用户名
	-w*     <pswd> 		ftp密码
	-o      <操作>		操作：upload, download, delete三选一; 默认为upload
	-s*     <filepath>	待操作的文件位置 e.g., /home/littsk/desktop/1.txt
	-d      <目标路径>	新文件所在文件夹的位置 e.g., /home/littsk/testdir", 默认为./
}
show_params(){
	echo "${line} 您输入的参数为: "
	echo "task		$task"
	echo "address		$address"
	echo "port		$port"
	echo "user		$user"
	echo "pass		$pass"
	echo "operation	$operation"
	echo "src_path	$src_path"
	echo "dst_path	$dst_path"
}

line="================"
# 设置变量
need_help=""
task=""
address=""
port=21
user=""
pass=""
operation="upload"
src_path=""
filename=""
dst_path="."
dirpath=""

## 接收参数
while getopts "t:ha:p:u:w:o:s:d:" opt; do
	case $opt in
		t) task=$OPTARG ;;
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

# show_params

## -h 帮助
# need_help非空则输入help
if [ $need_help ]; then
	show_help
	exit 0
fi

# 判断-t参数
if [[ $task -ne 1 && $task -ne 2 || -z $task ]]; then
	# echo "${line} -t参数错误，请选择1或者2"
    show_help
	exit 1
fi


## 任务1 打包文件
if [ $task -eq 1 ]; then
cd /var
echo "${line} 以下文件将被打包"
sudo -S tar -cvf backup.tar www << EOF
1

EOF
echo "${line} 打包完毕，压缩包信息为："
ls -l /var/backup.tar
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



# 
dirpath=$(dirname $src_path)
filename=$(basename $src_path)

echo "${line} 开始${operation}"

# # 开始操作

if [ $operation == "upload" ]; then
ftp -n -v $address $port << EOF
user $user $pass
lcd $dirpath
cd $dst_path
put $filename
quit
EOF
fi

if [ $operation == "download" ]; then
ftp -n -v $address $port << EOF
user $user $pass
cd $dirpath
lcd $dst_path
get $filename
EOF
fi

if [ $operation == "delete" ]; then
ftp -n -v $address $port << EOF
user $user $pass
cd $dirpath
delete $filename
EOF
fi

# # 如果没有出错，则输出传输成功的信息
echo "${line} 执行结束"
