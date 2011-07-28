#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

dumpDatabaseCommand=$(pwd)"/"${0%scheduledDumpDatabase.sh}"dumpDatabase.sh "$1
directory=$(date +%u)

cd $2
if [ ! -d $directory ]; then
	mkdir $directory
fi

cd $directory
rm -rf "/"$1"."*
touch $1".scheduledDumpSlaveDatabase.error.log"

mysql --execute "Stop slave;" 2>> $1".scheduledDumpSlaveDatabase.error.log"
$dumpDatabaseCommand 2>> $1".scheduledDumpSlaveDatabase.error.log"
mysql --execute "Start slave;" 2>> $1".scheduledDumpSlaveDatabase.error.log"

if [ -s $1".scheduledDump.error.log" ]; then
	mail -s "Scheduled Dump Slave Database Error" $3 < $1".scheduledDumpSlaveDatabase.error.log"
fi

exit 0
