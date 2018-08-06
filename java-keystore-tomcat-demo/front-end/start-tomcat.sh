#!/usr/bin/env bash

if [ -n "$1" ]; then
    USERNAME="$1"
else
   USERNAME="frontend"
fi

export JAVA_OPTS="$JAVA_OPTS -Dtasks.service=https://backend:8443/tasks/ -Djava.security.properties=/opt/front-end/java.security"
export SPIFFE_ENDPOINT_SOCKET=/tmp/agent.sock
su -c "/opt/tomcat/bin/catalina.sh run" ${USERNAME}
