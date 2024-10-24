#!/bin/sh

#--------------------检验前置----------------------
#创建信息输出文件夹
if [ ! -d "./Quee_OUTPUT" ]
then
	mkdir ./Quee_OUTPUT
	echo "══════════════════════════════════════════" > ./Quee_OUTPUT/Quee.info
	echo "<Info> Quee输出文件夹已自动创建" >> ./Quee_OUTPUT/Quee.info
else
	echo "══════════════════════════════════════════" > ./Quee_OUTPUT/Quee.info
	echo "<Info> Quee输出文件夹已存在，将自动绑定路径" >> ./Quee_OUTPUT/Quee.info
fi

#-----------------
#检验前置软件包是否安装
if [ ! "$(command -v vaspkit)" ]
then
	echo "<Warning> 前置软件包Vaspkit未找到" >> ./Quee_OUTPUT/Quee.info
	echo "前置软件包Vaspkit未找到，终止SR程序"
	exit 2
else
	echo "<Info> 前置软件包Vaspkit已检验安装" >> ./Quee_OUTPUT/Quee.info
fi

if [ ! "$(command -v sbatch)" ]
then
	echo "<Warning> 前置软件包Slurm未找到" >> ./Quee_OUTPUT/Quee.info
	echo "前置软件包Slurm未找到，终止SR程序"
	exit 2
else
	echo "<Info> 前置软件包Slurm已检验安装" >> ./Quee_OUTPUT/Quee.info
fi

#-----------------
#检验POSCAR文件是否已获得
if [ -f "./POSCAR" ]
then
	echo "<Info> POSCAR文件已检验" >> ./Quee_OUTPUT/Quee.info
else
	echo "<Warning> POSCAR文件未获取，终止SR程序" >> ./Quee_OUTPUT/Quee.info
	echo "POSCAR文件未获取，终止SR程序"
	exit 2
fi

#-------------------预处理步骤--------------------
#获取TASK信息
TASK=$2

#创建SR文件夹
if [ ! -d "./SR" ]
then
	mkdir ./SR
	echo -e "————————————————————SR————————————————————\n<Info> SR文件夹已自动创建" >> ./Quee_OUTPUT/Quee.info
else
	echo -e "————————————————————SR————————————————————\n<Warning> SR文件夹已存在，将自动绑定路径" >> ./Quee_OUTPUT/Quee.info
fi

#复制POSCAR文件至SR文件夹下
cp POSCAR ./SR/POSCAR
echo "<Info> POSCAR文件已复制至SR文件夹下" >> ./Quee_OUTPUT/Quee.info

#进入SR文件夹操作
cd ./SR

#-------------通过vaspkit获取初始文件-------------
#获得INCAR-SR文件
echo -e "101\nSR" | vaspkit > ../Quee_OUTPUT/Quee.out
#获得POTCAR文件
echo "103" | vaspkit >> ../Quee_OUTPUT/Quee.out
#获得KPOINTS文件 mesh=0.02
echo -e "102\n2\n0.02" | vaspkit >> ../Quee_OUTPUT/Quee.out
echo "<Info> 生成KPOINTS时设置mesh为 0.02" >> ../Quee_OUTPUT/Quee.info
#-----------------更改INCAR参数------------------
#修改ENMAX
sed -i '6s/# //1' INCAR

#获得ENMAX数据
grep ENMAX POTCAR | grep -oP '\d*\.\d+' | sed '1~2!d' | sed "s/\..*//g" > file_temp

#获得最大ENMAX并赋值到INCAR中
MAX=$(cat file_temp | sort -rn | head -n 1 )
temp=`expr ${MAX} / 2`
ENMAX=`expr ${MAX} + ${temp}`
ENMAX=$(expr $ENMAX \* 13 / 10)      #(Fixed 4/3/2024; 取1.3倍 经验之谈)
echo "<Info> ENMAX值设置为 $ENMAX" >> ../Quee_OUTPUT/Quee.info
sed -i "6s/400/${ENMAX}/1" INCAR
rm file_temp

#-----------------
#修改PREC
sed -i '7s/# //1' INCAR

#-----------------
#修改SIGMA
sed -i '23s/0.05/0.075/1' INCAR

#-----------------
#修改ISIF为3(改变形状和体积）
sed -i '32s/2/3/1' INCAR  

#-----------------
#修改EDIFFG
sed -i '33s/-2E-02/-0.001/1' INCAR    #(changed Oct 11, -0.001 -> -0.01) (changed Oct 24, -0.01 -> -0.001)

#-----------------
#修改EDIFF
sed -i '26s/1E-08/1E-7/1' INCAR     #(changed 24/10/2024, 1E-10 -> 1E-7 前者适用声子谱)

#-----------------
#修改ISTART
sed -i '2s/1/0/1' INCAR

#-----------------
#添加NCORE(默认不添加）
CORE=$1
if [ ! $CORE ]
then
	echo "SR:你未输入参数,将自动使用初始化程序"
	echo "<Info> 用户未自定义CORE，自动设置CORE = 4，NCORE = 2" >> ../Quee_OUTPUT/Quee.info
	sed -i "1a\NCORE = 2" INCAR
	CORE=4
else
	echo "SR:用户自定义CORE = $CORE"
	temp=$(awk -v x=$CORE 'BEGIN{print sqrt(x)}')
	NCORE=$(echo $temp | sed "s/\..*//g")
	echo "<Info> 用户选择自定义NCORE为 $NCORE" >> ../Quee_OUTPUT/Quee.info
	sed -i "1a\NCORE = $NCORE" INCAR
fi

#-----------------创造并运行SBATCH文件----------------
partition=$4
Path_vasp=$5
echo "#!/bin/bash
echo '<Info> SR程序开始运行' >> ../Quee_OUTPUT/Quee.info
mpirun -np $CORE $Path_vasp
echo '<Info> SR程序运行完毕' >> ../Quee_OUTPUT/Quee.info" > ./SR.sh
chmod +x ./SR.sh
./SR.sh
rm ./SR.sh

#--------------------检验运行后结果-------------------
echo "----------检验SR结果----------" >> ../Quee_OUTPUT/Quee.info

#检索OUTCAR文件
if [ ! -f "./OUTCAR" ]
then
	echo "<Warning> OUTCAR文件未索取，请检查SR运行情况" >> ../Quee_OUTPUT/Quee.info
else
	echo "<Info> OUTCAR文件已检索" >> ../Quee_OUTPUT/Quee.info
	
	#-----------------
	#检验是否收敛
	IsFit=$(grep -w 'reached required accuracy - stopping structural energy minimisation' OUTCAR)
	if [ -z "$IsFit" ]
	then
		echo "<Warning> SR未收敛"
		echo "<Warning> SR未收敛，请自行检查" >> ../Quee_OUTPUT/Quee.info
	else
		echo "<Info> SR已收敛" >> ../Quee_OUTPUT/Quee.info

	fi

	#-----------------
	#检验SIGMA展宽是否合理
	Width=$(grep 'entropy T' OUTCAR | tail -n1 | grep -oP '\d*\.\d+')
	 
	if [ ! $Width ]; then  
		echo "<Warning> OUTCAR中SIGMA展宽未索取，请检查OUTCAR" >> ../Quee_OUTPUT/Quee.info  
	else  
	  	echo "<Info> OUTCAR中SIGMA展宽已检索"  >> ../Quee_OUTPUT/Quee.info
	  	sum=0
		for line in ` sed -n '7,7p' POSCAR | cat `
		do
            sum=$(echo "$sum + $line" | tr -d '\r' | bc)
		    #sum=`expr $sum + $line` (Fixed 4/3/2024; A problem)
		done
		echo "<Info> 体系原子总数目为 $sum" >> ../Quee_OUTPUT/Quee.info

		Width_result=$(awk 'BEGIN{printf "%.6f\n",'$Width'/'$sum'}')

		if [ `echo "$Width_result < 0.001" | bc` -eq 1 ]
		then
			echo "<Info> 体系SIGMA展宽值合理，E/num_atoms = $Width_result < 0.001" >> ../Quee_OUTPUT/Quee.info
		else
			echo "<Warning> 体系SIGMA展宽值不合理，E/num_atoms = $Width_result ≥ 0.001" >> ../Quee_OUTPUT/Quee.info
		fi
	fi    
fi

#-----------------复原索取目录------------------
cd ../






