Here's an automation script for processing VASP(A software to calculate electrons' structure in Physical and Chemical).

The following are the necessary pre-requisite softwares.

    1. Vaspkit

    2. Slurm

Before using, the only thing you need to do is add some paths information in Quee.sh. 

Read following steps.

    1. Downloading all files in Quee_Task_1.0 from repository to your machine runing on Linux(Ubuntu20 recommended).
    
    2. Add two paths in Quee.sh. They will be at the head of the file, following are they look like.

        Path_Quee='/opt/Quee'  #edit it as you expected the files to be at.
        partition='phy'  #edit it as you expected of the partition name in Slurm.

    3. After editing, you must give files runnable permissions by running the following command in the terminal under the current file path.

        $ chmod +x Quee.sh
        $ chmod +x Quee_*.sh

    4. All done. You can just easily running the script by running following command.

        $ ./Quee.sh

  Notice that you can 'cp' the file Quee.sh to wherever you want, to run the script rather than copying all files. But you must run the script in a folder where the POSCAR file exists.

  The error message will be in the generated Quee_Output folder.

  Users are welcome to share their experience and improvement suggestions, and technicians who want to support the project are also welcome to participate in discussions. You can contact me on github, or you can send me an email. 
  My email: queepho@queecloud.com


Update Info:

version 1.1: 简介：史诗级飞跃，1.0版本几乎无可迁移性，需要修改大量源码以适配各种运行环境，1.1版本首次将脚本程序可迁移化，在新版本中你将可以只需要修改几个简单的运行路径即可快速使用程序。

    细节：
    1. 添加Details参数自定义 可加入公用集群中需手动source的路径
    2. 修改检测slurm程序的参数由slurmd改为sbatch(应对公用集群中的检验)
    3. 修复了内部运行vasp时的partition参数依然为phy的问题 现已改为与Quee.sh中一致(传参)
    4. 修复了内部运行vasp时的vasp路径问题 现已改为可自定义(传参)
    5. 修复了内部运行python作图程序路径问题 现已改为可自定义(传参)
    6. 修复大量细分步骤sh文件中的Quee路径问题(传参)
    7. 修复了偶尔会报错Quee_xx.sh文件不存在的问题 原因是Quee.sh主程序在sbatch后紧接着会进行rm操作 现已将rm操作塞入sbatch内 在运行完Quee_xx.sh后再将其删除
    8. 修复了部分机器bash不会自动在echo指令中识别\n换行符 现已在需要的echo后加上-e转义字符解析
    9. 修复了在公用集群中slurm设置有单任务核心数申请上限 导致内部计算srun报错 目前已删除srun操作 直接进行mpirun计算 并且每一小步的计算结果会记录于总slurm.out中
    10. 提醒 建议在路径参数中不要加~ 否则可能会无法识别

Version 1.1: Introduction: Epic leap! The 1.0 version had almost no portability, requiring extensive modifications to the source code to adapt to various runtime environments. In version 1.1, for the first time, the script program is portable; in this new version, you will only need to modify a few simple runtime paths to quickly use the program.

    Details:

    1. Added a "Details" parameter for customization; you can include paths that need to be manually sourced in the shared cluster.
    2. Changed the parameter for detecting the SLURM program from slurmd to sbatch (to accommodate checks in the shared cluster).
    3. Fixed the issue where the partition parameter for running VASP internally was still set to phy; it is now consistent with Quee.sh (parameter passing).
    4. Fixed the VASP path issue when running VASP internally; it is now customizable (parameter passing).
    5. Fixed the path issue for running the Python plotting program internally; it is now customizable (parameter passing).
    6. Fixed the path issues in the numerous detailed step shell scripts (parameter passing).
    7. Resolved the occasional error stating that the Quee_xx.sh file does not exist; the issue arose because the main program Quee.sh would perform a rm operation immediately after sbatch. This operation has now been incorporated into sbatch, and the file will be deleted only after Quee_xx.sh has finished running.
    8. Fixed the issue where some machines' bash would not automatically recognize \n newline characters in the echo command; the -e escape character has been added to the necessary echo commands for proper parsing.
    9. Fixed the SLURM setting in the shared cluster that imposed a limit on the number of cores for single-task requests, which caused srun errors during internal calculations. The srun operation has now been removed, and calculations are performed directly with mpirun. Additionally, the results of each small step of calculations will be recorded in the total slurm.out.
    10. Reminder: It is advised not to include ~ in the path parameters, as it may lead to recognition issues.