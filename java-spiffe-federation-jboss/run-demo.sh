#!/bin/bash


docker-compose exec -d spire-server-1 ./spire-server run
echo "Spire Server-1 is running"

docker-compose exec -d spire-server-2 ./spire-server run
echo "Spire Server-2 is running"

docker-compose exec spire-server-1 ./spire-server bundle show > bundle1.pem
docker-compose exec spire-server-2 ./spire-server bundle show > bundle2.pem

docker cp bundle2.pem spire-server-1:/opt/spire
docker cp bundle1.pem spire-server-2:/opt/spire
rm bundle1.pem
rm bundle2.pem

docker-compose exec spire-server-1 ./spire-server bundle set -id spiffe://test.com -path bundle2.pem
docker-compose exec spire-server-2 ./spire-server bundle set -id spiffe://example.org -path bundle1.pem

docker-compose exec spire-server-1 ./spire-server entry create -parentID spiffe://example.org/host -spiffeID spiffe://example.org/front-end -federatesWith spiffe://test.com -selector unix:uid:1000
docker-compose exec spire-server-2 ./spire-server entry create -parentID spiffe://test.com/host -spiffeID spiffe://test.com/back-end  -federatesWith spiffe://example.org -selector unix:uid:1000


OUTPUT1=$(docker-compose exec spire-server-1 ./spire-server token generate -spiffeID spiffe://example.org/host 2>&1)
TOKEN1=$( echo ${OUTPUT1} | cut -c8-43)

docker-compose exec -d frontend ./spire-agent run -joinToken $(echo $TOKEN1)
sleep 1
echo "Spire Agent - Frontend is running"


OUTPUT2=$(docker-compose exec spire-server-2 ./spire-server token generate -spiffeID spiffe://test.com/host 2>&1)
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


