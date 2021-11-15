#!/bin/bash


#Usage qarray.sh my_script.sh
file=$1;
filename=${file##*/};

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
if [ $(grep -F -o 'echo $ARRAY_NUM' $file | wc -l) -ne 1  ]
	then echo "ERROR: Script $file needs ONE 'echo \$ARRAY NUM' line..."; exit $ERRCODE;	

fi;

#ditto ##JOB_NUM## section
if [ $(grep -F -o '##JOB_NUM##' $file | wc -l) -ne 1  ]
	then echo "ERROR: Script $file needs ONE '##ARRAY_BIT##' line..."; exit $ERRCODE;	
fi;

##########
#2 Get number of tasks
#########

#temp script 1 (calculating array num)
#Generates a date (in nanoseconds) to use as temporary file...
dt1=`date '+%d_%N'`;
script1="$filename.my_script_$dt1.sh";

#So this starts at ##JOBNUM### and prints every line til ##ARRAY_BIT##
awk '/\#\#JOB_NUM\#\#/{flag=1;next}/\#\#ARRAY_BIT\#\#/{flag=0}flag' $file > $script1;

#Then executes the script, amd saves the output (which will either be NTASKS, or 
#NTASKS ARG1 ARG2 ARG3 etc.

script1_out=$(bash $script1);
echo $script1_out;

#So if there's a space (i.e. if there are arguments, set the first one as the TASK num
#and pass the rest on as arguments.
if [[ $script1_out = *" "* ]]
	then echo "Arguments..."; 
	script1_out_array=($script1_out);
	task_num=${script1_out_array[0]};
	rest=$(echo $script1_out | sed 's/^[^ ]* //g');
else
	#Otherise, just use the whole string as the task num
	task_num=$script1_out;
	rest="No arguments";	
fi;


echo "Number of tasks : $task_num";
echo "Arguments $rest";

#Task num has to be an integer
re='^[0-9+$]'
if ! [[ $task_num =~ $re ]]
	then echo "ERROR: ##JOB_NUM## section did not produce an integer"; exit $ERRCODE;	
fi;
rm $script1;

##########
#3 Print out rest of script; sub in task number; qsub script...
#########

dt2=`date '+%d_%N'`;
script2="$filename.my_script_$dt2.sh";

#Gets from the ##ARRAY_BIT## section to the end of the script..
awk '/\#\#ARRAY_BIT\#\#/{flag=1;next}/alongandhopefullyunmatchedpattern/{flag=0}flag' $file > $script2;

#Updates the task num bit to the appropriate task numbers
sed -i "s/\#\$ \-t ?/#$ -t 1-$task_num/" $script2;

#########
#5 Submit script (with whatever arguments)
########

qsub $script2 $rest;
rm $script2;
