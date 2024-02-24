# cloud-networks

- Terraform Plans for Deploying Scalable Networks to the Various Public Clouds

## Repository Structure

```tree
.
├── aws
│   ├── peered_w_vpn
│   │   ├── data.tf
│   │   ├── firewall.tf
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── transit_gateway_fortigate_ngfw
│   │   ├── data.tf
│   │   ├── main.tf
│   │   ├── module
│   │   │   ├── cloudwatch.tf
│   │   │   ├── firewall.tf
│   │   │   ├── fortigate_conf.tpl
│   │   │   ├── logging.tf
│   │   │   ├── network.tf
│   │   │   ├── outputs.tf
│   │   │   ├── transit_gateway.tf
│   │   │   └── variables.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   ├── terraform.tfvars
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── transit_gateway_native_firewall
│   │   ├── data.tf
│   │   ├── firewall.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── README.md
│   │   ├── variables.tf
│   │   └── versions.tf
│   └── vpc_peering
│       ├── main.tf
│       ├── network
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── README.md
│       ├── spokes.auto.tfvars
│       ├── terraform.tfvars
│       ├── variables.tf
│       ├── versions.tf
│       └── vpc.auto.tfvars
├── azure
│   ├── main.tf
│   ├── module
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── README.md
│   ├── terraform.tfvars
│   ├── variables.tf
│   ├── versions.tf
│   └── vnet_params.auto.tfvars
├── gcp
│   ├── instances
│   │   ├── main.tf
│   │   ├── modules
│   │   │   ├── main.tf
│   │   │   ├── startup.sh
│   │   │   └── variables.tf
│   │   ├── providers.tf
│   │   ├── terraform.tfvars
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── lbs
│   │   ├── cert.tf
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   ├── terraform.tfvars
│   │   └── versions.tf
│   ├── networks
│   │   ├── basic-sandbox
│   │   │   ├── main.tf
│   │   │   ├── README.md
│   │   │   ├── terraform.tfvars
│   │   │   ├── variables.tf
│   │   │   └── versions.tf
│   │   ├── hub-spoke-sandbox-w-fortigate
│   │   │   ├── firewall.tf
│   │   │   ├── fortigate.tf
│   │   │   ├── jumpbox.tf
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   ├── README.md
│   │   │   ├── variables.tf
│   │   │   └── versions.tf
│   │   └── ngfw-lb-sandwich
│   │       ├── backup_firewalls
│   │       │   ├── palo_alto_ngfw.tf.lock
│   │       │   └── pfsense.tf.lock
│   │       ├── main.tf
│   │       ├── modules
│   │       │   ├── app-networks
│   │       │   │   └── network.tf
│   │       │   ├── edge-firewall
│   │       │   │   ├── firewall.tf
│   │       │   │   ├── fortigate
│   │       │   │   │   ├── addresses.tf
│   │       │   │   │   ├── bootstrap2.tpl
│   │       │   │   │   ├── bootstrap.tpl
│   │       │   │   │   ├── firewall.tf
│   │       │   │   │   ├── load_balancers.tf
│   │       │   │   │   └── variables.tf
│   │       │   │   ├── load-balancers
│   │       │   │   │   ├── main.tf
│   │       │   │   │   └── variables.tf
│   │       │   │   ├── variables.tf
│   │       │   │   └── versions.tf
│   │       │   └── edge-network
│   │       │       ├── main.tf
│   │       │       ├── outputs.tf
│   │       │       ├── peerings
│   │       │       │   ├── main.tf
│   │       │       │   └── variables.tf
│   │       │       ├── variables.tf
│   │       │       └── versions.tf
│   │       ├── providers.tf
│   │       ├── README.md
│   │       ├── terraform.tfvars
│   │       ├── variables.tf
│   │       └── versions.tf
│   └── projects
│       ├── main.tf
│       ├── org
│       │   ├── main.tf
│       │   ├── terraform.tfvars
│       │   ├── variables.tf
│       │   └── versions.tf
│       ├── README.md
│       └── variables.tf
├── oci
│   ├── main.tf
│   ├── network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── network.auto.tfvars
│   ├── nsg_params.auto.tfvars
│   ├── nsg_vcn.auto.tfvars
│   ├── outputs.tf
│   ├── README.md
│   ├── variables.tf
│   └── versions.tf
└── README.md

29 directories, 122 files
```

## Public Cloud Networks

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

### GCP - Google Cloud Platform

- contains multiple plans for deploying standalone or peered networks
- includes modules for external application load balancers, network load balancers, and firewall vm series instances

#### Basic Sandbox Network

- [Basic Standalone Network](gcp/networks/basic-sandbox)

#### Hub-Spoke Networks w/ NGFW

- [Hub-Spoke Network](gcp/networks/hub-spoke-sandbox-w-fortigate)
- [NGFW-LB Sandwich](gcp/networks/ngfw-lb-sandwich)

#### Network Services and Instances

- [Projects](gcp/projects)
- [Load Balancing](gcp/lbs)
- [Instances](gcp/instances)

### Azure - Microsoft Azure

- contains plans to provision hub-spoke style network environments using VNET peering.
- [Azure Network](azure)

### OCI - Oracle Cloud Infrastructure

- contains a basic plan to build a peered VCN network
- [Oracle Network](oci/network)