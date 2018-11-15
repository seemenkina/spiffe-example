#!/bin/bash

set -x

## complicated build of ghostunnel branch on a fork

GOLANG_URL=https://storage.googleapis.com/golang/go1.9.1.linux-amd64.tar.gz
GHOSTUNNEL_BRANCH=spiffe-support

sudo apt-get -y install build-essential libltdl-dev git

export PATH=/usr/local/go/bin:$HOME/go/bin:$PATH

# ghostunnel requires golang1.9, so we fetch a tarball
if ! which go; then
	curl --silent $GOLANG_URL | sudo tar --directory /usr/local -xzf -
fi

rm -rf $HOME/go
mkdir -p $HOME/go/src/github.com/spiffe
cd $HOME/go/src/github.com/spiffe
git clone --branch $GHOSTUNNEL_BRANCH  https://github.com/spiffe/ghostunnel.git
cd ghostunnel
go install

# send a copy to our container friend
cp $HOME/go/bin/ghostunnel /extra_mount/blog/container_ghostunnel/

# abusing .bash_aliases to ammend PATH, for convenience
echo "export PATH=/usr/local/go/bin:$HOME/go/bin:$PATH" > $HOME/.bash_aliases

