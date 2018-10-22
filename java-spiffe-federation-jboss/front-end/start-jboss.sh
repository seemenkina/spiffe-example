#!/usr/bin/env bash

# Define PostgreSQL connection properties
export JAVA_OPTS="$JAVA_OPTS -Dspring.config.location=/opt/front-end/database.properties"

# needed for JBOSS to work with Docker Compose
export JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true"

export SPIFFE_ENDPOINT_SOCKET=/tmp/agent.sock
su -c "/opt/jboss/bin/standalone.sh" frontend
