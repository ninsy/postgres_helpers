#!/bin/bash

# TODO: get output of lsof, terminate if comman different than 'postgres' ( like connection with ssh...)

postgres_pid=$(pgrep -x postgres)

if [[ -z $postgres_pid ]]; then
  echo "Postgres process is not running. Exiting..."
  exit 1
fi 

if [[ -z "${POSTGRES_USER}" ]]; then
  echo "Set POSTGRES_USER env variable first"
  echo "Example: export \$(cat .env | xargs) && clear_db.sh"
  echo "Exiting..."
  exit 1
fi

if [[ -z "${POSTGRES_DB}" ]]; then
  echo "Set POSTGRES_DB env variable first"
  echo "Example: export \$(cat .env | xargs) && clear_db.sh"
  echo "Exiting..."
  exit 1
fi

read -p "Do you want to dump current database? [y/n] " dumpAction
if [ $dumpAction == 'y' ]; then
  echo "Dumping current database..."
  pg_dump -U ${POSTGRES_USER} -F t ${POSTGRES_DB} > ${POSTGRES_DB}-$(date +%s).dump.tar
  echo "Done dumping db."
fi

read -p "ARE YOU GOD DAMN SURE ABOUT THIS? [y/n] "  action

if [ $action == 'y' ]; then
    pg_dump -U ${POSTGRES_USER} -v -Fc -s -f ${POSTGRES_DB}.schemas.dump ${POSTGRES_DB}
    dropdb -U ${POSTGRES_USER} ${POSTGRES_DB}
    createdb -U ${POSTGRES_USER} ${POSTGRES_DB}
    pg_restore -U ${POSTGRES_USER} -v -d ${POSTGRES_DB} ${POSTGRES_DB}.schemas.dump
fi