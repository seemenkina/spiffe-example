# AWS Attestation and Scale Demo

This demo will create a fleet of 100 EC2 spot instances and run
spire-agent and 100 dummy workloads on each of them, all calling
back to a single spire-server.

### Using the demo

Prerequisites:

* Terraform
* Packer

Before building AMIs or running the demo, initialize your terraform
environment:

`make init`

The demo requires two pre-build AMIs. The only need to be rebuilt
when the SPIRE version or configuration is changed:

`make ami`

To launch or destroy the demo:

`make launch`
`make destroy`

To ssh to the server:

`make ssh`

### Modifying the demo

SPIRE configuration and AMI provisioning scripts are in the `remote`
directory.

To change the installed SPIRE versions, edit the `install_spire.sh`
and `install_sidecar.sh` scripts.

