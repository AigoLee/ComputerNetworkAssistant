# !/bin/bash
v_a=""
v_b=""
v_c=""

## 接收命令行参数
while getopts "a:b:c:" opt; do
	case $opt in
		a) v_a=$OPTARG ;;
		b) v_b=$OPTARG ;; 
		c) v_c=$OPTARG ;;
	esac
done

echo $v_a $v_b $v_c
