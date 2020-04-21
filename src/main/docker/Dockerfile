FROM postgres:12-alpine
LABEL maintainer="jose.hernandez@bristolalumni.org.uk"
LABEL name="PostgreSQL 12 Database" vendor="Jose Hernandez"
EXPOSE 5432

RUN apk --no-cache update upgrade && apk add --no-cache openjdk11 su-exec
COPY db/ /db/
COPY entrypoint.sh /entrypoint.sh
COPY flyway-commandline.tar.gz /flyway-commandline.tar.gz

# Install the flyway schema migrator
RUN tar -pxzf flyway-commandline.tar.gz \
    && rm flyway-commandline.tar.gz \
    && mv /flyway-* /flyway \
    && rm -fr /flyway/jre \
    && chmod 777 -R /flyway /db /entrypoint.sh

# Variables required for the schema migration (i.e. flyway)
ENV PGDATA=/var/lib/postgresql-static/data \
    POSTGRES_DB=postgres \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=password \
    PGPORT=5432 \
# Uncomment this line to use password authentication, instead of trust, inside the container.
# Please note that using trust authentication generates the following warning in the logs:
# initdb: warning: enabling "trust" authentication for local connections
#    POSTGRES_INITDB_ARGS="-A password" \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk

RUN ["/entrypoint.sh", "postgres"]
