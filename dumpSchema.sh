#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-08-30
 ##

if [ -e $1"."* ]
	then
		echo "File matching \""$1".*\" exists." > /dev/stderr

		exit 1
	fi

mysqldump -dR $1 > $1".schema.sql"
echo "Data model of schema "$1" dumped to \"./"$1".schema.sql\"."

mkdir $1".data"
chmod o+w $1".data"
for table in $(mysql -e "Show full tables where Table_type = 'BASE TABLE'" $1 | sed 1d | cut -f 1)
	do
		mysql -e "Set sql_big_selects = 1;
				Set query_cache_type = 0;
				Select * from "$table" into outfile '"$(pwd)/$1".data"/$table"'" $1 &
	done
echo "Commands to dump data from schema "$1" to \"./"$1".data\" sent."

wait
exit 0
