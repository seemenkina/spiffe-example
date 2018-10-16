#!/usr/bin/env bash

# Needed to use --workdir option in docker-compose exec
export COMPOSE_API_VERSION=1.35

docker-compose exec -d spire-server ./spire-server run
sleep 1
echo "Spire Server is running"

docker-compose exec -d spire-server ./create-entries.sh
sleep 1
echo "Entries Created"

OUTPUT1=$(docker-compose exec spire-server ./spire-server token generate -spiffeID spiffe://example.org/host1 2>&1)
TOKEN1=$( echo ${OUTPUT1} | cut -c8-43)

docker-compose exec -d --workdir /opt/spire backend ./spire-agent run -joinToken $(echo $TOKEN1)
sleep 1
echo "Spire Agent 1 is running"


OUTPUT2=$(docker-compose exec spire-server ./spire-server token generate -spiffeID spiffe://example.org/host2 2>&1)
TOKEN2=$( echo ${OUTPUT2} | cut -c8-43)

docker-compose exec -d --workdir /opt/spire frontend ./spire-agent run -joinToken $(echo $TOKEN2)
sleep 1
echo "Spire Agent 2 is running"


docker-compose exec -d backend /opt/back-end/start-tomcat.sh
sleep 1
echo "Tomcat Backend is running"

docker-compose exec -d frontend /opt/front-end/start-tomcat.sh
sleep 1
echo "Tomcat Frontend is running"

echo "Opening: http://localhost:9000/tasks"

case $(uname) in
    Darwin) open http://localhost:9000/tasks
            ;;
    Linux)    xdg-open http://localhost:9000/tasks
            ;;
esac
