#!/bin/bash

# TODO: get output of lsof, terminate if comman different than 'postgres' ( like connection with ssh...)

postgres_pid=$(pgrep -x postgres)
dump_tar_file=$1

if [[ -z $dump_tar_file ]]; then
  echo "Missing dump tar file. Exiting..."
  exit 1
fi

if [[ -z $postgres_pid ]]; then
  echo "Postgres process is not running. Exiting..."
  exit 1
fi 

file_type=$(file --mime-type -b $dump_tar_file)

if [ $file_type != 'application/x-tar' ]; then
  echo "Provided file is not tar archive. Exiting..."
  exit 1
fi

if [[ -z "${POSTGRES_USER}" ]]; then
  echo "Set POSTGRES_USER env variable first"
  echo "Example: export \$(cat .env | xargs) && restore_db.sh <dump_file>.tar"
  echo "Exiting..."
  exit 1
fi

if [[ -z "${POSTGRES_DB}" ]]; then
  echo "Set POSTGRES_DB env variable first"
  echo "Example: export \$(cat .env | xargs) && clear_db.sh <dump_file>.tar"
  echo "Exiting..."
  exit 1
fi

read -p "ARE YOU GOD DAMN SURE ABOUT THIS? [y/n] "  action

if [ $action == 'y' ]; then
    pg_restore -d $POSTGRES_DB $dump_tar_file -c -U $POSTGRES_USER
fi
