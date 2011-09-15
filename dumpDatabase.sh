#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

if [ -e slaveStatus ]
    then
        echo "File matching \"slaveStatus\" exists." > /dev/stderr

        exit 1
    fi

if [ -e masterStatus ]
    then
        echo "File matching \"masterStatus\" exists." > /dev/stderr

        exit 1
    fi

slaveRunning=$(mysql -e "Show status like 'Slave_running'" | sed 1d | cut -f 2)
if [ $slaveRunning = "ON" ]
    then
        echo "Stopping slave activity..."
        mysql -e "Stop slave"
    fi

for schema in $(mysql -e "Show schemas" | sed 1d)
    do
        if [ -e $schema"."* ]
            then
                echo "File matching \""$schema".*\" exists." > /dev/stderr

                exit 1
            fi

        echo "Dumping data model of "$schema"..."
        mysqldump -dR $schema > $schema".dataModel.sql"

        echo "Dumping data of "$schema"..."
        mkdir $schema".data"
        chmod o+w $schema".data"
        for table in $(mysql -e "Show full tables where Table_type = 'BASE TABLE'" $schema | sed 1d | cut -f 1)
            do
                mysql -e "Set sql_big_selects = 1;
                        Set query_cache_type = 0;
                        Select * from "$table" into outfile '"$(pwd)/$schema".data"/$table"'" $schema &
            done
    done

echo "Dumping master status..."
mysql -e "Show master status" > masterStatus

if [ -s masterStatus ]
    then
        echo "Flushing logs..."
        mysql -e "Flush logs"
    fi

if [ $slaveRunning = "ON" ]
    then
        echo "Dumping slave status..."
        mysql -e "Show slave status" > slaveStatus

        echo "Starting slave activity..."
        mysql -e "Start slave"
    fi

wait
exit 0
