# PostgreSQL database with embedded schema migrator

Docker image containing a PostgreSQL database and a schema migrator to simplify database schema upgrades.

## Building the Docker image

### Using the Maven command line:

```shell script
mvn clean install
```

### Using the Docker command line:
From the top-level directory, run the following command to copy the build assets to the target directory:

```shell script
mvn compile
```

Then go to the target directory and invoke Docker build as shown here:

```shell script
pushd target/docker
docker build . --tag localhost.localdomain/postgresql-container:latest --no-cache    
popd
```

## Running the database

Use the following command to the start the Database in a background docker container:

```shell script
docker run -p 5432:5432 --name postgres -d localhost.localdomain/postgresql-container:latest
```

## Connecting to the database

Use the following JDBC URL to connect to the database:

```text
jdbc:postgresql://localhost:5432/postgres
```
## Extending the database schema

To extend the schema definition with the tables, data, etc, simply add new idempotent SQL scripts to the
`src/main/resources/db/migration/` folder.

The SQL script file names must follow the pattern
`SPRINT<zero padded three digit sprint number>_<zero padded two digit script order number>__<description>.sql`
as shown in this example: `SPRINT001_01__Initial_database_revision.sql`.

## Resources

- [PostgreSQL](https://www.postgresql.org)
- [Flyway](https://flywaydb.org)
- [postgres - Docker Official Images](https://hub.docker.com/_/postgres)
- [Docker Library PostgreSQL on GitHub](https://github.com/docker-library/postgres)
- ["exec: \"docker-entrypoint.sh\": executable file not found in $PATH". #296](https://github.com/docker-library/postgres/issues/296)
- [Sending RUN ["docker-entrypoint.sh", "postgres", "--version"] output to the console during the build #718](https://github.com/docker-library/postgres/issues/718)
- [Functionalize the entrypoint to allow outside sourcing for extreme customizing of startup #496](https://github.com/docker-library/postgres/pull/496)
