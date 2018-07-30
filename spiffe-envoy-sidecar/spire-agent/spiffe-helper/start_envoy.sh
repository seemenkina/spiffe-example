#!/usr/bin/env bash

exec /usr/local/bin/envoy -c ./envoy.yaml --restart-epoch $RESTART_EPOCH
