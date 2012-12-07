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

(test $1 = "-h" || test $1 = "--help") && echo "Usage: $0 <mysql arguments except schema>" && exit 1

#
# Preparing the database server
#

slaveRunning=$(echo "Show status like 'Slave_running'" | mysql $@ | sed 1d | cut -f 2)
if [ "$slaveRunning" = "ON" ]; then
    echo "Stopping slave SQL thread..."
    echo "Stop slave sql_thread" | mysql $@
fi

echo "Locking tables..."
echo "Flush tables with read lock" | mysql $@

#
# Dumping
#

for schema in $(echo "Show schemas" | mysql $@ | sed 1d | sed /_schema$/d); do
    echo "Dumping data model of $schema..."
    mysqldump -dR $schema > $schema.dataModel.sql

    echo "Dumping data of $schema..."
    mkdir $schema.data
    chmod o+w $schema.data
    cd $schema.data
    ../dumpMySQL.sh $@ $schema
    cd ..
done

#
# Preparing the database server
#

echo "Unlocking tables..."
echo "Unlock tables" | mysql $@

echo "Flushing logs..."
echo "Flush logs" | mysql $@

echo "Saving master status..."
echo "Show master status" | mysql $@ > masterStatus

if [ "$slaveRunning" = "ON" ]; then
    echo "Saving slave status..."
    echo "Show slave status" | mysql $@ > slaveStatus

    echo "Starting slave SQL thread..."
    echo "Start slave sql_thread" | mysql $@
fi

exit 0
