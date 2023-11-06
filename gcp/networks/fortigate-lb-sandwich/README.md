# Google Cloud Platform - Network Environment Deployment with Terraform

This README provides a detailed explanation of the network environment set up by the provided Terraform configuration on Google Cloud Platform (GCP). The Terraform configuration creates a series of resources that enable a robust networking environment including instances, disks, VPCs, subnetworks, firewall rules, and load balancers.

## Overview

The Terraform configuration defines the creation of a `google_compute_instance` with pfSense, a popular network firewall/router software distribution. This virtual machine (VM) instance is designed with two network interfaces for the WAN and LAN segments, and is optimized for cost with a preemptible instance type.

## Resources Deployed

### Compute Engine

- **Google Compute Instance (pfSense):**
  - **Name:** `pfsense-active1-fw`
  - **Machine Type:** `e2-standard-4`
  - **Zone:** First available from `data.google_compute_zones.available.names`
  - **IP Forwarding Enabled:** Allows the instance to send and receive packets not matched to the instance's IP address.
  - **Boot Disk:** A standard persistent disk created from a pfSense image.

### Networking

- **VPC Networks:**
  - `test-trusted-vpc-network`: A VPC for trusted traffic, without auto-created subnetworks.
  - `test-untrusted-vpc-network`: A VPC for untrusted traffic.
  - `test-protected-vpc-network`: A VPC for protected segments of the network.

- **Subnetworks:**
  - `test-trusted-subnet`: A subnet with the range `10.0.0.0/16` within the trusted VPC.
  - `test-untrusted-subnet`: A subnet with the range `10.255.0.0/16` within the untrusted VPC.
  - `test-protected-subnet`: A subnet with the range `192.168.0.0/24` within the protected VPC.

- **Network Peering:**
  - `trusted-to-protected-peering` and `protected-to-trusted-peering`: Peering connections between the trusted and protected networks for controlled access.

### Load Balancers

- **External Load Balancer (ELB):**
  - A regional backend service directing traffic to the pfSense instance group, with an external forwarding rule.

- **Internal Load Balancer (ILB):**
  - A regional backend service within the trusted VPC that balances traffic internally, with a forwarding rule.

### Firewall Rules

- `default-allow-all-untrusted`: Allows all ingress traffic to the untrusted network.
- `default-allow-all-trusted`: Allows all ingress traffic to the trusted network.
- `allow-all-from-trusted-to-protected`: Allows all traffic from the trusted to the protected network.
- `default-allow-health-checks`: Allows TCP traffic on port 443 for health checks from Google's IP ranges.

### Health Checks

- **TCP Health Check:** Monitors the health of the pfSense instance by checking TCP traffic on port 443.

### Cloud Router and NAT

- **Cloud Router:** Named `trace-test-cloud-router` within the untrusted VPC.
- **Cloud NAT:** Provides NAT for instances without public IP addresses in the untrusted VPC.

### Static IPs

- **LAN and WAN IPs for pfSense:** Internal static IPs for the LAN and WAN interfaces of the pfSense VM.
- **Load Balancer IPs:** External and internal static IPs for the external and internal load balancers, respectively.

## Deployment Attributes

- **Project ID:** Defined by `var.gcp_project`.
- **Region:** Defined by `var.gcp_region`.

## Prerequisites

Before using this Terraform configuration, ensure you have:

- A GCP account with billing set up.
- The `gcloud` CLI installed and configured.
- Terraform installed locally.

## Usage

To deploy this configuration:

1. Clone the repository containing the Terraform files.
2. Navigate to the directory containing the Terraform files.
3. Initialize the Terraform environment with `terraform init`.
4. Apply the configuration with `terraform apply`.

Confirm all details in the output to ensure that the resources will be created as expected, then type `yes` to proceed with the creation.

## Contributing

If you would like to contribute to this project, please fork the repository and submit a pull request.

## License

This project is open-source and available under the MIT License.

## Disclaimer

This Terraform configuration is provided as-is, and you should ensure it meets your security and networking requirements before deployment.

