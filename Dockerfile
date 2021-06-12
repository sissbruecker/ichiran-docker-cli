FROM postgres:13.3-alpine

ARG DB_DUMP_PATH
ARG JM_DICT_DB_PATH

# Hard-coded for now
ENV POSTGRES_PASSWORD postgres
# Use a custom data folder for Postgres
# The default folder will always be in a volume, which would not allow us to create an image from the seeded database
ENV PGDATA /var/lib/postgresql/static_data

### Postgres setup

# Copy script for creating ichiran database
COPY scripts/create-db.sql /docker-entrypoint-initdb.d/

# Copy database dump
WORKDIR /var/lib/postgresql
COPY $DB_DUMP_PATH ichiran.pgdump

### Ichiran setup

# Install dependencies
RUN apk add --no-cache sbcl curl git

# Collect ichiran sources into quicklisp local project storage
WORKDIR /root/quicklisp/local-projects

RUN git clone https://github.com/tshatrov/ichiran.git
COPY scripts/settings.lisp ichiran/

# Collect build files into /var/lib/ichiran-cli
WORKDIR /var/lib/ichiran-cli

COPY scripts/build-cli.lisp .
COPY scripts/build-cli.sh .
COPY $JM_DICT_DB_PATH ./jmdictdb
RUN curl -O https://beta.quicklisp.org/quicklisp.lisp
RUN chmod +x build-cli.sh
