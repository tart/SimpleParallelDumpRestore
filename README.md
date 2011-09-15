## Usage:

./dumpDatabase.sh \<databaseName\>

./restoreSchema.sh \<oldSchemaName\> \<newSchemaName\>

## Description

Dumps and restores all tables parallel in a MySQL database.

Dump command creates a schema file and one data file for all
tables using "Select ... into outFile" statement with "mysqldump"
command. Restore command executes this files using "Load data
inFile" statement.

MySQL user with sufficient privileges should be specified in
"my.cnf".
