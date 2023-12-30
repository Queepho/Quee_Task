#!/bin/bash

Path_Quee='/opt/Quee'
partition='phy'

echo "════════════════════════════════════════╗"
echo "欢迎使用Quee快捷VASP程序                ║"

#-----------------
#检验前置软件包是否安装
if [ ! "$(command -v slurmd)" ]
then
	echo "<Warning> 前置软件包Slurm未找到,终止Quee程序"
	exit 2
else
	echo "<Info> 前置软件包Slurm已检验安装        ║"
fi

#-----------------
#检验POSCAR文件是否已获得
if [ -f "./POSCAR" ]
then
	echo "<Info> POSCAR文件已检验                 ║"
	echo "════════════════════════════════════════╝"
else
	echo "<Warning> POSCAR文件未获取，终止Quee程序║"
	echo "════════════════════════════════════════╝"
	exit 2
fi

#--------------------------------------
LOGO="
 ██████╗ ██╗   ██╗███████╗███████╗        ████████╗ █████╗ ███████╗██╗  ██╗
██╔═══██╗██║   ██║██╔════╝██╔════╝        ╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝
██║   ██║██║   ██║█████╗  █████╗             ██║   ███████║███████╗█████╔╝ 
██║▄▄ ██║██║   ██║██╔══╝  ██╔══╝             ██║   ██╔══██║╚════██║██╔═██╗ 
╚██████╔╝╚██████╔╝███████╗███████╗███████╗   ██║   ██║  ██║███████║██║  ██╗
 ╚══▀▀═╝  ╚═════╝ ╚══════╝╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"


echo "$LOGO"

Windows="
═══════════════════════════════════════════════════════════════════════════
请输入操作代号                                                            
101 进行SR操作                                                 
102 进行SR和SCF操作                                                      
103 进行SR和SCF及BS操作—— —— —— —— —— —— ->输出BS.png                                       
104 进行SR和SCF及BS, DOS操作 —— —— —— —— ->输出BS.png, *_LDOS.png                      
——————————————————————————————————————————
201 进行SCF操作
202 进行BS操作  —— —— —— —— —— —— —— —— ->输出BS.png
203 进行DOS操作 —— —— —— —— —— —— —— —— ->输出*_LDOS.png
——————————————————————————————————————————
301 ->输出BS.png
302 ->输出*_LDOS.png

31  更改绘图参数
═════════════════Wannier══════════════════
	Waiting for update
——————————————————————————————————————————
0   退出程序
═══════════════════════════════════════════════════════════════════════════"


#输入健

Welcome(){
	echo "$Windows"
	read Target
	if [ ! -n "$Target" ]
	then
		Show_Illegal
	else
		:
	fi

	if [ $Target == 101 ]
	then
		cp ${Path_Quee}/Quee_SR.sh ./Quee_SR.sh
		echo "请输入执行分配CPU核心数目"
		read CORE

		if [ $(echo $CORE | sed 's/[0-9]*/ /g')=" " ]
		then
				echo "请输入任务名称（默认为Quee_Task)"
				read TASK
				if [ ! -z "$TASK" ]
				then
					echo "任务名称定义为 $TASK"

					echo "#!/bin/bash
					#SBATCH -J Q_SR
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE 
					#SBATCH --oversubscribe
					
					./Quee_SR.sh $CORE $TASK $Path_Quee " > ./Q_____SR.slurm
				else
					echo "未自定义任务名称，设为默认Quee_Task"

					echo "#!/bin/bash
					#SBATCH -J Q_SR
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_SR.sh $CORE Quee_Task $Path_Quee " > ./Q_____SR.slurm
				fi

				sbatch -p $partition ./Q_____SR.slurm
				sleep 1
				
				rm ./Q_____SR.slurm
		        rm ./Quee_SR.sh
		        exit 0
		else
		        Show_Illegal
		fi
	elif [ $Target == 102 ]
	then
		cp ${Path_Quee}/Quee_SR.sh ./Quee_SR.sh
		cp ${Path_Quee}/Quee_SCF.sh ./Quee_SCF.sh
		cat ./Quee_SCF.sh >> ./Quee_SR.sh
		rm ./Quee_SCF.sh
		mv ./Quee_SR.sh ./Quee_SR_SCF.sh

		echo "请输入执行分配CPU核心数目"
		read CORE
		if [ $(echo $CORE | sed 's/[0-9]*/ /g')=" " ]
		then
				echo "请输入任务名称（默认为Quee_Task)"
				read TASK
				if [ ! -z "$TASK" ]
				then
					echo "任务名称定义为 $TASK"

					echo "#!/bin/bash
					#SBATCH -J Q_SR_SCF
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE 
					#SBATCH --oversubscribe
					
					./Quee_SR_SCF.sh $CORE $TASK $Path_Quee " > ./Q_SR_SCF.slurm
				else
					echo "未自定义任务名称，设为默认Quee_Task"

					echo "#!/bin/bash
					#SBATCH -J Q_SR_SCF
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE 
					#SBATCH --oversubscribe
					
					./Quee_SR_SCF.sh $CORE Quee_Task $Path_Quee " > ./Q_SR_SCF.slurm
				fi
				sbatch -p $partition ./Q_SR_SCF.slurm
				sleep 1
				
				rm ./Q_SR_SCF.slurm
		        rm ./Quee_SR_SCF.sh
		        exit 0
		else
		        Show_Illegal
		fi
	elif [ $Target == 103 ]
	then
		cp ${Path_Quee}/Quee_SR.sh ./Quee_SR.sh
		cp ${Path_Quee}/Quee_SCF.sh ./Quee_SCF.sh
		cp ${Path_Quee}/Quee_BS.sh ./Quee_BS.sh
		cat ./Quee_SCF.sh >> ./Quee_SR.sh
		cat ./Quee_BS.sh >> ./Quee_SR.sh
		rm ./Quee_SCF.sh
		rm ./Quee_BS.sh
		mv ./Quee_SR.sh ./Quee_SR_SCF_BS.sh

		echo "请输入执行分配CPU核心数目"
		read CORE
		if [ $(echo $CORE | sed 's/[0-9]*/ /g')=" " ]
		then
				echo "请输入任务名称（默认为Quee_Task)"
				read TASK
				if [ ! -z "$TASK" ]
				then
					echo "任务名称定义为 $TASK"

					echo "#!/bin/bash
					#SBATCH -J Q_R_F_BS
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_SR_SCF_BS.sh $CORE $TASK $Path_Quee" > ./Q_R_F_BS.slurm
				else
					echo "未自定义任务名称，设为默认Quee_Task"

					echo "#!/bin/bash
					#SBATCH -J Q_R_F_BS
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE 
					#SBATCH --oversubscribe
					
					./Quee_SR_SCF_BS.sh $CORE Quee_TASK $Path_Quee " > ./Q_R_F_BS.slurm
				fi

				sbatch -p $partition ./Q_R_F_BS.slurm
				sleep 1
				
				rm ./Q_R_F_BS.slurm
		        rm ./Quee_SR_SCF_BS.sh
		        exit 0
		else
		        Show_Illegal
		fi
	elif [ $Target == 104 ]
	then
		cp ${Path_Quee}/Quee_SR.sh ./Quee_SR.sh
		cp ${Path_Quee}/Quee_SCF.sh ./Quee_SCF.sh
		cp ${Path_Quee}/Quee_BS.sh ./Quee_BS.sh
		cp ${Path_Quee}/Quee_DOS.sh ./Quee_DOS.sh
		cat ./Quee_SCF.sh >> ./Quee_SR.sh
		cat ./Quee_BS.sh >> ./Quee_SR.sh
		cat ./Quee_DOS.sh >> ./Quee_SR.sh
		rm ./Quee_SCF.sh
		rm ./Quee_BS.sh
		rm ./Quee_DOS.sh
		mv ./Quee_SR.sh ./Quee_SR_SCF_BS_DOS.sh

		echo "请输入执行分配CPU核心数目"
		read CORE
		if [ $(echo $CORE | sed 's/[0-9]*/ /g')=" " ]
		then
				echo "请输入任务名称（默认为Quee_Task)"
				read TASK
				if [ ! -z "$TASK" ]
				then
					echo "任务名称定义为 $TASK"

					echo "#!/bin/bash
					#SBATCH -J Q_R_F_BS_DOS
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE 
					#SBATCH --oversubscribe
					
					./Quee_SR_SCF_BS_DOS.sh $CORE $TASK $Path_Quee" > ./Q_R--DOS.slurm
				else
					echo "未自定义任务名称，设为默认Quee_Task"

					echo "#!/bin/bash
					#SBATCH -J Q_R_F_BS_DOS
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE 
					#SBATCH --oversubscribe
					
					./Quee_SR_SCF_BS_DOS.sh $CORE Quee_Task $Path_Quee" > ./Q_R--DOS.slurm
				fi

				sbatch -p $partition ./Q_R--DOS.slurm
				sleep 1
				
				rm ./Q_R--DOS.slurm
		        rm ./Quee_SR_SCF_BS_DOS.sh
		        exit 0
		else
		        Show_Illegal
		fi
	elif [ $Target == 201 ]
	then
		cp ${Path_Quee}/Quee_SCF.sh ./Quee_SCF.sh
		echo "请输入执行分配CPU核心数目"
		read CORE
		if [ $(echo $CORE | sed 's/[0-9]*/ /g')=" " ]
		then
				echo "请输入任务名称（默认为Quee_Task)"
				read TASK
				if [ ! -z "$TASK" ]
				then
					echo "任务名称定义为 $TASK"

					echo "#!/bin/bash
					#SBATCH -J Q_SCF
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE 
					#SBATCH --oversubscribe
					
					./Quee_SCF.sh $CORE $TASK $Path_Quee" > ./Q____SCF.slurm
				else
					echo "未自定义任务名称，设为默认Quee_Task"

					echo "#!/bin/bash
					#SBATCH -J Q_SCF
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE 
					#SBATCH --oversubscribe
					
					./Quee_SCF.sh $CORE Quee_Task $Path_Quee" > ./Q____SCF.slurm

				fi

				sbatch -p $partition ./Q____SCF.slurm
				sleep 1
				
				rm ./Q____SCF.slurm
		        rm ./Quee_SCF.sh
		        exit 0
		else
		        Show_Illegal
		fi
	elif [ $Target == 202 ]
	then
		cp ${Path_Quee}/Quee_BS.sh ./Quee_BS.sh
		echo "请输入执行分配CPU核心数目"
		read CORE
		if [ $(echo $CORE | sed 's/[0-9]*/ /g')=" " ]
		then	
				echo "请输入任务名称（默认为Quee_Task)"
				read TASK
				if [ ! -z "$TASK" ]
				then
					echo "任务名称定义为 $TASK"

					echo "#!/bin/bash
					#SBATCH -J Q_BS
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_BS.sh $CORE $TASK $Path_Quee" > ./Q_____BS.slurm
				else
					echo "未自定义任务名称，设为默认Quee_Task"

					echo "#!/bin/bash
					#SBATCH -J Q_BS
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_BS.sh $CORE Quee_Task $Path_Quee" > ./Q_____BS.slurm
				fi

				sbatch -p $partition ./Q_____BS.slurm
				sleep 1

				rm ./Q_____BS.slurm
		        rm ./Quee_BS.sh
		        exit 0
		else
		        Show_Illegal
		fi
	elif [ $Target == 203 ]
	then
		cp ${Path_Quee}/Quee_DOS.sh ./Quee_DOS.sh
		echo "请输入执行分配CPU核心数目"
		read CORE
		if [ $(echo $CORE | sed 's/[0-9]*/ /g')=" " ]
		then	
				echo "请输入任务名称（默认为Quee_Task)"
				read TASK
				if [ ! -z "$TASK" ]
				then
					echo "任务名称定义为 $TASK"

					echo "#!/bin/bash
					#SBATCH -J Q_DOS
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_DOS.sh $CORE $TASK $Path_Quee" > ./Q____DOS.slurm
				else
					echo "未自定义任务名称，设为默认Quee_Task"

					echo "#!/bin/bash
					#SBATCH -J Q_DOS
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_DOS.sh $CORE Quee_Task $Path_Quee" > ./Q____DOS.slurm
				fi

				sbatch -p $partition ./Q____DOS.slurm
				sleep 1

				rm ./Q____DOS.slurm
		        rm ./Quee_DOS.sh
		        exit 0
		else
		        Show_Illegal
		fi
	elif [ $Target == 301 ]
	then
		cp ${Path_Quee}/Quee_BS_PNG.sh ./Quee_BS_PNG.sh
		echo "请输入执行分配CPU核心数目"
		read CORE
		if [ $(echo $CORE | sed 's/[0-9]*/ /g')=" " ]
		then	
				echo "请输入任务名称（默认为Quee_Task)"
				read TASK
				if [ ! -z "$TASK" ]
				then
					echo "任务名称定义为 $TASK"

					echo "#!/bin/bash
					#SBATCH -J Q_DOS_PNG
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_BS_PNG.sh $CORE $TASK $Path_Quee" > ./Q__BSPNG.slurm
				else
					echo "未自定义任务名称，设为默认Quee_Task"

					echo "#!/bin/bash
					#SBATCH -J Q_DOS
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_BS_PNG.sh $CORE Quee_Task $Path_Quee" > ./Q__BSPNG.slurm
				fi

				sbatch -p $partition ./Q__BSPNG.slurm
				sleep 1

				rm ./Q__BSPNG.slurm
		        rm ./Quee_BS_PNG.sh
		        exit 0
		else
		        Show_Illegal
		fi
	elif [ $Target == 302 ]
	then
		cp ${Path_Quee}/Quee_LDOS_PNG.sh ./Quee_LDOS_PNG.sh
		echo "请输入执行分配CPU核心数目"
		read CORE
		if [ $(echo $CORE | sed 's/[0-9]*/ /g')=" " ]
		then	
				echo "请输入任务名称（默认为Quee_Task)"
				read TASK
				if [ ! -z "$TASK" ]
				then
					echo "任务名称定义为 $TASK"

					echo "#!/bin/bash
					#SBATCH -J Q_DOS_PNG
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_LDOS_PNG.sh $CORE $TASK $Path_Quee" > ./Q_DOSPNG.slurm
				else
					echo "未自定义任务名称，设为默认Quee_Task"

					echo "#!/bin/bash
					#SBATCH -J Q_DOS
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_LDOS_PNG.sh $CORE Quee_Task $Path_Quee" > ./Q_DOSPNG.slurm
				fi

				sbatch -p $partition ./Q_DOSPNG.slurm
				sleep 1

				rm ./Q_DOSPNG.slurm
		        rm ./Quee_LDOS_PNG.sh
		        exit 0
		else
		        Show_Illegal
		fi
	elif [ $Target == 31 ]
	then
		Welcome_31
	elif [ $Target == 401 ]
	then
		cp ${Path_Quee}/Quee_Wan.sh ./Quee_Wan.sh
		echo "请输入执行分配CPU核心数目"
		read CORE
		if [ $(echo $CORE | sed 's/[0-9]*/ /g')=" " ]
		then	
				echo "请输入任务名称（默认为Quee_Task)"
				read TASK
				if [ ! -z "$TASK" ]
				then
					echo "任务名称定义为 $TASK"

					echo "#!/bin/bash
					#SBATCH -J Q_W_NSCF
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_BS.sh $CORE $TASK $Path_Quee" > ./Q_W_NSCF.slurm
				else
					echo "未自定义任务名称，设为默认Quee_Task"

					echo "#!/bin/bash
					#SBATCH -J Q_W_NSCF
					#SBATCH -p $partition
					#SBATCH -N 1
					#SBATCH -n $CORE
					#SBATCH --oversubscribe
					
					./Quee_BS.sh $CORE Quee_Task $Path_Quee" > ./Q_W_NSCF.slurm
				fi

				sbatch -p $partition ./Q_W_NSCF.slurm
				sleep 1

				rm ./Q_W_NSCF.slurm
		        rm ./Quee_BS.sh
		        exit 0
		else
		        Show_Illegal
		fi
	elif [ $Target == 41 ]
	then
		Welcome_41
	elif [ $Target == 0 ]
	then
		Show_Exit
	else
		Show_Illegal
	fi
}

#————————————————————————————————————————————————————End of Welcome——————————————————————————————————————————————————————————

Windows31="
——————————————————————————————————————————
请输入操作代号
311 修改BS_dpi
312 修改DOS_dpi
313 修改DOS图横坐标x最小值x_min
314 修改DOS图横坐标x最大值x_max
315 修改DOS图纵坐标y最小值y_min
316 修改DOS图纵坐标y最大值y_max

310 退回上一级
0   退出程序
——————————————————————————————————————————"

Welcome_31(){
	echo "$Windows31"
		read Target3
		if [ $Target3 == 311 ]
		then
			Welcome_311
		elif [ $Target3 == 312 ]
		then
			Welcome_312
		elif [ $Target3 == 313 ]
		then
			Welcome_313
		elif [ $Target3 == 314 ]
		then
			Welcome_314
		elif [ $Target3 == 315 ]
		then
			Welcome_315
		elif [ $Target3 == 316 ]
		then
			Welcome_316
		elif [ $Target3 == 310 ]
		then
			Welcome
		elif [ $Target3 == 0 ]
		then
			Show_Exit
		else
			Show_Illegal
		fi
}

Welcome_311(){
	BS_dpi=$(grep "BS_dpi" ${Path_Quee}/Quee.config | awk -F '= ' '{print $2}')
	echo "
		┌────────────────────────────────────────
		│当前BS_dpi = $BS_dpi
		│最大设置修改值为2500
		│输入修改值:        (输入0则取消修改)"
	read BS_dpi_new
	if [ $(echo $BS_dpi_new | sed 's/[0-9]*/ /g')=" " ]
	then
		if [ $BS_dpi_new == 0 ]
		then
			echo "
		│已返回上一级
		└────────────────────────────────────────"
			Welcome_31
		elif [ $BS_dpi_new -gt 2500 ]
		then
			echo "
		│输入值过大，请重新输入
		└────────────────────────────────────────"
			sleep 1
			Welcome_311
		else
			WhereIsBS_dpi=$(awk '/BS_dpi/{print NR}' ${Path_Quee}/Quee.config)
			sed -i "${WhereIsBS_dpi}s/$BS_dpi/$BS_dpi_new/1" ${Path_Quee}/Quee.config
			echo "
		│已设置为$BS_dpi_new,自动返回上一级
		└────────────────────────────────────────"
			sleep 1
			Welcome_31
		fi
	else
		Show_Illegal
	fi
}

Welcome_312(){
	DOS_dpi=$(grep "DOS_dpi" ${Path_Quee}/Quee.config | awk -F '= ' '{print $2}')
	echo "
		┌────────────────────────────────────────
		│当前DOS_dpi = $DOS_dpi
		│最大设置修改值为2500
		│输入修改值:        (输入0则取消修改)"
	read DOS_dpi_new
	if [ $(echo $DOS_dpi_new | sed 's/[0-9]*/ /g')=" " ]
	then
		if [ $DOS_dpi_new == 0 ]
		then
			echo "
		│已返回上一级
		└────────────────────────────────────────"
			Welcome_31
		elif [ $DOS_dpi_new -gt 2500 ]
		then
			echo "
		│输入值过大，请重新输入
		└────────────────────────────────────────"
			sleep 1
			Welcome_312
		else
			WhereIsDOS_dpi=$(awk '/DOS_dpi/{print NR}' ${Path_Quee}/Quee.config)
			sed -i "${WhereIsDOS_dpi}s/$DOS_dpi/$DOS_dpi_new/1" ${Path_Quee}/Quee.config
			echo "
		│已设置为$DOS_dpi_new,自动返回上一级
		└────────────────────────────────────────"
			sleep 1
			Welcome_31
		fi
	else
		Show_Illegal
	fi
}

Welcome_313(){
	DOS_x_min=$(grep "DOS_x_min" ${Path_Quee}/Quee.config | awk -F '= -' '{print $2}')
	echo "
		┌────────────────────────────────────────
		│当前DOS_x_min = -$DOS_x_min
		│最小设置大于0
		│最大设置修改值为10    
		│(x_min取相反数)
		│输入修改值:        (输入0则取消修改)"
	read DOS_x_min_new
	if [ $(echo $DOS_x_min_new | sed 's/[0-9]*/ /g')=" " ]
	then
		if [ $DOS_x_min_new == 0 ]
		then
			echo "
		│已返回上一级
		└────────────────────────────────────────"
			Welcome_31
		elif [ $DOS_x_min_new -gt 10 ]
		then
			echo "
		│输入值过大，请重新输入
		└────────────────────────────────────────"
			sleep 1
			Welcome_313
		else
			WhereIsDOS_x_min=$(awk '/DOS_x_min/{print NR}' ${Path_Quee}/Quee.config)
			sed -i "${WhereIsDOS_x_min}s/$DOS_x_min/$DOS_x_min_new/1" ${Path_Quee}/Quee.config
			echo "
		│已设置为-$DOS_x_min_new,自动返回上一级
		└────────────────────────────────────────"
			sleep 1
			Welcome_31
		fi
	else
		Show_Illegal
	fi
}

Welcome_314(){
	DOS_x_max=$(grep "DOS_x_max" ${Path_Quee}/Quee.config | awk -F '= ' '{print $2}')
	echo "
		┌────────────────────────────────────────
		│当前DOS_x_max = $DOS_x_max
		│最小设置大于0
		│最大设置修改值为10    
		│输入修改值:        (输入0则取消修改)"
	read DOS_x_max_new
	if [ $(echo $DOS_x_max_new | sed 's/[0-9]*/ /g')=" " ]
	then
		if [ $DOS_x_max_new == 0 ]
		then
			echo "
		│已返回上一级
		└────────────────────────────────────────"
			Welcome_31
		elif [ $DOS_x_max_new -gt 10 ]
		then
			echo "
		│输入值过大，请重新输入
		└────────────────────────────────────────"
			sleep 1
			Welcome_314
		else
			WhereIsDOS_x_max=$(awk '/DOS_x_max/{print NR}' ${Path_Quee}/Quee.config)
			sed -i "${WhereIsDOS_x_max}s/$DOS_x_max/$DOS_x_max_new/1" ${Path_Quee}/Quee.config
			echo "
		│已设置为$DOS_x_max_new,自动返回上一级
		└────────────────────────────────────────"
			sleep 1
			Welcome_31
		fi
	else
		Show_Illegal
	fi
}

Welcome_315(){
	DOS_y_min=$(grep "DOS_y_min" ${Path_Quee}/Quee.config | awk -F '= -' '{print $2}')
	if [ ! -n "$DOS_y_min" ]
	then
		DOS_y_min=$(grep "DOS_y_min" ${Path_Quee}/Quee.config | awk -F '= ' '{print $2}')
		if [ ! -n $DOS_y_min ]
		then
			echo "未查找到DOS_y_min,请检查Quee.config"
			exit 2
		else
			if [ $DOS_y_min == 0 ]
			then
				:
			else
				echo "DOS_y_min不合法，请检查Quee.config"
				exit 2
			fi
		fi
	else
		:
	fi
	echo "
		┌────────────────────────────────────────
		│当前DOS_y_min = -$DOS_y_min
		│最小设置0         (输入00则表示为0)
		│最大设置修改值为20    
		│(y_min取相反数)
		│输入修改值:        (输入0则取消修改)"
	read DOS_y_min_new

	if [ $(echo $DOS_y_min_new | sed 's/[0-9]*/ /g')=" " ]
	then
		if [ $DOS_y_min_new == 0 ]
		then
			echo "
		│已返回上一级
		└────────────────────────────────────────"
			Welcome_31
		elif [ $DOS_y_min_new -gt 20 ]
		then
			echo "
		│输入值过大，请重新输入
		└────────────────────────────────────────"
			sleep 1
			Welcome_315
		elif [ $DOS_y_min_new == 00 ]
		then
			WhereIsDOS_y_min=$(awk '/DOS_y_min/{print NR}' ${Path_Quee}/Quee.config)
			sed -i "${WhereIsDOS_y_min}s/$DOS_y_min/0/1" ${Path_Quee}/Quee.config
			echo "
		│已设置为0,自动返回上一级
		└────────────────────────────────────────"
			sleep 1
			Welcome_31
		else
			WhereIsDOS_y_min=$(awk '/DOS_y_min/{print NR}' ${Path_Quee}/Quee.config)
			IsDash=$(sed -n "${WhereIsDOS_y_min},${WhereIsDOS_y_min}p" ${Path_Quee}/Quee.config | grep '-')
			if [ ! -n "$IsDash" ]
			then
				sed -i "${WhereIsDOS_y_min}s/$DOS_y_min/-$DOS_y_min_new/1" ${Path_Quee}/Quee.config
				echo "
		│已设置为-$DOS_y_min_new,自动返回上一级
		└────────────────────────────────────────"
			else
				sed -i "${WhereIsDOS_y_min}s/$DOS_y_min/$DOS_y_min_new/1" ${Path_Quee}/Quee.config
				echo "
		│已设置为-$DOS_y_min_new,自动返回上一级
		└────────────────────────────────────────"
			fi
			sleep 1
			Welcome_31
		fi
	else
		Show_Illegal
	fi
}

Welcome_316(){
	DOS_y_max=$(grep "DOS_y_max" ${Path_Quee}/Quee.config | awk -F '= ' '{print $2}')
	echo "
		┌────────────────────────────────────────
		│当前DOS_y_max = $DOS_y_max
		│最小设置大于0
		│最大设置修改值为20    
		│输入修改值:        (输入0则取消修改)"
	read DOS_y_max_new
	if [ $(echo $DOS_y_max_new | sed 's/[0-9]*/ /g')=" " ]
	then
		if [ $DOS_y_max_new == 0 ]
		then
			echo "
		│已返回上一级
		└────────────────────────────────────────"
			Welcome_31
		elif [ $DOS_y_max_new -gt 20 ]
		then
			echo "
		│输入值过大，请重新输入
		└────────────────────────────────────────"
			sleep 1
			Welcome_316
		else
			WhereIsDOS_y_max=$(awk '/DOS_y_max/{print NR}' ${Path_Quee}/Quee.config)
			sed -i "${WhereIsDOS_y_max}s/$DOS_y_max/$DOS_y_max_new/1" ${Path_Quee}/Quee.config
			echo "
		│已设置为$DOS_y_max_new,自动返回上一级
		└────────────────────────────────────────"
			sleep 1
			Welcome_31
		fi
	else
		Show_Illegal
	fi
}

WhichRow_(){
	File=$1
	Content=$2
	Row=$(awk "/$Content/{print NR}" $File)
	return $Row
}

Windows41="
——————————————————————————————————————————
请输入操作代号
411 选择投影元素和对应轨道
412 

410 退回上一级
0   退出程序
——————————————————————————————————————————"

Welcome_41(){
	echo "$Windows41"
	read Target4
	if [ $Target4 == 411 ]
	then
		Welcome_411
	elif [ $Target4 == 412 ]
	then
		Welcome_412
	elif [ $Target4 == 410 ]
	then
		Welcome
	elif [ $Target4 == 0 ]
	then
		Show_Exit
	else
		Show_Illegal
	fi
}

Welcome_411(){
	cp -n ${Path_Quee}/Quee_Wan.config ${Path_Quee}/Quee_Wan_temp.config
	PATH_="${Path_Quee}/Quee_Wan_temp.config"
	WhichRow_ $PATH_ "begin projections"
	Row_begin=$?
	WhichRow_ $PATH_ "end projections"
	Row_end=$?
	if [ -n "Row_begin" ] && [ -n "Row_end" ]
	then
        Welcome_411_I
	else
		echo "Wannier标准文件格式错误，自动返回上一级"
		sleep 1
		Welcome_41
	fi
}

Welcome_411_I(){
	PATH_="${Path_Quee}/Quee_Wan_temp.config"
	WhichRow_ $PATH_ "begin projections"
	Row_begin=$?
	WhichRow_ $PATH_ "end projections"
	Row_end=$?
	echo "
		┌────────────────────────────────────────
		│当前投影信息:
────────────────┘	
$(sed -n "$Row_begin,${Row_end}p" $PATH_)
────────────────┐	
		│POSCAR索取元素:"
	for line in ` sed -n '6,6p' ./POSCAR | cat `
        do
            echo "        	$line"
        done
    echo "        	│格式范例1(Ta : s; p; d)"
    echo "        	│格式范例2(Si : p)"
    echo "        	│键入Enter或输入0则结束输入返回上一级"
    echo "        	│输入1则删除所有投影信息"
	read -p "        	│添加信息:" Input_Projection
	if [ -z "$Input_Projection" ]
	then
		echo "
		│已返回上一级
		└────────────────────────────────────────"
		Welcome_41
	elif [ $Input_Projection == 0 ]
	then
		echo "
		│已返回上一级
		└────────────────────────────────────────"
		Welcome_41
	elif [ $Input_Projection == 1 ]
	then
		sed -i -n '1,/begin projections/p;/end projections/,$p' $PATH_
		echo "        	│投影信息已全部删除"
		echo "
		└────────────────────────────────────────"
		Welcome_411_I
	else
	    sed -i "${Row_end}i ${Input_Projection}" $PATH_
	    echo "        	│信息已添加($Input_Projection)"
	    echo "
		└────────────────────────────────────────"
	    Welcome_411_I
	fi
}

Illegal="═══════════════════════输入值非法，自动终止Quee程序════════════════════════"

Show_Illegal(){
	echo "$Illegal"
	exit 2
}

Exit="════════════════════你已终止Quee程序，期待你的下次使用═════════════════════"

Show_Exit(){
	echo "$LOGO"
	echo "$Exit"
	exit 0
}

Welcome




