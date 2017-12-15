

init:
	./tf.sh init

ami:
	./tf.sh packer

launch:
	./tf.sh apply -auto-approve

destroy:
	./tf.sh destroy -force

ssh:
	$(foreach v,$(shell ./tf.sh env), $(eval export $v))
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${ssh_priv_key} ubuntu@${public_ip_server}


