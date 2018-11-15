#!/bin/bash

set -x

# install and start spire-agent
/extra_mount/install_spire.sh agent

# drop user into /opt/spire dir
echo "cd /opt/spire" >> $HOME/.bashrc
