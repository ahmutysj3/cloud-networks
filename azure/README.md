# Microsoft Azure Cloud TF Lab

## Overview

This terraform plan builds a network in the **microsoft azure cloud**.

Use of this module/s will require setting up **ms azure provider and azure-cli** (along w/credentials setup etc) before running terraform init

## Instructions

- define supernet for network in the *terraform.tfvars* file supernet variable
- subnet parameters such as cidr and vnet assignment can be found in *vnet_params.auto.tfvars*

## Network Structure

### Three-Tier Design w/ Hub VNET

- `DMZ` Virtual Network
- `App` Virtual Network
- `Database` Virtual Network

### Using Network Security Groups to create isolation between vnets

- All Spoke VNETs can receive traffic from the `Hub VNET`
- `DMZ VNET` can send traffic to `App VNET` (via hairpin at `Hub VNET`). `DMV VNET` can receive inbound traffic from `App` or `Hub VNET`s only.
- `App VNET` can send traffic to `DMZ` or `Database VNET`s and can receive inbound traffic from either of those VNETs (always utilizing hairpin at `Hub`).
- `Database VNET` can only receive traffic from `App VNET` and can only send traffic to `App VNET` (by way of `Hub` hairpin).

### Notes

- This module uses the priority argument in NSG rules to override default rules allowing traffic from within VNET or through VNET peering.
- Those same permissions are still in place but through manual TF plan instead of relying on Azure defaults.
- The hub subnets will automatically be provisioned as two /25 subnets for inside/outside fw interfaces (the network requires a **Network Virtual Appliance** in the hub for routing)

## Resources Used

- azurerm_resource_group
- azurerm_virtual_network
- azurerm_virtual_network_peering
- azurerm_subnet
- azurerm_route_table
- azurerm_route_table_association
- azurerm_network_security_group
- azurerm_network_security_group_association
- azurerm_network_security_rule
- azurerm_network_watcher
- azurerm_storage_account
- azurerm_network_watcher_flow_log
