FROM postgres:alpine
COPY init.sh /docker-entrypoint-initdb.d
COPY tasks.sql .
CMD [ "postgres" ]


# Create user for backend workload
#RUN useradd backend -u 1000

# Configure Spire Agent
#COPY agent.conf /opt/spire/conf/agent/agent.conf



