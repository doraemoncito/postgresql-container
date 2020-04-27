#!/bin/bash

#!/usr/bin/env bash
set -Eeo pipefail

# Example using the functions of the postgres entry point to customize startup to always run files in /always-initdb.d/

source "$(which docker-entrypoint.sh)"

docker_setup_env
docker_create_db_directories
# assumption: we are already running as the owner of PGDATA

# This is needed if the container is started as `root`
if [ "$1" = 'postgres' ] && [ "$(id -u)" = '0' ]; then
	exec su-exec postgres "$BASH_SOURCE" "$@"
fi

echo "Running flyway to update the PostgreSQL database"
PATH=$PATH:/flyway

echo "============================================================"
echo "                PATH: ${PATH}"
echo "              PGDATA: ${PGDATA}"
echo "         POSTGRES_DB: ${POSTGRES_DB}"
echo "       POSTGRES_USER: ${POSTGRES_USER}"
echo "              PGPORT: ${PGPORT}"
echo "POSTGRES_INITDB_ARGS: ${POSTGRES_INITDB_ARGS}"
echo "============================================================"

if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
	docker_verify_minimum_env
	docker_init_database_dir
	pg_setup_hba_conf

	# only required for '--auth[-local]=md5' on POSTGRES_INITDB_ARGS
	export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"

	docker_temp_server_start "$@" -c max_locks_per_transaction=256
	docker_setup_db

  # Ensure that PostgreSQL is restarted after the authentication is set to trust instead of ident so that flyway can
  # connect to the database to perform migration.  For more details please visit the PostgreSQL documentation page at
  # https://www.postgresql.org/docs/11/client-authentication.html
  pg_ctl --options "-c listen_addresses='localhost'" --wait restart

  /flyway/flyway -user="$POSTGRES_USER" -password="$POSTGRES_PASSWORD" -configFiles=/db/configuration/postgres/flyway.properties -url="jdbc:postgresql://localhost:$PGPORT/$POSTGRES_DB?user=$POSTGRES_USER" -locations="filesystem:/db/migration" info migrate info || exit 1

	docker_process_init_files /docker-entrypoint-initdb.d/*

	docker_temp_server_stop
else
	docker_temp_server_start "$@"

  # Ensure that PostgreSQL is restarted after the authentication is set to trust instead of ident so that flyway can
  # connect to the database to perform migration.  For more details please visit the PostgreSQL documentation page at
  # https://www.postgresql.org/docs/11/client-authentication.html
  pg_ctl --options "-c listen_addresses='localhost'" --wait restart

  /flyway/flyway -user="$POSTGRES_USER" -password="$POSTGRES_PASSWORD" -configFiles=/db/configuration/postgres/flyway.properties -url="jdbc:postgresql://localhost:$PGPORT/$POSTGRES_DB?user=$POSTGRES_USER" -locations="filesystem:/db/migration" info migrate info || exit 1

	docker_process_init_files /always-initdb.d/*
	docker_temp_server_stop
fi

echo "entrypoint.sh Completed"
