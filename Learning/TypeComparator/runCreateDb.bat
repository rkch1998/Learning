@echo off

set PGHOST=localhost
set PGPORT=5432
set PGUSER=postgres

psql  -h %PGHOST% -p %PGPORT% -U %PGUSER% -f D:\Learn\TypeComparator\db\createDb.sql
echo DB Created.
psql  -h %PGHOST% -p %PGPORT% -d practice -U %PGUSER% -f D:\Learn\TypeComparator\db\createType.sql
echo practice type created..
psql  -h %PGHOST% -p %PGPORT% -d practice2 -U %PGUSER% -f D:\Learn\TypeComparator\dbs\createType2.sql
echo practice2 type created..

pause > nul