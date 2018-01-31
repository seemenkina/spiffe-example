#!/bin/bash

set -x

NUM_WORKLOAD=${NUM_WORKLOAD:-10}

# set from drew.sh -> packer -> this script
#SPIRE_TGZ
#AWS_IID_TGZ
#AWS_RES_TGZ

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
ExecStart=/opt/spire/functional/tools/workload -timeout 120

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

