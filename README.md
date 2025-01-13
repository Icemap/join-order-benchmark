# Join-Order-Benchmark

This package contains the Join Order Benchmark (JOB) queries from:
"[How Good Are Query Optimizers, Really?](http://www.vldb.org/pvldb/vol9/p204-leis.pdf)"
by Viktor Leis, Andrey Gubichev, Atans Mirchev, Peter Boncz, Alfons Kemper, Thomas Neumann
PVLDB Volume 9, No. 3, 2015


The `csv_files/schematext.sql` and `queries/*.sql` are modified to MySQL syntax.


## Quick Start

1. Get the `imdb` dataset:
```bash
cd csv_files/
wget https://event.cwi.nl/da/job/imdb.tgz
tar -xvzf imdb.tgz
```
2. Create the database `imdbload`:
```bash
csv_files/schema-tidb.sql
```
3. Run the script:
```
./load_data.sh
```
If you encounter any access restrictions, please modify the configuration as follows:
```
mysql --local-infile=1 -h 127.0.0.1 -P 4000 -u root -D imdbload < $sql_file
```

## Order Problem

Please note that `queries/17b.sql` and `queries/8d.sql` may exhibit order issues due to the use of different order rules from MySQL. This is not a real bug.

## Improving TiDB Performance using Analyze Table
Please execute analyze_table.sql to optimize the TiDB performance.
