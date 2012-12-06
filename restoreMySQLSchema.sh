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
        Load data infile '$(pwd)/{}' into table {/.} character set 'utf8' \
        fields terminated by ',' enclosed by '\\\"'\" $2" ::: $(ls $1.data/*)

exit 0
