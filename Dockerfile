FROM postgres:15
RUN apt-get upgrade
RUN apt-get update
RUN apt-get install gcc make libsodium-dev pgxnclient postgresql-server-dev-15 nodejs -y
RUN pgxn install --pg_config /usr/lib/postgresql/15/bin/pg_config pgsodium
RUN echo "shared_preload_libraries='pgsodium'" >> /usr/share/postgresql/postgresql.conf.sample