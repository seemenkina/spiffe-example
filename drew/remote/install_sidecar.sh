#!/bin/bash

cd $HOME

SIDECAR_TGZ="https://github.com/spiffe/sidecar/releases/download/0.2/sidecar_0.2_linux_amd64.tar.gz"
sudo rm -rf /opt/sidecar
sudo mkdir -p /opt/sidecar/bin
sudo mkdir -p /certs
sudo chmod 777 /certs

curl --silent --location $SIDECAR_TGZ | sudo tar --directory /opt/sidecar/bin -xzf -
