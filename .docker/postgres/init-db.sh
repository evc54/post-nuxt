#!/bin/bash

DIR=`dirname "$0"`

# set jwt secret
psql -v ON_ERROR_STOP=1 -U postgres -c "ALTER DATABASE ${POSTGRES_DB} SET \"sys.jwt_secret\" TO \"$JWT_SECRET\"" || exit 1
# create database structure and upload default data
for FILE in extensions roles types functions auth api data
do
  psql -v ON_ERROR_STOP=1 -U postgres --dbname "$POSTGRES_DB" < ${DIR}/sql/${FILE}.sql
done
