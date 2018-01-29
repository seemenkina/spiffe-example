# AWS Attestation and Scale Demo

This demo will create a fleet of 10 EC2 spot instances and run
spire-agent and 10 dummy workloads on each of them, all calling
back to a single spire-server.

### Using the demo

Prerequisites:

* [An AWS account and credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
* Terraform
* Packer

Before building AMIs or running the demo, initialize your terraform
environment:

`make init`

The demo requires two pre-built AMIs. They only need to be rebuilt
when the SPIRE version or configuration is changed:

`make ami`

To launch or destroy the demo:

`make launch`
`make destroy`

To ssh to the server:

`make ssh`

### Modifying the demo

SPIRE configuration and AMI provisioning scripts are in the [remote](/drew/remote)
directory.

You can change the number of agents in [tf.sh](/drew/tf.sh) (`TF_VAR_SIZE`) and
the number of workloads per agent in [install_spire.sh](/drew/remote/install_spire.sh) (`NUM_WORKLOAD`).

To change the installed SPIRE versions, edit [install_spire.sh](/drew/remote/install_spire.sh).
