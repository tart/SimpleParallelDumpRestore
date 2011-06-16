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
		mysqldump --no-create-info --tab $1".data" $1 $table 2> $1".error.log" &
	done

exit 0
