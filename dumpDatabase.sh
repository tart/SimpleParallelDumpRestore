#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

if [ -e $1"."* ]
	then
		echo "File matching \""$1".*\" exists." > /dev/stderr
		exit 1
	fi

echo "Stopping slave..."
mysql -e "Stop slave"

echo "Dumping schema to \""$1".schema.sql\"..."
mysqldump -dR $1 > $1".schema.sql"

mkdir $1".data"
chmod o+w $1".data"

echo "Dumping data to \""$1".data\"..."
tables=$(mysql -e "Show full tables where Table_type = 'BASE TABLE'" $1 |
		sed "/^Tables/d" |
		sed "s/\tBASE TABLE//;")
for table in $tables
	do
		mysql -e "Set sql_big_selects = 1;
				Set query_cache_type = 0;
				Select * from "$table" into outfile '"$(pwd)/$1".data"/$table"'" $1 &
	done
wait

chmod go-rw $1"."*
chmod go-rw $1".data"/*

echo "Dumping master status to \""$1".masterStatus\"..."
mysql -e "Show master status" > $1".masterStatus"

echo "Dumping slave status to \""$1".masterStatus\"..."
mysql -e "Show slave status" > $1".slaveStatus"

if [ -s $1".masterStatus" ]
	then
		echo "Flushing logs..."
		mysql -e "Flush logs"
	fi

if [ -s $1".slaveStatus" ]
	then
		echo "Starting slave..."
		mysql -e "Start slave"
	fi

exit 0
