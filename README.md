# PostgreSQL database with embedded schema migrator

Docker image containing a PostgreSQL database and a schema migrator to simplify database schema upgrades.


## Building the Docker image

Use the provided Makefile to build the Docker image and prepare the context:

```shell
make all
```

This will download Flyway, prepare the build context, and build the Docker image.

## Running the container

After building, run:

```shell
make run
```

Or directly with Docker:

```shell
docker run --name pg-flyway-test -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password -p 5432:5432 localhost.localdomain/postgresql-container:1.1.0-SNAPSHOT
```

## Connecting to the database

Use the following JDBC URL to connect to the database:

```text
jdbc:postgresql://localhost:5432/postgres
```

Username: `postgres` Password: `password`

## Schema migration

Flyway is integrated via the commandline tool in the Docker container. Migration scripts should be placed in:

`build/db/migration/`

Scripts must follow the naming pattern:

`SPRINT<zero padded three digit sprint number>_<zero padded two digit script order number>__<description>.sql`

Example: `SPRINT001_01__Initial_database_revision.sql`

## Cleaning up

To remove all build artifacts, Docker containers, and images, use:

```shell
make distclean
```

This will stop and remove the Docker container and image, and clean build artifacts.

## Makefile Output Suppression and Debug Mode

By default, all command output is sent to the console. Output suppression is now controlled by the `--silent` argument: when you run Make with `--silent`, output from Docker and other commands is hidden. If you want to see all command output (for troubleshooting or detailed build information), simply omit the `--silent` flag:

```shell
make <target>
```

To suppress output, use:

```shell
make --silent <target>
```

For more information, see the help target in the Makefile (`make help`).

## Resources

- [PostgreSQL](https://www.postgresql.org)
- [Flyway](https://flywaydb.org)
- [postgres - Docker Official Images](https://hub.docker.com/_/postgres)
- [Docker Library PostgreSQL on GitHub](https://github.com/docker-library/postgres)
- ["exec: \"docker-entrypoint.sh\": executable file not found in $PATH". #296](https://github.com/docker-library/postgres/issues/296)
- [Sending RUN ["docker-entrypoint.sh", "postgres", "--version"] output to the console during the build #718](https://github.com/docker-library/postgres/issues/718)
- [Functionalize the entrypoint to allow outside sourcing for extreme customizing of startup #496](https://github.com/docker-library/postgres/pull/496)
