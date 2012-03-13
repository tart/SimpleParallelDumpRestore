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
		j )	jobs=$OPTARG ;;
		h )	echo "a script to restore MySQL schema parallel"
			echo "Usage:"
			echo "$0 -h"
			echo "$0 [-j jobs] <oldSchemaName> <newSchemaName>"
			echo "Source:"
			echo "github.com/tart/SimpleMySQLParallelDumpRestore"
			exit 1 ;;
		\? )	echo "Wrong parameter." > /dev/stderr
			exit 1
	esac
done

#
# Checking files
#

if [ ! -f $1.dataModel.sql ]; then
    echo "File matching \"$1.dataModel.sql\" does not exists." > /dev/stderr

    exit 1
fi

if [ ! -d $1.data ]; then
    echo "Directory matching \"$1.data\" does not exists." > /dev/stderr

    exit 1
fi

#
# Restoring
#

echo "Restoring data model from \""$1".dataModel.sql\" to "$2" database..."
mysql $2 < $1".dataModel.sql"

echo "Restoring data from \""$1".data\" to "$2" database..."
parallel $jobs"mysql -e \"Set unique_checks = 0; \
        Set foreign_key_checks = 0; \
        Load data infile '$(pwd)/{}' into table {/} character set 'utf8' \
        fields terminated by ',' enclosed by '\\\"'\" $2" ::: $(ls $1.data/*)

exit 0
