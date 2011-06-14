#!/bin/sh
 ##
 # Tart Database Operations
 # Simple MySQL Parallel Dump & Restore
 #
 # @author      Emre Hasegeli <hasegeli@tart.com.tr>
 # @date        2011-05-23
 ##

mysql $2 < $1"Schema.sql"

for table in $1"Data.sql"/*
	do
		mysql $2 < $table &
	done
