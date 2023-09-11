# cloud-networks

Terraform Plans for Deploying Scalable Networks to the Various Public Clouds

```tree
	|-- aws
	|   |-- peered_w_vpn
	|   |   |-- data.tf
	|   |   |-- firewall.tf
	|   |   |-- main.tf
	|   |   |-- providers.tf
	|   |   |-- tree.md
	|   |   |-- variables.tf
	|   |   |-- vault.tf
	|   |   `-- versions.tf
	|   |-- transit_gateway_fortigate_ngfw
	|   |   |-- README.md
	|   |   |-- data.tf
	|   |   |-- main.tf
	|   |   |-- module
	|   |   |   |-- cloudwatch.tf
	|   |   |   |-- firewall.tf
	|   |   |   |-- fortigate_conf.tpl
	|   |   |   |-- logging.tf
	|   |   |   |-- network.tf
	|   |   |   |-- outputs.tf
	|   |   |   |-- transit_gateway.tf
	|   |   |   `-- variables.tf
	|   |   |-- outputs.tf
	|   |   |-- terraform.tfvars
	|   |   |-- variables.tf
	|   |   `-- versions.tf
	|   |-- transit_gateway_native_firewall
	|   |   |-- README.md
	|   |   |-- data.tf
	|   |   |-- firewall.tf
	|   |   |-- main.tf
	|   |   |-- outputs.tf
	|   |   |-- variables.tf
	|   |   `-- versions.tf
	|   `-- vpc_peering
	|       |-- README.md
	|       |-- main.tf
	|       |-- network
	|       |   |-- main.tf
	|       |   |-- outputs.tf
	|       |   `-- variables.tf
	|       |-- outputs.tf
	|       |-- spokes.auto.tfvars
	|       |-- terraform.tfvars
	|       |-- variables.tf
	|       `-- vpc.auto.tfvars
	|-- azure
	|   |-- README.md
	|   |-- main.tf
	|   |-- module
	|   |   |-- main.tf
	|   |   |-- outputs.tf
	|   |   `-- variables.tf
	|   |-- terraform.tfvars
	|   |-- variables.tf
	|   |-- versions.tf
	|   `-- vnet_params.auto.tfvars
	|-- gcp
	|   |-- main.tf
	|   |-- terraform.tfvars
	|   |-- variables.tf
	|   `-- versions.tf
	`-- oci
	    |-- README.md
	    |-- main.tf
	    |-- network
	    |   |-- main.tf
	    |   |-- outputs.tf
	    |   `-- variables.tf
	    |-- network.auto.tfvars
	    |-- nsg_params.auto.tfvars
	    |-- nsg_vcn.auto.tfvars
	    |-- outputs.tf
	    |-- variables.tf
	    `-- versions.tf
```

### AWS - Amazon Web Services

- contains plans to provision hub-spoke style network environments using either transit gateways or VPC Peering.
- includes deployments of both the AWS Network Native Firewall and the *FortiGate NGFW*.
- also includes a plan to deploy a simple VPC Peering network.

#### Transit Gateway Networks

- [Transit Gateway Native Firewall](aws/transit_gateway_native_firewall)
- [Transit Gateway FortiGate NGFW](aws/transit_gateway_fortigate_ngfw)

#### VPC Peering Networks

- [VPC Peering](aws/vpc_peering)
- [VPC Peering w/ VPN](aws/peered_w_vpn) - WIP

### Azure - Microsoft Azure

- contains plans to provision hub-spoke style network environments using VNET peering.
- [Azure Network](azure)

### GCP - Google Cloud Platform

- contains a basic plan to build a peered VPC network (WIP)
- [GCP Network](gcp)

### OCI - Oracle Cloud Infrastructure

- contains a basic plan to build a peered VCN network
- [Oracle Network](oci/network)


## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.13.0 |
| vault | ~> 3.19.0 |

 