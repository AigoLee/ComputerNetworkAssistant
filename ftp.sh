src_path=$1
dst_path=$2


echo $src_path
echo $dst_path

ftp -n -v localhost<<EOF
user logan 1
put $src_path $dst_path
bye
ls $dst_path
EOF
