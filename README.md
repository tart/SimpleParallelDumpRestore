## Usage:

./dumpDatabase.sh \<databaseName\>

./restoreDatabase.sh \<oldDatabaseName\> \<newDatabaseName\>


## Description

Dumps and restores all tables parallel in a database. Dump command creates a schema file and one data file for all tables. Restore file executes this files. Dump command catches views with "View" word.
