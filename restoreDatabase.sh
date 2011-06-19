#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

mysql $2 < $1".schema.sql" 2> $1".error.log"

cd $1".data"

for table in *".txt"
	do
		if [ -s $table ]; then
			mysql --execute "Load data inFile '"$(pwd)"/"$table"' into table "${table%.txt}"; $2 2> $1".error.log" &
		fi
	done

exit 0
