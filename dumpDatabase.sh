#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

if [ -e $1".schema.sql" ]
	then
	echo $1".schema.sql file exists." > /dev/stderr
	exit 1
fi

mysql -e "Show master status" > $1".masterStatus"
mysql -e "Show slave status" > $1".slaveStatus"

if [ -s $1".slaveStatus" ]
	then
	mysql -e "Stop slave"
fi

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

echo "Waiting..."
wait

chmod go-rw $1"."*
chmod go-rw $1".data"/*

if [ -s $1".slaveStatus" ]
	then
	mysql -e "Start slave"
fi

exit 0
