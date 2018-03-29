#!/bin/bash

declare -rx TF_VAR_REGION="us-east-2"
declare -rx TF_VAR_AZ="a"
declare -rx TF_VAR_CIDR="10.70.0.0/24"

declare -rx TF_VAR_PRIVATE_IP_BLOG="10.70.0.10"
declare -rx TF_VAR_PRIVATE_IP_DATABASE="10.70.0.20"
declare -rx TF_VAR_PRIVATE_IP_SERVER="10.70.0.30"

declare -rx TF_VAR_SSH_PRIV_KEY="$PWD/demo_ssh_key"
declare -rx TF_VAR_SSH_PUB_KEY="$PWD/demo_ssh_key.pub"

declare -rx TF_VAR_SCRIPT_DIR="$PWD/../cadfael/remote"

if [[ ! -r $TF_VAR_SSH_PRIV_KEY ]]; then
	ssh-keygen -N '' -f $TF_VAR_SSH_PRIV_KEY
	chmod 600 $TF_VAR_SSH_PRIV_KEY
fi

tf_env() {
	echo "SSH_PRIV_KEY=${TF_VAR_SSH_PRIV_KEY}"
	terraform output | tr 'a-z' 'A-Z' | sed 's/ //g'
}

case $1 in
	env)	tf_env ;;
	*)		terraform "$@" ;;
esac
