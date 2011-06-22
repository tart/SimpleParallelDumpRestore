#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

echo "Restoring schema from \""$1".schema.sql\" to "$2" database..." >> $1".restore.log"
echo "Restoring schema from \""$1".schema.sql\" to "$2" database..."
( time mysql $2 < $1".schema.sql" 2>> $1".restore.log" ) 2>> $1".restore.log"
echo >> $1".restore.log"

echo "Restoring data from \""$1".data\" to "$2" database..." >> $1".restore.log"
echo "Restoring data from \""$1".data\" to "$2" database..."
cd $1".data"

for table in *
	do
		if [ -s $table ]; then
			mysql --execute "Load data inFile '"$(pwd)"/"$table"' into table "$table $2 2>> $1".restore.log" &
		fi
	done

echo "Waiting..."
( time wait ) 2>> $1".restore.log"
echo >> $1".restore.log"
exit 0
