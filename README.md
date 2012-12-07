Simple scripts to dump and restore data in parallel as comma-seperated values (CSV)

## Usage:

dumpMySQL.sh \<mysql arguments\> 

restoreMySQL.sh \<mysql arguments\> 

restoreAllMySQL.sh \<mysql arguments except schema\> 

restorePostgreSQL.sh \<psql arguments\> 

## Description

Dumps and restores MySQL, PostgreSQL databases in parallel using GNU parallel tool [1] and database client executables.

Dump commands creates data files for all tables in parallel as comma-seperated value (CSV) in the working directory.
Restore commands restores data files in the working directory in parallel.

"Select ... into outfile" queries are used to dump from and "load data infile" queries are used to restore to MySQL.
"Copy" queries are used to dump from and restore to PostgreSQL.

dumpAllMySQL.sh is an helper to dump all schemas in a MySQL database with data models. It also locks tables before
dump, stopes and starts slave SQL thread, saves master and slave status.

[1] http://www.gnu.org/software/parallel

## License

These scripts are released under the ISC License, whose text is included to the source files. The ISC License is
registered with and approved by the Open Source Initiative [1].

[1] http://opensource.org/licenses/isc-license.txt
