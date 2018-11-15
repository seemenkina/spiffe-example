#!/bin/bash

cat << _EOF > sidecar_config.hcl
agentAddress = "$AGENT_SOCKET"
ghostunnelCmd = "$HOME/ghostunnel"
ghostunnelArgs = "client --listen $LISTEN --target $UPSTREAM --verify-spiffe-id spiffe://example.org/Database"
certDir = "certs"
_EOF

mkdir -p certs

while true; do
	./sidecar
	sleep 1
done
