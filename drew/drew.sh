#!/bin/bash

declare -rx TF_VAR_SPIRE_TGZ="https://s3.us-east-2.amazonaws.com/scytale-artifacts/spire/spire-c37711f-linux-x86_64-glibc.tar.gz"
declare -rx TF_VAR_AWS_IID_TGZ="https://github.com/spiffe/aws-iid-attestor/releases/download/0.1/nodeattestor-aws_iid_0.1_linux_x86_64.tar.gz"
declare -rx TF_VAR_AWS_RES_TGZ="https://github.com/spiffe/aws-resolver/releases/download/0.1.1/noderesolver-aws_0.1.1_linux_x86_64.tar.gz"

declare -rx TF_VAR_REGION="us-east-2"
declare -rx TF_VAR_AZ="a"
declare -rx TF_VAR_CIDR="10.71.0.0/20"

declare -rx TF_VAR_TYPE="t2.micro"
declare -rx TF_VAR_AGENTS="${DEMO_AGENTS:-2}"
declare -rx TF_VAR_WORKLOADS="${DEMO_WORKLOADS:-20}"
declare -rx TF_VAR_PRICE="0.01"

declare -rx TF_VAR_SSH_PRIV_KEY="$PWD/drew_ssh_key"
declare -rx TF_VAR_SSH_PUB_KEY="${TF_VAR_SSH_PRIV_KEY}.pub"

if [[ ! -r $TF_VAR_SSH_PRIV_KEY ]]; then
	ssh-keygen -N '' -f $TF_VAR_SSH_PRIV_KEY
	chmod 600 $TF_VAR_SSH_PRIV_KEY
fi

drew_env() {
	echo "ssh_priv_key=${TF_VAR_SSH_PRIV_KEY}"
	terraform output | sed 's/ //g'
}

drew_packer() {
	terraform get
	terraform apply -target=random_pet.demo -auto-approve
	eval $(drew_env)
	export demo_name
	packer build packer.json
}

drew_agents() {
	local _n _i=1
	eval $(drew_env)
	for _n in $(aws --output text ec2 describe-instances \
		--filter Name=tag:Name,Values=${demo_name}_spot_agent \
		| grep INSTANCES | awk '{print $17}'); do
			echo "public_ip_agent$((_i++))=$_n"
	done
}

drew_update() {
	local _tgz="$2"
	local _n

	eval $(drew_env)
	eval $(drew_agents)

	for _n in $public_ip_server $public_ip_agent1 $public_ip_agent2; do
		echo "=== $_n"
		cat $_tgz | ssh -i drew_ssh_key ubuntu@${_n} \
			tar --directory=/opt --exclude=spire/conf -xvzf -
	done
}

drew_ssh() {
	eval $(drew_env)
	eval $(drew_agents)
	case $2 in
		server) connect_host=$public_ip_server ;;
		agent) connect_host=$public_ip_agent1 ;;
		*) connect_host="$2" ;;
	esac
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $ssh_priv_key ubuntu@$connect_host
}

case $1 in
	packer)	drew_packer ;;
	env)	drew_env ;;
	ssh)	drew_ssh "$@" ;;
	agents)	drew_agents ;;
	update)	drew_update "$@" ;;
	*)		terraform get
			terraform "$@"
			;;
esac
