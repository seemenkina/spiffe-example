#!/bin/bash

set -x

mode="$1"

SPIRE_TGZ="https://github.com/spiffe/spire/releases/download/0.3pre1/spire-0.3pre1-linux-x86_64-glibc.tar.gz"
AWS_IID_TGZ="https://github.com/spiffe/aws-iid-attestor/releases/download/0.1/nodeattestor-aws_iid_0.1_linux_x86_64.tar.gz"
AWS_RES_TGZ="https://github.com/spiffe/aws-resolver/releases/download/0.1/noderesolver-aws_0.1_linux_x86_64.tar.gz"

sudo rm -rf /opt/spire*
curl --silent --location $SPIRE_TGZ | sudo tar --directory /opt -xzf -
curl --silent --location $AWS_IID_TGZ | sudo tar --directory /opt/spire* -xzf -
curl --silent --location $AWS_RES_TGZ | sudo tar --directory /opt/spire* -xzf -

cd /opt
sudo ln -s spire-* spire
sudo rm -rf /opt/spire/conf
sudo cp -r /tmp/remote/spire-conf /opt/spire/conf
sudo chown -R ubuntu:ubuntu /opt/spire*

sudo cp /tmp/remote/systemd/spire-${mode}.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl restart spire-${mode}.service


