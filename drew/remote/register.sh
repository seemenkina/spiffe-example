#!/bin/bash

sleep 2
while ! /opt/spire/spire-server entry create -data /opt/spire/conf/registration.json; do
	sleep 1
done
