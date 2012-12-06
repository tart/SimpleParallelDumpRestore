Simple scripts to dump and restore data in parallel as comma-seperated values (CSV)

## Usage:

./dumpMySQLDatabase.sh

./restoreMySQLSchema.sh \<oldSchemaName\> \<newSchemaName\>

## Description

Dumps and restores MySQL databases in parallel using GNU parallel tool [1] and database client executables.

Dump command creates a schema file and one comma separated data file for all tables with "Select ... into outFile"
statement with "mysql" command. Restore command executes this files using "Load data inFile" statement.

MySQL user with sufficient privileges should be specified in "my.cnf".

[1] http://www.gnu.org/software/parallel

## License

These scripts are released under the ISC License, whose text is included to the source files. The ISC License is
registered with and approved by the Open Source Initiative [1].

[1] http://opensource.org/licenses/isc-license.txt
