#!/usr/bin/env bash
export JAVA_OPTS="$JAVA_OPTS -Dtasks.service=http://localhost:8003/tasks/"
/opt/tomcat/bin/catalina.sh run
