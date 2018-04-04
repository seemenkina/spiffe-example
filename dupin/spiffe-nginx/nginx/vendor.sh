#!/bin/bash

declare -r PCRE_VERSION="8.41"
declare -r PCRE_URL="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz"
declare -r GRPC_VERSION="v1.9.1"
declare -r GRPC_URL="https://github.com/grpc/grpc"

declare -r VENDOR_DIR="/tmp/vendor"

set -e
[[ ${DEBUG} ]] && set -x

untar_url() {
	curl --progress-bar --location $1 | tar --directory ${VENDOR_DIR} -xzf -
}

do_pcre() {
	untar_url ${PCRE_URL}
	(
		cd ${VENDOR_DIR}/pcre-${PCRE_VERSION}
		./configure --prefix=/usr
		make
		make install
	)
}

do_grpc() {
	(
		cd ${VENDOR_DIR}
		rm -rf grpc
		git clone -b ${GRPC_VERSION} ${GRPC_URL}
		cd grpc
		git submodule update --init
		make
		make install
		cd third_party/protobuf
		make install
	)
}

mkdir -p ${VENDOR_DIR}
do_pcre
do_grpc
rm -rf ${VENDOR_DIR}
