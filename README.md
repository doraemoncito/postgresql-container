# PostgreSQL database with embedded schema migrator

Docker image containing a PostgreSQL database and a schema migrator to simplify database schema upgrades.

##Building the Docker image

###Using the Maven command line:

    mvn clean install

###Using the Docker command line:
From the top level directory, run the following command to copy the build assets to the target directory:

    mvn compile

The go to the target directory and invoke Docker build as shown here:
 
    pushd target/docker
    docker build . --tag localhost.localdomain/postgresql-container:latest --no-cache    
    popd

##Running the database

Use the following command to the start the Database in a background docker container:

    docker run -p 5432:5432 --name postgres -d localhost.localdomain/postgresql-container:latest
