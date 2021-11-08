##JOB_NUM##

#Examples...

#my_file="/path/to/my/file";
#ARRAY_NUM=$(cat $my_file | wc -l);

ARRAY_NUM=5;

#etc. etc.

echo $ARRAY_NUM;

##ARRAY_BIT##

#!/bin.bash
#$ -cwd
#$ -pe smp 1
#$ -l h_rt=1:0:0
#$ -l h_vmem=5G
#$ -t ?
#$ -tc 50

echo ${SGE_TASK_ID};
