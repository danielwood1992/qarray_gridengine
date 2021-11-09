**Purpose**

Grid Engine array jobs take a number of tasks, but you can't set these
within the program: you have to specify a fixed number in advance.
This script will allow you to have an initial section of your script that
when run outputs the appropriate number of tasks. The second section you 
can then write as a regular old array job. 
This stops you having to have two separate scripts, one to generate the 
correct array number and the second to actually run your job

For example, you might have a list of files you want to do something to. Normally
you'd have to manually do wc -l $file_list and change the value of N in  #$ -t N
to that number. If the number is changing all the time (e.g. if your $file_list is 
changing in size all the time as new tasks are added to it), or if you have a complex
method of determining how many tasks to run (e.g. if it's things in file A and not file B
and file A and B are changing all the time) or if you're just too lazy to change
the number by hand, this might be the script for you.

**Usage**

qarray.sh your_script.sh

**Requirements (that I know of...)**

A script corresponding to the qarray_template.sh format.

This will have:
1. A section starting with the line ##JOB_NUM##. This section needs to end with 'echo $ARRAY_NUM'. The $ARRAY_NUM variable can either just be the number of tasks; OR the number of tasks, and
then arguments to pass to each array jobs (separated by spaces);
You can script whatever processes you want to generate these things.
2. A second section starting with '##ARRAY_BIT##'. This you should write and should behave exactly as a normal array job...except where you'd normally have a line '#$ -t 1-10' or whatever, you
need to put '#$ -t ?'. This will get replaced with 1-$ARRAY_NUM from the
first bit of your script. 

If your script doesn't correspond to these requirements, an error message
should hopefully be generated

**Probable issues/caveats/etc.**

*None of the variables etc. from the JOB_NUM section will be transferred to 
the ARRAY_BIT section. If you need that stuff you'll have to re-run it down
there. 

*Probably worth checking the submission script the first time you run this
(it's $script2 from below, you'll need to comment out the rm $script2 line)
 in case something's gone horribly wrong.

*If you're generating multiple scripts per nanosecond the temporry script names might end up being a problem, I guess?
