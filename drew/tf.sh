#!/bin/bash

declare -rx TF_VAR_REGION="us-east-2"
declare -rx TF_VAR_AZ="a"
declare -rx TF_VAR_CIDR="10.71.0.0/20"

declare -rx TF_VAR_TYPE="t2.micro"
declare -rx TF_VAR_SIZE="2"
declare -rx TF_VAR_PRICE="0.01"

declare -rx TF_VAR_SSH_PRIV_KEY="$PWD/drew_ssh_key"
declare -rx TF_VAR_SSH_PUB_KEY="${TF_VAR_SSH_PRIV_KEY}.pub"

if [[ ! -r $TF_VAR_SSH_PRIV_KEY ]]; then
	ssh-keygen -N '' -f $TF_VAR_SSH_PRIV_KEY
	chmod 600 $TF_VAR_SSH_PRIV_KEY
fi

tf_env() {
	echo "SSH_PRIV_KEY=${TF_VAR_SSH_PRIV_KEY}"
	terraform output | tr 'a-z' 'A-Z' | sed 's/ //g'
}

case $1 in
	packer)	packer build packer.json ;;
	env)	tf_env ;;
	*)		terraform "$@" ;;
esac
