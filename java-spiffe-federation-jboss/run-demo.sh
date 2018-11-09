#!/bin/bash

echo "Starting Demo components"

docker-compose exec -d spire-server-frontend ./spire-server run
echo "SPIRE Server-Frontend is running"

docker-compose exec -d spire-server-backend ./spire-server run
echo "SPIRE Server-Backend is running"
echo "-------------------------------"

echo "Set Federated Bundles"
docker-compose exec spire-server-frontend ./spire-server bundle show > first-domain.pem
docker-compose exec spire-server-backend ./spire-server bundle show > second-domain.pem

docker cp second-domain.pem spire-server-frontend:/opt/spire
docker cp first-domain.pem spire-server-backend:/opt/spire
rm first-domain.pem
rm second-domain.pem

docker-compose exec spire-server-frontend ./spire-server bundle set -id spiffe://second-domain.test -path second-domain.pem
docker-compose exec spire-server-backend ./spire-server bundle set -id spiffe://first-domain.test -path first-domain.pem

echo ""
echo "Creating Registration Entry in SPIRE Server-Frontend"
docker-compose exec spire-server-frontend ./spire-server entry create -parentID spiffe://first-domain.test/host -spiffeID spiffe://first-domain.test/front-end -federatesWith spiffe://second-domain.test -selector unix:uid:1000

echo ""
echo "Creating Registration Entry in SPIRE Server-Backend"
docker-compose exec spire-server-backend ./spire-server entry create -parentID spiffe://second-domain.test/host -spiffeID spiffe://second-domain.test/back-end  -federatesWith spiffe://first-domain.test -selector unix:uid:1000


OUTPUT1=$(docker-compose exec spire-server-frontend ./spire-server token generate -spiffeID spiffe://first-domain.test/host 2>&1)
TOKEN1=$( echo ${OUTPUT1} | cut -c8-43)

docker-compose exec -d frontend ./spire-agent run -joinToken $(echo $TOKEN1)
sleep 1
echo "SPIRE Agent - Frontend is running"


OUTPUT2=$(docker-compose exec spire-server-backend ./spire-server token generate -spiffeID spiffe://second-domain.test/host 2>&1)
TOKEN2=$( echo ${OUTPUT2} | cut -c8-43)

docker-compose exec -d backend ./spire-agent run -joinToken $(echo $TOKEN2)
sleep 1
echo "SPIRE Agent - Backend is running"


docker-compose exec -d backend /opt/nginx/nginx
sleep 1
echo "NGINX is running"

docker-compose exec -d frontend /opt/front-end/start-jboss.sh
sleep 3
echo "JBOSS is running"
echo "------------------"
echo "Checking health..."

RESPONSE=$(curl -Is http://localhost:9000/tasks | head -n 1)

if [[ $RESPONSE = *"200"* ]]; then
  echo "Health Check: OK"
  echo -e "------------------"
  echo "Open in a browser: http://localhost:9000/tasks"
fi

if [[ $RESPONSE = *"500"* ]]; then
  echo "Health Check: ERROR"
  echo "Troubleshooting: Check that the containers, servers, agents, proxy and jboss are running."
  echo "For more information see Demo step by step in README"
fi


