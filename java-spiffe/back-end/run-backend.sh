#!/usr/bin/env bash
su -c 'java -Dspiffe.endpoint.socket=/tmp/agent.sock \
            -Dtrusted.services.list=spiffe-id-whitelist \
            -jar back-end.jar' backend &

