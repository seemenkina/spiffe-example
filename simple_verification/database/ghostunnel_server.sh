#!/bin/bash

# Set default value for URI if not defined in the first argument
set -x
URI="$1"
if [ -z "$URI" ]; then
    URI="spiffe://blog.dev.example.org/path/service"
fi

ghostunnel server \
    --listen database:8002 \
    --target localhost:8001 \
    --keystore /keys/server.key.pem \
    --cacert /keys/ca-chain.cert.pem \
    --allow-uri-san $URI
