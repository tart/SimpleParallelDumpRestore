#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

mysql $2 < $1".schema.sql"
echo "Data model restored from \"./"$1".schema.sql\" to schema "$2"."

for table in $1".data"/*
	do
		if [ -s $table ]
			then
				mysql -e "Set unique_checks = 0;
						Set foreign_key_checks = 0;
						Load data infile '"$(pwd)/$table"' into table "${table#$1".data/"} $2 &
			fi
	done
echo "Commands to restore data from \"./"$1".data\" to schema "$2" sent."

wait
exit 0
