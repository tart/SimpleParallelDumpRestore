#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

mysqldump --no-data --routines $1 > $1"Schema.sql"
mkdir $1"Data.sql"

tables=$(mysql --execute "Show tables" $1 | sed -e "/^Tables/d" -e "/^View/d" | sed -e :a -e '$!N; s/\n/ /; ta')
for table in $tables
	do
		mysqldump --no-create-info --skip-add-locks $1 $table > $1"Data.sql/"$table".sql" &
	done
