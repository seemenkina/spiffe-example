#!/bin/bash

set -x

# wait for registry to become available
while ! curl --silent --fail --output /dev/null localhost; do
	sleep 1
done

sudo docker build -t localhost/spiffe/blog:latest /extra_mount/blog/container_blog
sudo docker push localhost/spiffe/blog

sudo docker build -t localhost/spiffe/ghostunnel:latest /extra_mount/blog/container_ghostunnel
sudo docker push localhost/spiffe/ghostunnel

kubectl delete -f /extra_mount/blog/blog.yaml || true
kubectl create -f /extra_mount/blog/blog.yaml

# install and start spire-server
/extra_mount/install_spire.sh server

# drop user into /opt/spire dir
echo "cd /opt/spire" >> $HOME/.bashrc
