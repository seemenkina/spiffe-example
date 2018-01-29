#!/bin/bash

set -x

NUM_WORKLOAD=${NUM_WORKLOAD:-10}

#SPIRE_TGZ="https://github.com/spiffe/spire/releases/download/0.3pre1/spire-0.3pre1-linux-x86_64-glibc.tar.gz"
SPIRE_TGZ="https://s3.us-east-2.amazonaws.com/scytale-artifacts/spire/spire-156db7c-linux-x86_64-glibc.tar.gz"
AWS_IID_TGZ="https://github.com/spiffe/aws-iid-attestor/releases/download/0.1/nodeattestor-aws_iid_0.1_linux_x86_64.tar.gz"
AWS_RES_TGZ="https://github.com/spiffe/aws-resolver/releases/download/0.1/noderesolver-aws_0.1_linux_x86_64.tar.gz"

mode="$1"
sudo rm -rf /opt/spire*
curl --silent --location $SPIRE_TGZ | sudo tar --directory /opt -xzf -
curl --silent --location $AWS_IID_TGZ | sudo tar --directory /opt/spire* -xzf -
curl --silent --location $AWS_RES_TGZ | sudo tar --directory /opt/spire* -xzf -

cd /opt
ls opt/spire-* >/dev/null 2>&1 && sudo ln -s spire-* spire
sudo rm -rf /opt/spire/conf
sudo cp -r /tmp/remote/spire-conf /opt/spire/conf
sudo chown -R ubuntu:ubuntu /opt/spire*

sudo cp /tmp/remote/systemd/spire-${mode}.service /etc/systemd/system/
sudo systemctl enable spire-${mode}.service

mk_sysd() {
	local _n="$(printf '%03d' $1)"
	cat << _EOF | sudo tee /etc/systemd/system/spire-workload-${_n}.service >/dev/null
[Unit]
Description=spire-agent-${_n}

[Service]
Type=simple
User=user3${_n}
Restart=always
RestartSec=3
WorkingDirectory=/opt/spire
ExecStart=/opt/spire/functional/tools/workload -timeout 3

[Install]
WantedBy=multi-user.target
_EOF
    sudo adduser --quiet --system --uid 3${_n} user3${_n}
	sudo systemctl enable spire-workload-${_n}.service
}

echo "$mode" | sudo tee /etc/hostname >/dev/null
echo "127.0.0.1 $mode" | sudo tee -a /etc/hosts >/dev/null
sudo hostname $mode

if [[ $mode == "agent" ]]; then
	for n in $(seq 0 $((NUM_WORKLOAD - 1))); do
		mk_sysd $n
	done
else
	sudo cp /tmp/remote/register.sh /opt/spire/
fi

