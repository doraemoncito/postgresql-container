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
    && ln -s /usr/local/bin/docker-entrypoint.sh /

# Variables required for the schema migration (i.e. flyway)
ENV PGDATA=/var/lib/postgresql-static/data \
    POSTGRES_DB=postgres \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=password \
    PGPORT=5432 \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk

# Invoke entrypoint to create and populate the database with flyway, then exit.  Please note that we use the
# --version switch to prevent docker-entrypoint.sh from leaving postgres running after the image is built.
RUN ["docker-entrypoint.sh", "postgres", "--version"]
