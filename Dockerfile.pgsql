FROM postgres:10.11-alpine

COPY ./db/01-structure.sql /docker-entrypoint-initdb.d/
COPY ./db/02-project.sql /docker-entrypoint-initdb.d/
