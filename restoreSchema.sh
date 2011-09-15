#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

echo "Restoring data model from \""$1".dataModel.sql\" to "$2" database..."
mysql $2 < $1".dataModel.sql"

echo "Restoring data from \""$1".data\" to "$2" database..."
for table in $1".data"/*
	do
		if [ -s $table ]
			then
				mysql -e "Set unique_checks = 0;
						Set foreign_key_checks = 0;
						Load data infile '"$(pwd)/$table"' into table "${table#$1".data/"} $2 &
			fi
	done
	
wait
exit 0
