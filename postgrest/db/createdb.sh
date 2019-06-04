#!/bin/bash
source ./credentials.sh

createdb ${PGDATABASE} || exit 1
psql -c "ALTER DATABASE ${PGDATABASE} SET \"sys.jwt_secret\" TO \"$JWT_SECRET\"" || exit 1
exec ./deploy.sh
