#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

mysqldump --no-data --routines $1 > $1".schema.sql" 2> $1".error.log"

mkdir $1".data"
chmod o+w $1".data"

tables=$(mysql --execute "Show full tables where Table_type = 'BASE TABLE';" $1 |
		sed "/^Tables/d" |
		sed "s/\tBASE TABLE//;")
for table in $tables
	do
		mysql --execute "Select SQL_NO_CACHE * from "$table" into outFile '"$(pwd)"/"$1".data/"$table"'" $1 2> $1".error.log" &
	done

exit 0
