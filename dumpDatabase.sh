#!/bin/bash
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
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
			echo "github.com/tart/SimpleMySQLParallelDumpRestore"
			exit 1 ;;
		\? )	echo "Wrong parameter." > /dev/stderr
			exit 1
	esac
done

if [ -e slaveStatus ]; then
    echo "File matching \"slaveStatus\" exists." > /dev/stderr

    exit 1
fi

if [ -e masterStatus ]; then
    echo "File matching \"masterStatus\" exists." > /dev/stderr

    exit 1
fi

#
# Preparing the database server
#

slaveRunning=$(mysql -e "Show status like 'Slave_running'" | sed 1d | cut -f 2)
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
    tables=$(mysql -e "Show full tables where Table_type = 'BASE TABLE'" $schema | sed 1d | cut -f 1)

    echo "Dumping data model of $schema..."
    mysqldump -dR $schema > $schema.dataModel.sql

    echo "Dumping data of $schema..."
    mkdir $schema.data
    chmod o+w $schema.data
    parallel $jobs"mysql -e \"Select * from {} into outfile '\"$(pwd)/$schema.data/{}\"' character set 'utf8'\" $schema" ::: $tables
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
