#!/usr/bin/env bash

exec /usr/local/bin/envoy -c ./envoy.yaml --log-path /opt/spiffe-helper/logs/envoy.log --restart-epoch $RESTART_EPOCH
