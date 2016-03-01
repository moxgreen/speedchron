#!/bin/bash

usage()
{
cat << EOF
usage: $0 'MYSQL_CMD' DONE_URL

OPTIONS:
   -h      Show this message
   -n	   Dry run
EOF
}

MYSQL_CMD=mysql
DRY_RUN=0
while getopts "hn" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
    	 n)
	         DRY_RUN=1
	         ;;
         ?)
             usage
             exit
             ;;
     esac
done

shift `expr $OPTIND - 1`

if [[ $# -ne 2 ]] 
then
     usage
     exit 1
fi

MYSQL_CMD=$1
DONE_URL=$2

ID=$(
	$MYSQL_CMD<<-EOF
		SELECT id FROM custom_net WHERE done=0 LIMIT 1;
	EOF
)

if [[ -z $ID ]]
then
	exit 128
fi

N=""
if [[ $DRY_RUN -ne 0 ]]
then
	N="-n"
fi

cd $BIOINFO_ROOT/prj/conserved_net/dataset/
bmake $N all CONSERVED_NET_UNIQ_ID=$ID
RETVAL=$?

if [[ $DRY_RUN -eq 0 && $RETVAL -eq 0 ]]
then
	echo wgetting $DONE_URL
	wget -q -O /dev/null "$DONE_URL?n=$ID"
fi

echo "Done"
exit $RETVAL
