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