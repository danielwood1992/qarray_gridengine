**Purpose**

Grid Engine array jobs take a number of tasks, but you can't set these
within the program: you have to specify a fixed number in advance.
This script will allow you to have an initial section of your script that
when run outputs the appropriate number of tasks. The second section you 
can then write as a regular old array job. 
This stops you having to have two separate scripts, one to generate the 
correct array number and the second to actually run your job

**Usage

qarray.sh your_script.sh

**Requirements (that I know of...)**

A script corresponding to the qarray_template.sh format.

This will have:
1. A section starting with the line ##JOB_NUM##. This section needs to end with 'echo $ARRAY_NUM';
You can script whatever process you want to generate this array.
2. A second section starting with '##ARRAY_BIT##'. This you should write and should behave exactly as a normal array job...except where you'd normally have a line '#$ -t 1-10' or whatever, you
need to put '#$ -t ?'. This will get replaced with 1-$ARRAY_NUM from the
first bit of your script. 

If your script doesn't correspond to these requirements, an error message
should hopefully be generated

**Probable issues/caveats/etc.**

*Your JOB_NUM section should only print out an integer that's your number
of tasks, nothing else.

*None of the variables etc. from the JOB_NUM section will be transferred to 
the ARRAY_BIT section. If you need that stuff you'll have to re-run it down
there. 

*Probably worth checking the submission script the first time you run this
(it's $script2 from below, you'll need to comment out the rm $script2 line)
 in case something's gone horribly wrong.

*At the moment this script won't allow you to specify arguments for your job
e.g. 'qsub my_script.sh some_param'. Such is life.

*If you're generating multiple scripts per nanosecond the temporry script names might end up being a problem, I guess?
