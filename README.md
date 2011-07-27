## Usage:

./dumpDatabase.sh \<databaseName\>

./restoreDatabase.sh \<oldDatabaseName\> \<newDatabaseName\>

./scheduledDumpSlaveDatabase.sh \<oldDatabaseName\> \<dumpDirectory\> \<emailAddress\>

## Description

Dumps and restores all tables parallel in a MySQL database.

Dump command creates a schema file and one data file for all
tables using "Select ... into outFile" statement with "mysqldump"
command. Restore command executes this files using "Load data
inFile" statement.

Commands create log files. Log files include errors and times
as Unix time.

MySQL user with sufficient privileges should be specified in
"my.cnf".
