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
docker run -p 5432:5432 --name postgres -d localhost.localdomain/postgresql-container:1.0.0-SNAPSHOT
```

## Connecting to the database

Use the following JDBC URL to connect to the database:

```text
jdbc:postgresql://localhost:5432/postgres
```

## Resources

- [postgres - Docker Official Images](https://hub.docker.com/_/postgres)
- [Docker Library PostgreSQL on GitHub](https://github.com/docker-library/postgres)
- ["exec: \"docker-entrypoint.sh\": executable file not found in $PATH". #296](https://github.com/docker-library/postgres/issues/296)
- [Sending RUN ["docker-entrypoint.sh", "postgres", "--version"] output to the console during the build #718](https://github.com/docker-library/postgres/issues/718)
