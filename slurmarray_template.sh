##JOB_NUM##

#For example...

my_file="/path/to/my/file";
my_file="/home/b.bssc1d/scripts/qarray/woof";
ARRAY_NUM=$(cat $my_file | wc -l);
ARRAY_NUM="$ARRAY_NUM $my_file some_other_argument";

echo $ARRAY_NUM;

##ARRAY_BIT##
#!/bin/bash --login
#SBATCH --ntasks=1
#SBATCH --time=1:00:00
#SBATCH --partition=htc
#SBATCH --array=?
#SBATCH -o batch example-%A_%a-%J.out.txt
#SBATCH -e example-%A_%a-%J.out.txt

file_list=$1;
arg=$2;
INPUT_FILE=$(sed -n "${SLURM_ARRAY_TASKID}p" $file_list);
echo ${SLURM_ARRAY_TASK_ID};
echo $INPUT_FILE;
echo $arg;
