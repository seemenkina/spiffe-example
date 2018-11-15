#!/bin/bash

set -x

# wipe any exsting DB config
cat <<_EOF | sudo mysql || true
drop user 'dbuser'@'%';
drop database forum_db;
_EOF

cat <<_EOF | sudo mysql
create user 'dbuser'@'%' identified by 'badpass';
grant all on *.* to 'dbuser'@'%';
flush privileges;
create database forum_db;
_EOF

# restore our static forum_db dump
cat /extra_mount/blog/forum_db.dump | sudo mysql forum_db

# install and start spire-agent
/extra_mount/install_spire.sh agent

# build and install ghostunnel
/extra_mount/install_ghostunnel.sh

# install sidecar
/extra_mount/install_sidecar.sh

# drop user into /opt/spire dir
echo "cd /opt/spire" >> $HOME/.bashrc
