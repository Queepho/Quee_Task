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
#检索DOS文件夹
if [ ! -d "./DOS" ]
then
	echo "—————————————————LDOS_PNG—————————————————\n<Warning> DOS文件夹不存在，LDOS输出程序将终止" >> ./Quee_OUTPUT/Quee.info
	exit 2
else
	echo "—————————————————LDOS_PNG—————————————————\n<Info> DOS文件夹已索取，将自动绑定路径" >> ./Quee_OUTPUT/Quee.info
fi

#判断DOS是否已输出完整并转移文件

if [ -f "./DOS/OUTCAR" ]
then
	echo "<Info> DOS文件OUTCAR已检索" >> ./Quee_OUTPUT/Quee.info

	IsFit=$(grep -w 'EDIFF is reached' ./DOS/OUTCAR)
	if [ -z "$IsFit" ]
	then
		echo "<Warning> DOS未收敛"
		echo "<Warning> DOS未收敛，请自行检查" >> ./Quee_OUTPUT/Quee.info
	else
		echo "<Info> DOS已收敛" >> ./Quee_OUTPUT/Quee.info
	fi
else
	echo "<Warning> DOS文件中未索取OUTCAR，LDOS输出程序将终止" >> ./Quee_OUTPUT/Quee.info
	exit 2
fi

#进入DOS文件夹操作
cd ./DOS

#--------------------运行LDOS.sh文件----------------
#复制LDOS.py文件
cp ~/work/Quee/LDOS.py ./LDOS.py

#-------------
#输出*_LDOS.png

#获得.config作图信息
DOS_dpi=$(grep "DOS_dpi" ~/work/Quee/Quee.config | awk -F '= ' '{print $2}')
DOS_x_min=$(grep "DOS_x_min" ~/work/Quee/Quee.config | awk -F '= -' '{print $2}')
DOS_x_max=$(grep "DOS_x_max" ~/work/Quee/Quee.config | awk -F '= ' '{print $2}')
DOS_y_min=$(grep "DOS_y_min" ~/work/Quee/Quee.config | awk -F '= -' '{print $2}')
	if [ ! -n "$DOS_y_min" ]
	then
		DOS_y_min=$(grep "DOS_y_min" ~/work/Quee/Quee.config | awk -F '= ' '{print $2}')
		if [ ! -n $DOS_y_min ]
		then
			echo "未查找到DOS_y_min,请检查Quee.config"
			exit 2
		else
			if [ $DOS_y_min -eq 0 ]
			then
				:
			else
				echo "DOS_y_min不合法，请检查Quee.config"
				exit 2
			fi
		fi
	else
		DOS_y_min="-$DOS_y_min"
	fi
DOS_y_max=$(grep "DOS_y_max" ~/work/Quee/Quee.config | awk -F '= ' '{print $2}')

echo "#!/bin/bash
echo '<Info> *_LDOS.png开始输出' >> ../Quee_OUTPUT/Quee.info
python3.10 ./LDOS.py $DOS_dpi -$DOS_x_min $DOS_x_max $DOS_y_min $DOS_y_max
echo '<Info> *_LDOS.png输出完毕' >> ../Quee_OUTPUT/Quee.info" > ./LDOS.sh

chmod +x ./LDOS.sh

./LDOS.sh | cat > ../Quee_OUTPUT/Quee_LDOS.info

rm ./LDOS.sh
rm ./LDOS.py

NAME=$(head -n 1 ../Quee_OUTPUT/Quee_LDOS.info)

#-------------------将NAME_LDOS.png上传ftp------------------
#ftp创建TASK文件夹并上传NAME_LDOS.png
TASK=$2
echo "<Info> 开始FTP连接服务器上传${NAME}_LDOS.png" >> ../Quee_OUTPUT/Quee.info
ftp -n <<!
open queepho.cc 30021
user Queepho 123
binary
hash
cd /Users/BAND
mkdir ./$TASK
lcd ./
prompt
put ./${NAME}_LDOS.png ./$TASK/${TASK}_LDOS.png
close
bye
!
echo '<Info> 上传完毕' >> ../Quee_OUTPUT/Quee.info

#---------------------复原索取目录--------------------
cd ../







