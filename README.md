# cloud-networks

Terraform Plans for Deploying Scalable Networks to the Various Public Clouds

```tree
├── aws
│   ├── transit_gateway_fortigate_ngfw
│   │   └── module
│   ├── transit_gateway_native_firewall
│   └── vpc_peering
│       └── network
├── azure
│   └── module
├── gcp
└── oci
    └── network
```

## AWS - Amazon Web Services

- contains plans to provision hub-spoke style network environments using either transit gateways or VPC Peering. 
- includes deployments of both the AWS Network Native Firewall and the *FortiGate NGFW*.
- also includes a plan to deploy a simple VPC Peering network.

#### Transit Gateway Networks

- [Transit Gateway Native Firewall](aws/transit_gateway_native_firewall)
- [Transit Gateway FortiGate NGFW](aws/transit_gateway_fortigate_ngfw)

#### VPC Peering Networks

- [VPC Peering](aws/vpc_peering)

## Azure - Microsoft Azure

- contains plans to provision hub-spoke style network environments using VNET peering.
- [Azure Network](azure)

## GCP - Google Cloud Platform

- contains a basic plan to build a peered VPC network (WIP)
- [GCP Network](gcp)

## OCI - Oracle Cloud Infrastructure

- contains a basic plan to build a peered VCN network
- [Oracle Network](oci/network)