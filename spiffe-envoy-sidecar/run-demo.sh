#!/usr/bin/env bash

# Needed to use --workdir option in docker-compose exec
export COMPOSE_API_VERSION=1.35

docker-compose exec -d spire-server ./spire-server run
echo "Spire Server is running"

docker-compose exec -d spire-server ./create-entries.sh
echo "Entries Created"

OUTPUT1=$(docker-compose exec spire-server ./spire-server token generate -spiffeID spiffe://example.org/host1 2>&1)
TOKEN1=$( echo ${OUTPUT1} | cut -c8-43)

docker-compose exec -d --workdir /opt/spire backend ./spire-agent run -joinToken $(echo $TOKEN1)
echo "Spire Agent 1 is running"


OUTPUT2=$(docker-compose exec spire-server ./spire-server token generate -spiffeID spiffe://example.org/host2 2>&1)
TOKEN2=$( echo ${OUTPUT2} | cut -c8-43)

docker-compose exec -d --workdir /opt/spire frontend ./spire-agent run -joinToken $(echo $TOKEN2)
echo "Spire Agent 2 is running"


docker-compose exec -d backend /opt/back-end/start-tomcat.sh
echo "Tomcat Backend is running"

docker-compose exec -d frontend /opt/front-end/start-tomcat.sh
echo "Tomcat Frontend is running"
sleep 1

echo "Opening: http://localhost:9000/tasks"
xdg-open http://localhost:9000/tasks
