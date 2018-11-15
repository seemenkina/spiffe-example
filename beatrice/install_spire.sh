#!/bin/bash

set -x

mode="$1"

SPIRE_TGZ="https://github.com/spiffe/spire/releases/download/0.2/spire-0.2-linux-x86_64-glibc.tar.gz"

sudo rm -rf /opt/spire*
curl --silent --location $SPIRE_TGZ | sudo tar --directory /opt -xzf -

cd /opt
sudo ln -s spire-* spire
sudo rm -rf /opt/spire/conf
sudo cp -r /extra_mount/spire-conf /opt/spire/conf

#sudo cp /extra_mount/systemd/spire-${mode}.service /etc/systemd/system/
#sudo systemctl daemon-reload
#sudo systemctl restart spire-${mode}.service


