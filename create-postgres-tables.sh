#!/bin/bash
echo "
CREATE SCHEMA tpch; 
CREATE SCHEMA tpcds;
CALL dbgen(sf=1, schema='tpch');
CALL dsdgen(sf=1, schema='tpcds');
EXPORT DATABASE '/tmp/postgresscannertmp';
" | \
./duckdb/build/release/duckdb 

dropdb postgresscanner
createdb postgresscanner

psql -d postgresscanner < /tmp/postgresscannertmp/schema.sql
psql -d postgresscanner < /tmp/postgresscannertmp/load.sql
rm -rf /tmp/postgresscannertmp

echo "
create table nulltest (c1 integer, c2 integer, c3 integer, c4 integer, c5 integer, c6 integer, c7 integer, c8 integer, c9 integer, c10 integer);
insert into nulltest values (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
insert into nulltest values (1, NULL, 3, 4, NULL, 6, 7, 8, NULL, 10);
insert into nulltest values (NULL, NULL, 3, 4, 5, 6, 7, NULL, NULL, NULL);
insert into nulltest values (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
" | psql -d postgresscanner

psql -d postgresscanner -c "CHECKPOINT"
psql -d postgresscanner -c "VACUUM"