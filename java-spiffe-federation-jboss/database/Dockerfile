FROM postgres:alpine
COPY init.sh /docker-entrypoint-initdb.d
COPY tasks.sql .
CMD [ "postgres" ]

