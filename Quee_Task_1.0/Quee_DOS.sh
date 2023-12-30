#!/bin/sh

Path_Quee=$3

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
if [ ! "$(command -v vaspkit)" ]
then
	echo "<Warning> 前置软件包Vaspkit未找到" >> ./Quee_OUTPUT/Quee.info
	echo "前置软件包Vaspkit未找到，终止DOS程序"
	exit 2
else
	echo "<Info> 前置软件包Vaspkit已检验安装" >> ./Quee_OUTPUT/Quee.info
fi

if [ ! "$(command -v slurmd)" ]
then
	echo "<Warning> 前置软件包Slurm未找到" >> ./Quee_OUTPUT/Quee.info
	echo "前置软件包Slurm未找到，终止DOS程序"
	exit 2
else
	echo "<Info> 前置软件包Slurm已检验安装" >> ./Quee_OUTPUT/Quee.info
fi

#-------------------预处理步骤--------------------
#创建DOS文件夹
if [ ! -d "./DOS" ]
then
	mkdir ./DOS
	echo "————————————————————DOS———————————————————\n<Info> DOS文件夹已自动创建" >> ./Quee_OUTPUT/Quee.info
	if [ ! -d "./SCF" ]
	then
		echo "<Warning> SCF文件夹未索取，DOS程序将终止" >> ./Quee_OUTPUT/Quee.info
		rm -r ./DOS
		exit 2
	fi
else
	echo "————————————————————DOS———————————————————\n<Warning> DOS文件夹已存在，将自动绑定路径" >> ./Quee_OUTPUT/Quee.info
fi

#检索SR文件夹
if [ ! -d "./SR" ]
then
	echo "<Warning> SR文件夹未索取，DOS程序将终止" >> ./Quee_OUTPUT/Quee.info
	exit 2
else
	echo "<Info> SR文件已检索" >> ./Quee_OUTPUT/Quee.info
fi

#判断SR是否已输出完整并转移文件

if [ -f "./SR/OUTCAR" ]
then
	echo "<Info> SR文件OUTCAR已检索" >> ./Quee_OUTPUT/Quee.info

	IsFit=$(grep -w 'reached required accuracy - stopping structural energy minimisation' ./SR/OUTCAR)
	if [ -z "$IsFit" ]
	then
		echo "<Warning> SR未收敛"
		echo "<Warning> SR未收敛，请自行检查" >> ./Quee_OUTPUT/Quee.info
	else
		echo "<Info> SR已收敛" >> ./Quee_OUTPUT/Quee.info
	fi
else
	echo "<Warning> SR文件中未索取OUTCAR，DOS程序将终止" >> ./Quee_OUTPUT/Quee.info
	exit 2
fi

if [ -f "./SR/CONTCAR" ]
then
	cp ./SR/CONTCAR ./DOS/POSCAR
	echo "<Info> SR中CONTCAR已获取，转移到DOS中作为POSCAR" >> ./Quee_OUTPUT/Quee.info
	if [ -f "./SR/INCAR" ]
	then
		cp ./SR/INCAR ./DOS/INCAR
		echo "<Info> 复制SR中INCAR文件，转移到DOS文件夹" >> ./Quee_OUTPUT/Quee.info
		if [ -f "./SR/POTCAR" ]
		then
			cp ./SR/POTCAR ./DOS/POTCAR
			echo "<Info> 复制SR中POTCAR文件，转移到DOS文件夹" >> ./Quee_OUTPUT/Quee.info
		else
			echo "<Warning> SR中未找到POTCAR文件，终止DOS程序" >> ./Quee_OUTPUT/Quee.info
			echo "SCF中未找到POTCAR文件，终止DOS程序"
			exit 2
		fi
	else
		echo "<Warning> SR中未找到INCAR文件，终止DOS程序" >> ./Quee_OUTPUT/Quee.info
		echo "SCF中未找到INCAR文件，终止DOS程序"
		exit 2
	fi
else
	echo "<Warning> SR中未找到POSCAR文件,终止DOS程序" >> ./Quee_OUTPUT/Quee.info
	echo "SCF中未找到POSCAR文件,终止DOS程序"
	exit 2
fi

#进入DOS文件夹操作
cd ./DOS
#----------------通过vaspkit获取初始文件--------------
#获得KPOINTS文件 mesh=0.01
echo "102\n2\n0.01" | vaspkit >> ../Quee_OUTPUT/Quee.out
echo "<Info> 生成KPOINTS时设置mesh为 0.01" >> ../Quee_OUTPUT/Quee.info

#--------------------更改INCAR参数-------------------
#删除SR_NSW部分
sed -i '30,$d' INCAR

#-----------------
#修改ISMEAR = -5
sed -i '23s/0/-5/1' INCAR

#-----------------
#添加LORBIT =  11
sed -i "2a\LORBIT = 11" INCAR

#-----------------
#添加NEDOS = 3000
sed -i "3a\NEDOS = 3000" INCAR

#-----------------
#添加NCORE(默认为SR对应值）
CORE=$1
if [ ! $CORE ]
then
	echo "DOS:你未输入参数,将自动使用初始化程序"
	echo "<Info> 用户未自定义CORE，自动设置CORE = 4，NCORE = 2" >> ../Quee_OUTPUT/Quee.info
	TEMP_NCORE=$(grep NCORE INCAR)
	if [ -z "$TEMP_NCORE" ]
	then
		sed -i "1a\NCORE = 2" INCAR
		CORE=4
	else
		sed -i '2d' INCAR
		sed -i "1a\NCORE = 2" INCAR
	fi
	CORE=4
else
	echo "DOS:用户自定义CORE = $CORE"
	temp=$(awk -v x=$CORE 'BEGIN{print sqrt(x)}')
	NCORE=$(echo $temp | sed "s/\..*//g")
	echo "<Info> 用户选择自定义NCORE为 $NCORE" >> ../Quee_OUTPUT/Quee.info
	TEMP_NCORE=$(grep NCORE INCAR)
	if [ -z "$TEMP_NCORE" ]
	then
		sed -i "1a\NCORE = $NCORE" INCAR
		CORE=4
	else
		sed -i '2d' INCAR
		sed -i "1a\NCORE = $NCORE" INCAR
	fi
fi

#-----------------创造并运行SBATCH文件----------------
#复制LDOS.py文件
cp ${Path_Quee}/LDOS.py ./LDOS.py

echo "#!/bin/bash
echo '<Info> DOS程序开始运行' >> ../Quee_OUTPUT/Quee.info
srun -p phy -c $CORE -oversubscribe --ntasks=1 mpirun -np $CORE vasp_std
echo '<Info> DOS程序运行完毕' >> ../Quee_OUTPUT/Quee.info
rm ./versubscribe" > ./DOS.sh

#-----------------
#输出*_LDOS.png

DOS_dpi=$(grep "DOS_dpi" ${Path_Quee}/Quee.config | awk -F '= ' '{print $2}')
DOS_x_min=$(grep "DOS_x_min" ${Path_Quee}/Quee.config | awk -F '= -' '{print $2}')
DOS_x_max=$(grep "DOS_x_max" ${Path_Quee}/Quee.config | awk -F '= ' '{print $2}')
DOS_y_min=$(grep "DOS_y_min" ${Path_Quee}/Quee.config | awk -F '= -' '{print $2}')
	if [ ! -n "$DOS_y_min" ]
	then
		DOS_y_min=$(grep "DOS_y_min" ${Path_Quee}/Quee.config | awk -F '= ' '{print $2}')
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
DOS_y_max=$(grep "DOS_y_max" ${Path_Quee}/Quee.config | awk -F '= ' '{print $2}')

echo "#!/bin/bash
echo '<Info> *_LDOS.png开始输出' >> ../Quee_OUTPUT/Quee.info
python3.10 ./LDOS.py $DOS_dpi -$DOS_x_min $DOS_x_max $DOS_y_min $DOS_y_max
echo '<Info> *_LDOS.png输出完毕' >> ../Quee_OUTPUT/Quee.info" > ./LDOS.sh

chmod +x ./DOS.sh
chmod +x ./LDOS.sh
./DOS.sh
./LDOS.sh | cat > ../Quee_OUTPUT/Quee_LDOS.info
rm ./DOS.sh
rm ./LDOS.sh
rm ./LDOS.py

NAME=$(head -n 1 ../Quee_OUTPUT/Quee_LDOS.info)

#-------------------将NAME_LDOS.png上传ftp------------------
#ftp创建TASK文件夹并上传NAME_LDOS.png
# TASK=$2
# echo "<Info> 开始FTP连接服务器上传${NAME}_LDOS.png" >> ../Quee_OUTPUT/Quee.info
# ftp -n <<!
# open queepho.cc 30021
# user Queepho 123
# binary
# hash
# cd /Users/BAND
# mkdir ./$TASK
# lcd ./
# prompt
# put ./${NAME}_LDOS.png ./$TASK/${TASK}_LDOS.png
# close
# bye
# !
# echo '<Info> 上传完毕' >> ../Quee_OUTPUT/Quee.info

#---------------------复原索取目录--------------------
cd ../