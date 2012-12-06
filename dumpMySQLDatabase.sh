#!/bin/bash
##
# SimpleParallelDumpRestore - Simple scripts to dump and restore data in parallel as comma-seperated values (CSV)
#
# Copyright (c) 2011-2012, Tart İnternet Teknolojileri AŞ
#
# Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby
# granted, provided that the above copyright notice and this permission notice appear in all copies.
# 
# The software is provided "as is" and the author disclaims all warranties with regard to the software including all
# implied warranties of merchantability and fitness. In no event shall the author be liable for any special, direct,
# indirect, or consequential damages or any damages whatsoever resulting from loss of use, data or profits, whether
# in an action of contract, negligence or other tortious action, arising out of or in connection with the use or
# performance of this software.
##

#
# Fetching the parameters
#

while getopts "j:" opt; do
	case $opt in
		j )	jobs="-j $OPTARG " ;;
		h )	echo "a script to dump MySQL database parallel"
			echo "Usage:"
			echo "$0 -h"
			echo "$0 [-j jobs]"
			echo "Source:"
			echo "github.com/tart/SimpleParallelDumpRestore"
			exit 1 ;;
		\? )	echo "Wrong parameter." > /dev/stderr
			exit 1
	esac
done

#
# Preparing the database server
#

slaveRunning=$(mysql -e "Show status like 'Slave_running'" |
        sed 1d | cut -f 2)
if [ "$slaveRunning" = "ON" ]; then
    echo "Stopping slave SQL thread..."
    mysql -e "Stop slave sql_thread"
fi

echo "Locking tables..."
mysql -e "Flush tables with read lock"

#
# Dumping
#

for schema in $(mysql -e "Show schemas" | sed 1d | sed /_schema$/d); do
    tables=$(mysql -e "Show full tables where Table_type = 'BASE TABLE'" $schema |
            sed 1d | sed /_log$/d | cut -f 1)
    if [ "$tables" ]; then
	    echo "Dumping data model of $schema..."
	    mysqldump -dR $schema > $schema.dataModel.sql
	
	    echo "Dumping data of $schema..."
	    mkdir $schema.data
	    chmod o+w $schema.data
	    parallel $jobs"mysql -e \"Select * from {} \
            into outfile '$(pwd)/$schema.data/{}.csv' character set 'utf8' \
            fields terminated by ',' enclosed by '\\\"'\" $schema" ::: $tables
    fi
done

#
# Preparing the database server
#

echo "Unlocking tables..."
mysql -e "Unlock tables"

echo "Flushing logs..."
mysql -e "Flush logs"

echo "Dumping master status..."
mysql -e "Show master status" > masterStatus

if [ "$slaveRunning" = "ON" ]; then
    echo "Dumping slave status..."
    mysql -e "Show slave status" > slaveStatus

    echo "Starting slave activity..."
    mysql -e "Start slave"
fi

exit 0
