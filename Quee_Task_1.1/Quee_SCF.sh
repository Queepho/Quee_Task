#!/bin/sh

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
if [ ! "$(command -v sbatch)" ]
then
	echo "<Warning> 前置软件包Slurm未找到" >> ./Quee_OUTPUT/Quee.info
	echo "前置软件包Slurm未找到，终止SCF程序"
	exit 2
else
	echo "<Info> 前置软件包Slurm已检验安装" >> ./Quee_OUTPUT/Quee.info
fi

#-------------------预处理步骤--------------------
#创建SCF文件夹
if [ ! -d "./SCF" ]
then
	mkdir ./SCF
	echo -e "————————————————————SCF———————————————————\n<Info> SCF文件夹已自动创建" >> ./Quee_OUTPUT/Quee.info
	if [ ! -d "./SR" ]
	then
		echo "<Warning> SR文件夹未索取，SCF程序将终止" >> ./Quee_OUTPUT/Quee.info
		rm -r ./SCF
		exit 2
	fi
else
	echo -e "————————————————————SCF———————————————————\n<Warning> SCF文件夹已存在，将自动绑定路径" >> ./Quee_OUTPUT/Quee.info
fi

#检索SR文件夹
if [ ! -d "./SR" ]
then
	echo "<Warning> SR文件夹未索取，SCF程序将终止" >> ./Quee_OUTPUT/Quee.info
	exit 2
else
	echo "<Info> SR文件已检索" >> ./Quee_OUTPUT/Quee.info
fi

#判断SR是否已输出完整并转移文件
if [ -f "./SR/CONTCAR" ]
then
	cp ./SR/CONTCAR ./SCF/POSCAR
	echo "<Info> SR中CONTCAR已获取，转移到SCF中作为POSCAR" >> ./Quee_OUTPUT/Quee.info
	if [ -f "./SR/INCAR" ]
	then
		cp ./SR/INCAR ./SCF/INCAR
		echo "<Info> 复制SR中INCAR文件，转移到SCF文件夹" >> ./Quee_OUTPUT/Quee.info
		if [ -f "./SR/POTCAR" ]
		then
			cp ./SR/POTCAR ./SCF/POTCAR
			echo "<Info> 复制SR中POTCAR文件，转移到SCF文件夹" >> ./Quee_OUTPUT/Quee.info
			if [ -f "./SR/KPOINTS" ]
			then
				cp ./SR/KPOINTS ./SCF/KPOINTS
				echo "<Info> 复制SR中KPOINTS文件，转移到SCF文件夹" >> ./Quee_OUTPUT/Quee.info
				echo "<Info> SR输出完整，所需文件已全部转移完毕" >> ./Quee_OUTPUT/Quee.info
			else
				echo "<Warning> SR中未找到KPOINTS文件，终止SCF程序" >> ./Quee_OUTPUT/Quee.info
				echo "SR中未找到KPOINTS文件，终止SCF程序"
				exit 2
			fi
		else
			echo "<Warning> SR中未找到POTCAR文件，终止SCF程序" >> ./Quee_OUTPUT/Quee.info
			echo "SR中未找到POTCAR文件，终止SCF程序"
			exit 2
		fi
	else
		echo "<Warning> SR中未找到INCAR文件，终止SCF程序" >> ./Quee_OUTPUT/Quee.info
		echo "SR中未找到INCAR文件，终止SCF程序"
		exit 2
	fi
else
	echo "<Warning> SR中未找到CONTCAR文件,终止SCF程序" >> ./Quee_OUTPUT/Quee.info
	echo "SR中未找到CONTCAR文件,终止SCF程序"
	exit 2
fi

#进入SCF文件夹操作
cd ./SCF
#--------------------更改INCAR参数-------------------
#删除SR_NSW
sed -i '30,$d' ./INCAR

#-----------------
#添加NCORE(默认为SR对应值）
CORE=$1
if [ ! $CORE ]
then
	echo "SCF:你未输入参数,将自动使用初始化程序"
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
	echo "SCF:用户自定义CORE = $CORE"
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
partition=$4
Path_vasp=$5
echo "#!/bin/bash
echo '<Info> SCF程序开始运行' >> ../Quee_OUTPUT/Quee.info
mpirun -np $CORE $Path_vasp
echo '<Info> SCF程序运行完毕' >> ../Quee_OUTPUT/Quee.info" > ./SCF.sh
chmod +x ./SCF.sh
./SCF.sh
rm ./SCF.sh

#---------------------复原索取目录--------------------
cd ../

#--------------------检验运行后结果-------------------
#检验是否收敛
if [ -f "./SCF/OUTCAR" ]
then
	echo "<Info> SCF文件OUTCAR已检索" >> ./Quee_OUTPUT/Quee.info

	IsFit=$(grep -w 'EDIFF is reached' ./SCF/OUTCAR)
	if [ -z "$IsFit" ]
	then
		echo "<Warning> SCF未收敛"
		echo "<Warning> SCF未收敛，请自行检查" >> ./Quee_OUTPUT/Quee.info
	else
		echo "<Info> SCF已收敛" >> ./Quee_OUTPUT/Quee.info
	fi
else
	echo "<Warning> SCF文件中未索取OUTCAR" >> ./Quee_OUTPUT/Quee.info
	exit 2
fi
