FROM postgres:13.3-alpine

ARG DB_DUMP_PATH

# Hard-coded for now
ENV POSTGRES_PASSWORD postgres
# Use a custom data folder for Postgres
# The default folder will always be in a volume, which would not allow us to create an image from the seeded database
ENV PGDATA /var/lib/postgresql/static_data

# Copy script for creating ichiran database
COPY images/database/create-db.sql /docker-entrypoint-initdb.d/

# Copy database dump
WORKDIR /var/lib/postgresql
COPY $DB_DUMP_PATH ichiran.pgdump
