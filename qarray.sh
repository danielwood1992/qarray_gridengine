#!/bin/bash


#Usage qarray.sh my_script.sh
file=$1;

#####
#1 Check my_script.sh conforms to requirements (see qarray_template.sh for example)
#####


if [ -z "$file" ]
	then echo "ERROR: Need to specify a script (that conforms with qarray_template)"; exit $ERRCODE;
fi; 

#So if there's not one match to '#$ -t ?' then kill the thing...
if [ $(grep -F -o '#$ -t ?' $file | wc -l) -ne 1  ]
	then echo "ERROR: Script $file needs ONE '#$ -t ?' argument..."; exit $ERRCODE;	
fi;

#ditto ##ARRAY_BIT##
if [ $(grep -F -o '##ARRAY_BIT##' $file | wc -l) -ne 1  ]
	then echo "ERROR: Script $file needs ONE '##ARRAY_BIT##' line..."; exit $ERRCODE;	
fi;

#ditto 'echo $ARRAY_NUM'
if [ $(grep -F -o 'echo $ARRAY_NUM' $file | wc -l) -NE 1  ]
	then echo "ERROR: Script $file needs ONE 'echo \$ARRAY NUM' line..."; exit $ERRCODE;	

fi;

#ditto ##JOB_NUM## section
if [ $(grep -F -o '##JOB_NUM##' $file | wc -l) -NE 1  ]
	then echo "ERROR: Script $file needs ONE '##ARRAY_BIT##' line..."; exit $ERRCODE;	
fi;

##########
#2 Get number of tasks
#########

#temp script 1 (calculating array num)
dt1=`date '+%d_%N'`;
script1="my_script_$dt1.sh";
awk '/\#\#JOB_NUM\#\#/{flag=1;next}/\#\#ARRAY_BIT\#\#/{flag=0}flag' $file > $script1;
task_num=$(bash $script1);
echo "Number of tasks : $task_num";
re='^[0-9+$]'
if ! [[ $task_num =~ $re ]]
	then echo "ERROR: ##JOB_NUM## section did not produce an integer"; exit $ERRCODE;	
fi;
rm $script1;

##########
#3 Print out rest of script; sub in task number; qsub script...
#########

dt2=`date '+%d_%N'`;
script2="my_script_$dt2.sh";
awk '/\#\#ARRAY_BIT\#\#/{flag=1;next}/alongandhopefullyunmatchedpattern/{flag=0}flag' $file > $script2;
sed -i "s/\#\$ \-t ?/#$ -t 1-$task_num/" $script2;

#########
#5 This should probably now work
########
qsub $script2;
rm $script2;
echo "Done.";

