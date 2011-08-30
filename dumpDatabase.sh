#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

mysql -e "Stop slave"
echo "Slave activity stopped."

for schema in $(mysql -e "Show schemas" | sed 1d)
	do
		$(pwd)/${0%dumpDatabase.sh}dumpSchema.sh $schema &
	done
echo "Dump commands sent."

mysql -e "Show master status" > masterStatus
echo "Master status dumped to \"./masterStatus\"."

mysql -e "Show slave status" > slaveStatus
echo "Slave status dumped to \"./slaveStatus\"."

if [ -s masterStatus ]
	then
		mysql -e "Flush logs"
		echo "Logs flushed."
	fi

if [ -s slaveStatus ]
	then
		mysql -e "Start slave"
		echo "Slave activity started."
	fi

wait
exit 0
