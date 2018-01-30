# SPIFFE examples 

This repository contains infrastructure for development and demos as well as automated demos for each SPIRE release
 
## Demonstrations

**[simple_verification](simple_verification) - SVID Verification with Ghostunnel**

This demo shows a Ghostunnel connection validating SPIFFE certificates.

**[rosemary](rosemary) - UNIX Attestation and Ghostunnel Verification**

Demonstrates two workloads communicating over mutually authenticated Ghostunnel using SVIDs generated through UNIX attestation by UID. 

**[beatrice](beatrice) - Kubernetes Attestation and Ghostunnel verification**

Demonstrates two workloads communicating over mutually authenticated Ghostunnel endpoints using SVIDs automatically provistioned to an attested Kubernetres Pod. 

**[cadfael](cadfael) - AWS Attestation and Envoy Verification**

Demonstrates two workloads communicating via mutually authenticated Envoys using SVIDs generated through AWS instance attestation. 

**[drew](drew) - Server and Agent Scale and Performance**

Demonstrates 100 workloads on 100 servers managed by one spire-server

## Infrastructure

**[vagrant_k8s](vagrant_k8s) - Local Kubernetes with Vagrant**

Creates a Kubernets master and >=1 node in seperate Vagrant VMs.

**[vagrant_db](vagrant_db) - Local MariaDB "bare metal" with Vagrant**

**[ec2](ec2) - AWS EC2 with Terraform**

Provisions a VPC with three EC2 instances with proper IAM instance roles for the aws-resolver plugin.

