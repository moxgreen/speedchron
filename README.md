# speedchron
tool to execute a command repeatedly

##usage
$ speedchron options 'command args'

This script run the the command. Then if the command exit status is 0 run it again. 
If the exist status of the command is 128 wait -t seconds and then run the command again.
Oterwise report the stderr via mail.

OPTIONS:

   -h           Show this message

   -t S         seconds to wait before rerunning command 

   -m EMAIL     e-mail address to report problems

   -v           verbose output

   -s SIGNAL    do not exit if the child produce this signal

### Example
$ speedchron -t 60 -m mail@mail.com "check_for_custom_network_to_do 'mysql -BCAN -u $USER -p$PASSWORD -h $IP $DBNAME' http://$IP/coexpr/custom_network/custom_net_done.php"

see also the example command check_for_custom_network_to_do.sh


