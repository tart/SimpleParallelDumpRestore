#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

if [ -e slaveStatus ]
    then
        echo "File matching \"slaveStatus\" exists." > /dev/stderr
        exit 1
    fi

if [ -e masterStatus ]
    then
        echo "File matching \"masterStatus\" exists." > /dev/stderr
        exit 1
    fi

if [ -e $1"."* ]
    then
        echo "File matching \""$1".*\" exists." > /dev/stderr
        exit 1
    fi

slaveRunning=$(mysql -e "Show status like 'Slave_running'" | sed 1d | cut -f 2)
if [ $slaveRunning = "ON" ]
    then
        echo "Stopping slave activity..."
        mysql -e "Stop slave"
    fi

echo "Dumping data model to \""$1".dataModel.sql\"..."
mysqldump -dR $1 > $1".dataModel.sql"

echo "Dumping data to \""$1".data\"..."
mkdir $1".data"
chmod o+w $1".data"
for table in $(mysql -e "Show full tables where Table_type = 'BASE TABLE'" $1 | sed 1d | cut -f 1)
	do
		mysql -e "Set sql_big_selects = 1;
				Set query_cache_type = 0;
				Select * from "$table" into outfile '"$(pwd)/$1".data"/$table"'" $1 &
	done

echo "Dumping master status..."
mysql -e "Show master status" > masterStatus

if [ -s masterStatus ]
	then
		echo "Flushing logs..."
		mysql -e "Flush logs"
	fi

if [ $slaveRunning = "ON" ]
	then
        echo "Dumping slave status..."
        mysql -e "Show slave status" > slaveStatus

		echo "Starting slave activity..."
		mysql -e "Start slave"
	fi

wait
exit 0
