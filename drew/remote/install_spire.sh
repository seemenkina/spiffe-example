#!/bin/bash

[[ $DEBUG ]] && set -x
set -e

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
	local _n="$(printf '%03d' $n)"
	local _user=user3${_n} _uid=3${_n}

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
	if ! id $_user >/dev/null 2>&1; then
		sudo adduser --quiet --system --uid $_uid $_user
		sudo systemctl enable spire-workload-${_n}.service
	fi
	if [[ -n $RECONFIGURE ]]; then
		sudo systemctl restart spire-workload-${_n}.service
	fi
}

if [[ $mode == "agent" ]]; then
	for n in $(seq 0 $((NUM_WORKLOAD - 1))); do
		mk_sysd $n
	done
	cat << _EOF | sudo tee /etc/rsyslog.d/99-spire-agent.conf >/dev/null
*.*     @@10.71.0.10:514
_EOF
fi

if [[ $mode == "server" ]]; then
	sudo cp /tmp/remote/register.sh /opt/spire/
	cat << _EOF | sudo tee /etc/rsyslog.d/99-spire-agent.conf >/dev/null
module(load="imtcp")
input(type="imtcp" port="514")
_EOF
fi

if [[ -n $RECONFIGURE ]]; then
	sudo systemctl restart rsyslog
fi

