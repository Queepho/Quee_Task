#!/bin/sh

CORE=$1
#--------------------检验前置----------------------
#创建信息输出文件夹
if [ ! -d "./Quee_OUTPUT" ]
then
	mkdir ./Quee_OUTPUT
	echo "══════════════════════════════════════════" >> ./Quee_OUTPUT/Quee.info
	echo "<Info> Quee输出文件夹已自动创建" >> ./Quee_OUTPUT/Quee.info
else
	echo "══════════════════════════════════════════" >> ./Quee_OUTPUT/Quee.info
	echo "<Info> Quee输出文件夹已存在，将自动绑定路径" >> ./Quee_OUTPUT/Quee.info
fi

#-----------------
#检验前置软件包是否安装

#none

#-------------------预处理步骤--------------------
#检索BS文件夹
if [ ! -d "./BS" ]
then
	echo "——————————————————BS_PNG——————————————————\n<Warning> BS文件夹不存在，BS输出程序将终止" >> ./Quee_OUTPUT/Quee.info
	exit 2
else
	echo "——————————————————BS_PNG——————————————————\n<Info> BS文件夹已索取，将自动绑定路径" >> ./Quee_OUTPUT/Quee.info
fi

#判断BS是否已输出完整并转移文件

if [ -f "./BS/OUTCAR" ]
then
	echo "<Info> BS文件OUTCAR已检索" >> ./Quee_OUTPUT/Quee.info

	IsFit=$(grep -w 'EDIFF is reached' ./BS/OUTCAR)
	if [ -z "$IsFit" ]
	then
		echo "<Warning> BS未收敛"
		echo "<Warning> BS未收敛，请自行检查" >> ./Quee_OUTPUT/Quee.info
	else
		echo "<Info> BS已收敛" >> ./Quee_OUTPUT/Quee.info
	fi
else
	echo "<Warning> BS文件中未索取OUTCAR，BS输出程序将终止" >> ./Quee_OUTPUT/Quee.info
	exit 2
fi

#进入BS文件夹操作
cd ./BS

#-----------------创造并运行SBATCH文件----------------
#复制BS.py文件
cp ~/work/Quee/BS.py ./BS.py

#-----------------
#输出BS.png

#获得.config作图信息
BS_dpi=$(grep "BS_dpi" ~/work/Quee/Quee.config | awk -F '= ' '{print $2}')

echo "
echo '<Info> BS.png开始输出' >> ../Quee_OUTPUT/Quee.info
python3.10 ./BS.py $BS_dpi
echo '<Info> BS.png输出完毕' >> ../Quee_OUTPUT/Quee.info
rm ./versubscribe" > ./BS.sh

chmod +x ./BS.sh
./BS.sh
rm ./BS.sh
rm ./BS.py

#-------------------将BS.png上传ftp------------------
#ftp创建TASK文件夹并上传BS.png
TASK=$2
echo '<Info> 开始FTP连接服务器上传BS.png' >> ../Quee_OUTPUT/Quee.info
ftp -n <<!
open queepho.cc 30021
user Queepho 123
binary
hash
cd /Users/BAND
mkdir ./$TASK
lcd ./
prompt
put ./BS.png ./$TASK/${TASK}_BS.png
close
bye
!
echo '<Info> 上传完毕' >> ../Quee_OUTPUT/Quee.info

#---------------------复原索取目录--------------------
cd ../

