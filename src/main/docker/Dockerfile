FROM postgres:12-alpine
LABEL maintainer="jose.hernandez@bristolalumni.org.uk"
LABEL name="PostgreSQL 12 Database" vendor="Jose Hernandez"
EXPOSE 5432

RUN apk --no-cache update upgrade \
    && apk add --no-cache openjdk11

COPY db/ /db/
COPY entrypoint.sh /docker-entrypoint-initdb.d/entrypoint.sh
COPY flyway-commandline.tar.gz /flyway-commandline.tar.gz

# Install the flyway schema migrator
RUN tar -pxzf flyway-commandline.tar.gz \
    && rm flyway-commandline.tar.gz \
    && mv /flyway-* /flyway \
    && rm -fr /flyway/jre \
    && chmod 777 -R /flyway /db /docker-entrypoint-initdb.d/entrypoint.sh \
# Later versions of the base Dockerfile (e.g. postgres:10-alpine) appear to be missing the symbolic link present in
# earlier versions. This next line is intended to keep this Dockerfile compatible with all postgres base Docker images.
# See ["exec: \"docker-entrypoint.sh\": executable file not found in $PATH". #296](https://github.com/docker-library/postgres/issues/296)
# for more details.
    && if [ ! -L "/docker-entrypoint.sh" ]; then ln -s /usr/local/bin/docker-entrypoint.sh /; fi

# Variables required for the schema migration (i.e. flyway)
ENV PGDATA=/var/lib/postgresql-static/data \
    POSTGRES_DB=postgres \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=password \
    PGPORT=5432 \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk

RUN ["docker-entrypoint.sh", "postgres"]
