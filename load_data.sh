#!/bin/bash
set -e

TASKNUM=5
trap "exec 1000>&-;exec 1000<&-;exit 0" 2
tempfifo=$$.fifo 
mkfifo $tempfifo
exec 1000<>$tempfifo
rm -rf $tempfifo

MYSQL_HOST=${MYSQL_HOST:-127.0.0.1}
MYSQL_PORT=${MYSQL_PORT:-4000}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PSWD=${MYSQL_PSWD:-}
DB_NAME=imdbload

# Create database and schema
COMMON_ARGS=(--protocol tcp -h"${MYSQL_HOST}" --port "${MYSQL_PORT}" -u"${MYSQL_USER}")
if [ -n "${MYSQL_PSWD}" ]; then
  COMMON_ARGS+=( -p"${MYSQL_PSWD}" )
fi

mysql "${COMMON_ARGS[@]}" < schema-tidb.sql | cat

for ((i=1; i<=$TASKNUM; i++))
do
    echo >&1000
done

load_data() {
  CURDIR=$(cd `dirname $0`; pwd)
  PREFIX=$CURDIR/csv_files/
  for csv_file in `ls $CURDIR/csv_files/*.csv`; do
    read -u1000

    bname=${csv_file%.*}
    table=${bname#$PREFIX}
    sql="LOAD DATA LOCAL INFILE '$csv_file' INTO TABLE $table FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"';"
    {
       mysql --local-infile=1 "${COMMON_ARGS[@]}" -D imdbload -e "$sql"
       echo >&1000
    }& 
  done
}

load_data
wait
echo "done!!!!!!!!!!"
