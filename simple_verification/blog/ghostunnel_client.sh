#!/bin/bash

set -x
ghostunnel client \
    --listen localhost:8003 \
    --target database:8002 \
    --keystore /keys/client.key.pem \
    --cacert /keys/ca-chain.cert.pem
