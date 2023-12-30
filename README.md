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

  Notice that you can 'cp' the file Quee.sh to wherever you want, to run the script rather that all files. But you must run the script in a folder where the POSCAR file exists.

  The error message will be in the generated Quee_Output folder.

  Users are welcome to share their experience and improvement suggestions, and technicians who want to support the project are also welcome to participate in discussions. You can contact me on github, or you can send me an email. 
  My email: queepho@queecloud.com
    
