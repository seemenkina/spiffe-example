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
	echo "ssh_priv_key=${TF_VAR_SSH_PRIV_KEY}"
	terraform output | sed 's/ //g'
}

tf_packer() {
	terraform apply -target=random_pet.demo >/dev/null
	eval $(tf_env)
	export demo_name
	packer build packer.json
}

terraform get
case $1 in
	packer)	tf_packer ;;
	env)	tf_env ;;
	*)		terraform "$@" ;;
esac
