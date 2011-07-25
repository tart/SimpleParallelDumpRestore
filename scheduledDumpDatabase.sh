#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

dumpDatabaseCommand=$(pwd)"/"${0%scheduledDumpDatabase.sh}"dumpDatabase.sh "$1

cd $2
if [ -e $(date +%u) ]; then
	rm -rf $(date +%u)
fi

mkdir $(date +%u)
cd $(date +%u)

mysql --execute "Stop slave;" 2>> $1".scheduledDump.error.log"
$dumpDatabaseCommand
mysql --execute "Start slave;" 2>> $1".scheduledDump.error.log"

exit 0;
