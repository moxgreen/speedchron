#!/bin/bash


usage()
{
cat << EOF
usage: $0 options 'command args'

This script run the the command. Then if the command exit status is 0 run it again. Otherwise wait -t seconds and then run the command again.

OPTIONS:
   -h      	Show this message
   -t S     	seconds to wait before rerunning command 
   -m EMAIL	e-mail address to report problems
   -v	   	verbose output
   -s SIGNAL	do not exit if the child produce this signal	
EOF
}

error ()
{
	EXIT=$1
	if [[ $EXIT -eq 1 ]]
	then
		EXIT_MSG="$0 exiting"
	else
		EXIT_MSG="$0 continue anyway (since -s $IGNORE_SIGNAL)"
	fi

	(
		echo -e "The command \n\n $CMD \n\nfailed with exit status $EXIT_STATUS.\n\n"
		echo $EXIT_MSG
		echo "[BEGIN STDOUT]"
		cat $TEMP_FILENAME1 
		echo "[END STDOUT]"
		echo "[BEGIN STDERR]"
		cat $TEMP_FILENAME2 
	) | tee /dev/stderr | mail -s "msg form $0" $MAIL_ADDRESS
	#rm $TEMP_FILENAME1 $TEMP_FILENAME2

	if [[ $EXIT -eq 1 ]]
	then
		exit $EXIT_STATUS
	fi
}

MAIL_ADDRESS=root
MY_SECONDS=-1 # dont use SECONDS, is a special UNIX variable!
VERBOSE=0
IGNORE_SIGNAL=0
declare -i MY_SECONDS
while getopts "ht:m:vs:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
    	 m)
	         MAIL_ADDRESS=$OPTARG
	     ;;
         t)
             MY_SECONDS=$OPTARG
	     ;;
         s)
             IGNORE_SIGNAL=$OPTARG
	     ;;
         v)
             VERBOSE=1
             ;;
         ?)
             usage
             exit
             ;;
     esac
done


shift `expr $OPTIND - 1`

CMD=$1

if [[ -z $MY_SECONDS ]] || [[ $MY_SECONDS -le 0 ]] || [[ $# -ne 1 ]] 
then
     usage
     exit 1
fi

while [[ 1 ]]
do
	[[ $VERBOSE -eq 1 ]] && echo creating tmp files

	TEMP_FILENAME1=`mktemp`
	TEMP_FILENAME2=`mktemp`

	[[ $VERBOSE -eq 1 ]] && echo executing \"$CMD\"

	bash -c -e "$CMD" 2>$TEMP_FILENAME2

	EXIT_STATUS=$?

	[[ $VERBOSE -eq 1 ]] && echo "exit status $EXIT_STATUS"

	if [[ $EXIT_STATUS -ne 0 ]]
	then
		if [[ $EXIT_STATUS -eq 128 ]]
		then
			[[ $VERBOSE -eq 1 ]] && echo sleep for $MY_SECONDS seconds
			[[ $VERBOSE -eq 1 ]] && echo sleeping since `date`
			sleep $MY_SECONDS
		else 
			if [[ $IGNORE_SIGNAL -ne 0 ]]
			then
				if [[ $EXIT_STATUS -eq $IGNORE_SIGNAL ]]
				then
					error 0
					[[ $VERBOSE -eq 1 ]] && echo sleep for $MY_SECONDS seconds
					[[ $VERBOSE -eq 1 ]] && echo sleeping since `date`
					sleep $MY_SECONDS
				else
					error 1
				fi
			else
				error 1
			fi
		fi
	fi

	rm $TEMP_FILENAME1 $TEMP_FILENAME2
done

