#!/bin/bash
source ./credentials.sh

psql ${PGDATABASE} < sql/extensions.sql
psql ${PGDATABASE} < sql/roles.sql
psql ${PGDATABASE} < sql/types.sql
psql ${PGDATABASE} < sql/functions.sql
psql ${PGDATABASE} < sql/auth.sql
psql ${PGDATABASE} < sql/api.sql
psql ${PGDATABASE} < sql/data.sql
