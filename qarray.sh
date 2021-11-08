#!/bin/bash

####Purpose
#Grid Engine array jobs take a number of tasks, but you can't set these
#within the program: you have to specify a fixed number in advance.
#This script will allow you to have an initial section of your script that
#when run outputs the appropriate number of tasks. The second section you 
#can then write as a regular old array job. 
#This stops you having to have two separate scripts, one to generate the 
#correct array number and the second to actually run your job

####Requirements (that I know of...)

#A script corresponding to the qarray_template.sh format.

#This will have:
#A section starting with the line ##JOB_NUM##
#This section needs to end with 'echo $ARRAY_NUM';
#You can script whatever process you want to generate this array.
#A second section starting with '##ARRAY_BIT##'
#This you should write and should behave exactly as a normal array job...
#...except where you'd normally have a line '#$ -t 1-10' or whatever, you
#need to put '#$ -t ?'. This will get replaced with 1-$ARRAY_NUM from the
#first bit of your script. 
#If your script doesn't correspond to these requirements, an error message
#should hopefully be generated

####Probable issues/caveats/etc.
#Your JOB_NUM section should only print out an integer that's your number
#of tasks, nothing else.
#
#None of the variables etc. from the JOB_NUM section will be transferred to 
#the ARRAY_BIT section. If you need that stuff you'll have to re-run it down
#there. 
#
#Probably worth checking the submission script the first time you run this
#(it's $script2 from below, you'll need to comment out the rm $script2 line)
# in case something's gone horribly wrong.
#
#At the moment this script won't allow you to specify arguments for your job
#e.g. 'qsub my_script.sh some_param'. Such is life.
#
#If you're generating multiple scripts per nanosecond the temporry script names might end up being a problem, I guess?


file=$1;

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
#1 Get number of tasks
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
#2 Print out rest of script; sub in task number; qsub script...
#########

dt2=`date '+%d_%N'`;
script2="my_script_$dt2.sh";
awk '/\#\#ARRAY_BIT\#\#/{flag=1;next}/alongandhopefullyunmatchedpattern/{flag=0}flag' $file > $script2;
sed -i "s/\#\$ \-t ?/#$ -t 1-$task_num/" $script2;

#########
#3 This should probably now work
########
qsub $script2;
rm $script2;
echo "Done.";

