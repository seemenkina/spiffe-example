#!/bin/bash


docker-compose exec -d spire-server-frontend ./spire-server run
echo "Spire Server-Frontend is running"

docker-compose exec -d spire-server-backend ./spire-server run
echo "Spire Server-Backend is running"

docker-compose exec spire-server-frontend ./spire-server bundle show > bundle1.pem
docker-compose exec spire-server-backend ./spire-server bundle show > bundle2.pem

docker cp bundle2.pem spire-server-frontend:/opt/spire
docker cp bundle1.pem spire-server-backend:/opt/spire
rm bundle1.pem
rm bundle2.pem

docker-compose exec spire-server-frontend ./spire-server bundle set -id spiffe://second-domain.test -path bundle2.pem
docker-compose exec spire-server-backend ./spire-server bundle set -id spiffe://first-domain.test -path bundle1.pem

docker-compose exec spire-server-frontend ./spire-server entry create -parentID spiffe://first-domain.test/host -spiffeID spiffe://first-domain.test/front-end -federatesWith spiffe://second-domain.test -selector unix:uid:1000 -ttl 60
docker-compose exec spire-server-backend ./spire-server entry create -parentID spiffe://second-domain.test/host -spiffeID spiffe://second-domain.test/back-end  -federatesWith spiffe://first-domain.test -selector unix:uid:1000 -ttl 60


OUTPUT1=$(docker-compose exec spire-server-frontend ./spire-server token generate -spiffeID spiffe://first-domain.test/host 2>&1)
TOKEN1=$( echo ${OUTPUT1} | cut -c8-43)

docker-compose exec -d frontend ./spire-agent run -joinToken $(echo $TOKEN1)
sleep 1
echo "Spire Agent - Frontend is running"


OUTPUT2=$(docker-compose exec spire-server-backend ./spire-server token generate -spiffeID spiffe://second-domain.test/host 2>&1)
TOKEN2=$( echo ${OUTPUT2} | cut -c8-43)

docker-compose exec -d backend ./spire-agent run -joinToken $(echo $TOKEN2)
sleep 1
echo "Spire Agent - Backend is running"


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


