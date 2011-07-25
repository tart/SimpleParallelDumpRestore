#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

if [ -e $1".schema.sql" ]; then
	echo $1".schema.sql file exists."
	exit 1
fi

echo "Dump started:" > $1".dump.log"
date +%s >> $1".dump.log"
echo >> $1".dump.log"

echo "Master status:" >> $1".dump.log"
mysql --execute "Show master status;" >> $1".dump.log" 2>> $1".dump.log"
echo "Slave status:" >> $1".dump.log"
mysql --execute "Show slave status;" >> $1".dump.log" 2>> $1".dump.log"
echo >> $1".dump.log"

echo "Dumping schema to \""$1".schema.sql\"..."
mysqldump --no-data --routines $1 > $1".schema.sql" 2>> $1".dump.log"

echo "Schema dumped:" >> $1".dump.log"
date +%s >> $1".dump.log"
echo >> $1".dump.log"

mkdir $1".data"
chmod o+w $1".data"

echo "Dumping data to \""$1".data\"..."
tables=$(mysql --execute "Show full tables where Table_type = 'BASE TABLE';" $1 |
		sed "/^Tables/d" |
		sed "s/\tBASE TABLE//;")
for table in $tables
	do
		mysql --execute "Set sql_big_selects = 1;
				Set query_cache_type = 0;
				Select * from "$table" into outfile '"$(pwd)/$1".data"/$table"'" $1 2>> $1".dump.log" &
	done

echo "Waiting..."
wait

chmod go-rw $1"."*
chmod go-rw $1".data"/*

echo "All tables dumped:" >> $1".dump.log"
date +%s >> $1".dump.log"
echo >> $1".dump.log"

exit 0
