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

To ssh to the server or the first agent instance:

`make ssh_server`
`make ssh_agent`

### Modifying the demo

SPIRE configuration and AMI provisioning scripts are in the [remote](/drew/remote)
directory.

Configurable variables in [drew.sh](/drew/drew.sh):

Demo-specific:
* `TF_VAR_AGENTS` - number of agent instances to launch
* `TF_VAR_WORKLOADS` - number of workloads per agent
* `TF_VAR_SPIRE_TGZ` - URL to SPIRE build artifact (not release tarball)
* `TF_VAR_AWS_IID_TGZ` - URL to SPIRE AWS IID attestor tarball
* `TF_VAR_AWS_RES_TGZ` - URL to SPIRE AWS node resolver tarball

AWS specific:
* `TF_VAR_REGION` - default us-eaast-2
* `TF_VAR_AZ` - default us-east-2a
* `TF_VAR_CIDR` - VPC network, default 10.71.0.0/20
* `TF_VAR_TYPE` - EC2 instance type, default t2.micro
* `TF_VAR_PRICE` - spot instance bid price, default $0.01
