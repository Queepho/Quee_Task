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
if [ ! "$(command -v vaspkit)" ]
then
	echo "<Warning> 前置软件包Vaspkit未找到" >> ./Quee_OUTPUT/Quee.info
	echo "前置软件包Vaspkit未找到，终止BS程序"
	exit 2
else
	echo "<Info> 前置软件包Vaspkit已检验安装" >> ./Quee_OUTPUT/Quee.info
fi

if [ ! "$(command -v slurmd)" ]
then
	echo "<Warning> 前置软件包Slurm未找到" >> ./Quee_OUTPUT/Quee.info
	echo "前置软件包Slurm未找到，终止BS程序"
	exit 2
else
	echo "<Info> 前置软件包Slurm已检验安装" >> ./Quee_OUTPUT/Quee.info
fi

#-------------------预处理步骤--------------------
#创建BS文件夹
if [ ! -d "./BS" ]
then
	mkdir ./BS
	echo "————————————————————BS————————————————————\n<Info> BS文件夹已自动创建" >> ./Quee_OUTPUT/Quee.info
	if [ ! -d "./SCF" ]
	then
		echo "<Warning> SCF文件夹未索取，BS程序将终止" >> ./Quee_OUTPUT/Quee.info
		rm -r ./BS
		exit 2
	fi
else
	echo "————————————————————BS————————————————————\n<Warning> BS文件夹已存在，将自动绑定路径" >> ./Quee_OUTPUT/Quee.info
fi

#检索SCF文件夹
if [ ! -d "./SCF" ]
then
	echo "<Warning> SCF文件夹未索取，BS程序将终止" >> ./Quee_OUTPUT/Quee.info
	exit 2
else
	echo "<Info> SCF文件已检索" >> ./Quee_OUTPUT/Quee.info
fi

#判断SCF是否已输出完整并转移文件

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
	echo "<Warning> SCF文件中未索取OUTCAR，BS程序将终止" >> ./Quee_OUTPUT/Quee.info
	exit 2
fi

if [ -f "./SCF/POSCAR" ]
then
	cp ./SCF/POSCAR ./BS/POSCAR
	echo "<Info> 复制SCF中POSCAR文件，转移到BS文件夹" >> ./Quee_OUTPUT/Quee.info
	if [ -f "./SCF/INCAR" ]
	then
		cp ./SCF/INCAR ./BS/INCAR
		echo "<Info> 复制SCF中INCAR文件，转移到BS文件夹" >> ./Quee_OUTPUT/Quee.info
		if [ -f "./SCF/POTCAR" ]
		then
			cp ./SCF/POTCAR ./BS/POTCAR
			echo "<Info> 复制SCF中POTCAR文件，转移到BS文件夹" >> ./Quee_OUTPUT/Quee.info
			if [ -f "./SCF/CHGCAR" ]
			then
				cp ./SCF/CHGCAR ./BS/CHGCAR
				echo "<Info> 复制SCF中CHGCAR文件，转移到BS文件夹" >> ./Quee_OUTPUT/Quee.info
				echo "<Info> SCF输出完整，所需文件已全部转移完毕" >> ./Quee_OUTPUT/Quee.info
			else
				echo "<Warning> SCF中未找到CHGCAR文件，终止BS程序" >> ./Quee_OUTPUT/Quee.info
				echo "SCF中未找到CHGCAR文件，终止BS程序"
				exit 2
			fi
		else
			echo "<Warning> SCF中未找到POTCAR文件，终止BS程序" >> ./Quee_OUTPUT/Quee.info
			echo "SCF中未找到POTCAR文件，终止BS程序"
			exit 2
		fi
	else
		echo "<Warning> SCF中未找到INCAR文件，终止BS程序" >> ./Quee_OUTPUT/Quee.info
		echo "SCF中未找到INCAR文件，终止BS程序"
		exit 2
	fi
else
	echo "<Warning> SCF中未找到POSCAR文件,终止BS程序" >> ./Quee_OUTPUT/Quee.info
	echo "SCF中未找到POSCAR文件,终止BS程序"
	exit 2
fi

#进入BS文件夹操作
cd ./BS
#----------------通过vaspkit获取初始文件--------------
#获得K-PATH和Primcell文件并覆盖
echo "303" | vaspkit >> ../Quee_OUTPUT/Quee.out
mv PRIMCELL.vasp POSCAR
mv KPATH.in KPOINTS

#--------------------更改INCAR参数-------------------
#修改ISTART
sed -i '3s/0/1/1' INCAR

#-----------------
#修改ICHARG
sed -i '5s/# //1' INCAR

#-----------------
#修改LCHARG
sed -i '10s/.TRUE./.FALSE./1' INCAR

#-----------------
#修改LORBIT =  11
sed -i "2a\LORBIT = 11" INCAR

#-----------------
#添加NCORE(默认为SR对应值）
CORE=$1
if [ ! $CORE ]
then
	echo "BS:你未输入参数,将自动使用初始化程序"
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
	echo "BS:用户自定义CORE = $CORE"
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
#复制BS.py文件
cp ~/work/Quee/BS.py ./BS.py

echo "#!/bin/bash
echo '<Info> BS程序开始运行' >> ../Quee_OUTPUT/Quee.info
srun -p phy -c $CORE -oversubscribe --ntasks=1 mpirun -np $CORE vasp_std
echo '<Info> BS程序运行完毕' >> ../Quee_OUTPUT/Quee.info
sleep 1" > ./BS.sh

#-----------------
#将SCF文件DOSCAR复制到BS文件夹下覆盖
echo "cp ../SCF/DOSCAR ./DOSCAR
sleep 1" >> ./BS.sh

#-----------------
#输出BS.png

#获得.config作图信息
BS_dpi=$(grep "BS_dpi" ~/work/Quee/Quee.config | awk -F '= ' '{print $2}')

echo "
echo '<Info> BS.png开始输出' >> ../Quee_OUTPUT/Quee.info
python3.10 ./BS.py $BS_dpi
echo '<Info> BS.png输出完毕' >> ../Quee_OUTPUT/Quee.info
rm ./versubscribe" >> ./BS.sh

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








