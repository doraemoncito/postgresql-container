FROM postgres:16-alpine
LABEL maintainer="13024293+doraemoncito@users.noreply.github.com"
LABEL name="PostgreSQL 16; JDK 21" vendor="José Hernández"
EXPOSE 5432

COPY flyway-commandline.tar.gz /flyway-commandline.tar.gz
RUN apk --no-cache update upgrade && apk add --no-cache openjdk21-jdk su-exec \
    && mkdir -p /flyway \
    && tar -xzf /flyway-commandline.tar.gz -C /flyway --strip-components=1 \
    && rm /flyway-commandline.tar.gz
COPY db/ /db/
COPY entrypoint.sh /entrypoint.sh

# Variables required for the schema migration (i.e. flyway)
ENV PGDATA=/var/lib/postgresql-static/data \
    POSTGRES_DB=postgres \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=password \
    PGPORT=5432 \
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk \
    PATH=/flyway:$PATH

# NOTE: Uncomment the line below use password authentication, instead of trust,
# inside the container.   Please note that using trust authentication generates
# the following warning in the logs:
#       initdb: warning: enabling "trust" authentication for local connections
#
# POSTGRES_INITDB_ARGS="-A password"
