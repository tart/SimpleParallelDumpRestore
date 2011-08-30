#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

echo "Stopping slave activity..."
mysql -e "Stop slave"

for schema in $(mysql -e "Show schemas" | sed 1d)
	do
		$(pwd)/${0%dumpDatabase.sh}dumpSchema.sh $schema &
	done

echo "Dumping master status to \"masterStatus\"..."
mysql -e "Show master status" > masterStatus

echo "Dumping slave status to \"slaveStatus\"..."
mysql -e "Show slave status" > slaveStatus

if [ -s masterStatus ]
	then
		echo "Flushing logs..."
		mysql -e "Flush logs"
	fi

if [ -s slaveStatus ]
	then
		echo "Starting slave activity..."
		mysql -e "Start slave"
	fi

wait
exit 0
