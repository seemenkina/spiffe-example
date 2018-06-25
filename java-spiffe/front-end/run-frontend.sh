#!/usr/bin/env bash
if [ -n "$1" ]; then
    USERNAME="$1"
else
   USERNAME="frontend"
fi
su -c 'java -Dspiffe.endpoint.socket=/tmp/agent.sock \
            -Dtasks.service=https://backend:3000/tasks/ \
            -Dtrusted.services.list=spiffe-id-whitelist \
            -jar front-end.jar' ${USERNAME}

