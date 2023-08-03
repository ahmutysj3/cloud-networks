# Amazon Web Services AWS VPC/Network Module

## Overview

This terraform plan builds a network in the **AWS Cloud**.

Use of this module/s will require setting up **Terraform AWS Provider & AWS-CLI** (along w/credentials setup etc) before running terraform init

## Instructions

- define region for network in the *terraform.tfvars* file supernet variable
- VPC parameters such as cidr can be found in *vpc.auto.tfvars*
- subnet parameters can be found in *spokes.auto.tfvars*
- Hub subnet parameters are automatic and can only be changed on the module side.

## Network Structure

### Three-Tier Design w/ Hub VPC

- `DMZ` Virtual Private Cloud
- `App` Virtual Private Cloud
- `Database` Virtual Private Cloud

### Using Network Security Groups to create isolation between VPCs

- All Spoke VPCs can receive traffic from the `Hub`
- `DMZ` can send traffic to `App` (via hairpin at `Hub`). `DMV` can receive inbound traffic from `App` or `Hub` only.
- `App` can send traffic to `DMZ` or `Database` and can receive inbound traffic from either of those VPCs (always utilizing hairpin at `Hub`).
- `Database` can only receive traffic from `App` and can only send traffic to `App` (by way of `Hub` hairpin).

### Notes

- The hub subnets will automatically be provisioned as two /24 subnets for inside/outside fw interfaces (the network requires a **Network Virtual Appliance** in the hub for routing)

## Resources Used

- aws_default_route_table
- aws_route_table
- aws_route_table_association
- aws_internet_gateway
- aws_network_acl
- aws_network_acl_association
- aws_security_group
- aws_security_group_rule
- aws_subnet
- aws_vpc
- aws_vpc_peering_connection
