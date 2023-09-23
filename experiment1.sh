#!/bin.bash

show_help(){
	echo "${line} 参数说明:
	[option]		[说明]
	-h 	<null>		帮助
	-a 	<ftp地址>	ftp地址，i.g., localhost
	-p 	<端口>		默认21 
	-u 	<user>		ftp用户名
	-w 	<pswd> 		ftp密码
	-o 	<操作>		操作：upload, download, delete三选一 
	-s 	<filepath>	源文件位置 e.g., /home/littsk/testdir/1.txt
	-f	<filename>
	-d 	<目标路径>	目的文件所在文件夹的位置 e.g., /home/littsk/testdir
	-t 	<任务类型>	1: 打包任务2的/var/www;	2: 登录fpt并上传文件到指定目录"
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
operation=""
src_path=""
filename=""
dst_path=""

## 接收参数
while getopts "t:ha:p:u:w:o:s:f:d:" opt; do
	case $opt in
		t) task=$OPTARG ;;
		h) need_help="true" ;;
		a) address=$OPTARG ;; 
		p) port=$OPTARG ;;
		u) user=$OPTARG ;;
		w) pass=$OPTARG ;;
		o) operation=$OPTARG ;;
		s) src_path=$OPTARG ;;
		f) filename=$OPTARG ;;
		d) dst_path=$OPTARG ;;
		?) echo "unknown param" 
			exit 1;;
	esac
done

show_params

## -h 帮助
# need_help非空则输入help
if [ $need_help ]; then
	show_help
	exit 0
fi
# 判断-t参数
if [ $task -ne 1 ] && [ $task -ne 2 ]; then
	echo "${line} -t参数错误，请输出1或者2"
	exit 2
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
if [ -z $address ] || [ -z $user ] || [ -z $pass ] || [ -z $operation ] || [ -z $src_path ] || [ -z $filename ] || [ -z $dst_path ]; then
    echo "${line} 缺少必要的参数，请按照格式输入参数"
	show_help
    exit 3
fi

# 判断操作类型是否有效
if [ $operation != "upload" ] && [ $operation != "download" ] && [ $operation != "delete" ]; then
    echo "${line} ftp操作类型错误，请输入 upload, download 或 delete"
    exit 4
fi

echo "${line} 开始${operation}"

# 开始操作
ftp -n -v $address $port << EOF
user $user $pass

# 如果是上传操作，切换到本地源文件路径和远程目标文件路径，并使用 mput 命令上传多个文件或文件夹
if [ $operation == "upload" ]; then
	lcd $src_path
    put $filename
fi

# # 如果是下载操作，切换到远程源文件路径和本地目标文件路径，并使用 mget 命令下载多个文件或文件夹
# if [ $operation == "download" ]; then
#     cd $src_path
#     lcd $dst_path
#     mget *
# fi

# # 如果是删除操作，切换到远程源文件路径，并使用 mdelete 命令删除多个文件或文件夹
# if [ $operation == "delete" ]; then
#     cd $src_path
#     mdelete *
# fi

quit
EOF

# 判断 ftp 命令的返回值是否为 0，如果不为 0，则表示出现错误，输出错误信息并退出脚本
if [ $? -ne 0 ]; then
    echo "ftp 命令执行失败，请检查参数和网络连接"
    exit 5
fi

# 如果没有出错，则输出传输成功的信息，并显示传输的文件列表和大小
echo "${line} ftp 命令执行成功，已完成 ${operation} 操作"
ls -l ${src_path} | awk '{print $5, $9}'


