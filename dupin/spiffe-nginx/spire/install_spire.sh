#!/bin/bash

declare -r SPIRE_URL="http://s3.us-east-2.amazonaws.com/scytale-artifacts/spire/spire-b90d108-linux-x86_64-glibc.tar.gz"
declare -r SPIRE_DIR="/opt/spire"

curl --progress-bar --location ${SPIRE_URL} | tar xzf -
rm -rf ${SPIRE_DIR}
mv -v spire /opt/spire/
chmod -R 777 ${SPIRE_DIR}
mkdir ${SPIRE_DIR}/.data

# Clean installation files
rm install_spire.sh