# speedchron
tool to execute a command repeatedly

##usage
$ speedchron options 'command args'

This script run the the command. Then if the command exit status is 0 run it again. 
Otherwise wait -t seconds and then run the command again.

OPTIONS:
   -h           Show this message
   -t S         seconds to wait before rerunning command 
   -m EMAIL     e-mail address to report problems
   -v           verbose output
   -s SIGNAL    do not exit if the child produce this signal

