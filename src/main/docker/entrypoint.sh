#!/bin/bash

echo "Running flyway to update the PostgreSQL database"
PATH=$PATH:/flyway

echo "============================================================"
echo "         PATH: $PATH"
echo "       PGDATA: $PGDATA"
echo "  POSTGRES_DB: $POSTGRES_DB"
echo "POSTGRES_USER: $POSTGRES_USER"
echo "       PGPORT: $PGPORT"
echo "============================================================"

# Ensure that PostgreSQL is restarted after the authentication is set to trust instead of ident so that flyway can
# connect to the database to perform migration.  For more details please visit the PostgreSQL documentation page at
# https://www.postgresql.org/docs/11/client-authentication.html
pg_ctl --options "-c listen_addresses='localhost'" --wait restart

cd db
/flyway/flyway -user="$POSTGRES_USER" -password="$POSTGRES_PASSWORD" -configFiles=/db/configuration/postgres/flyway.properties -url="jdbc:postgresql://localhost:$PGPORT/$POSTGRES_DB?user=$POSTGRES_USER" -locations="filesystem:/db/migration" info migrate info
cd..

echo "entrypoint.sh Completed"
