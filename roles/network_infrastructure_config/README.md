# Network Infrastructure Configuration Role

## Description

Configures network infrastructure for RHIS including the primary 10.168.0.0/16 subnet with DHCP, DNS, and firewall rules.

## Features

- **Primary Subnet**: 10.168.0.0/16 with gateway at 10.168.0.1
- **Host Groups**: Pre-configured subnets for different service types
- **DHCP**: Automatic IP assignment with DNS and NTP configuration
- **DNS**: Primary and secondary resolvers
- **Firewall**: Rules for DNS, DHCP, SSH, and Satellite access
- **Static Hosts**: Reserved IPs for core infrastructure

## Host Group Subnets

- **Infrastructure** (10.168.0.0/24): Satellite, IdM, AAP
- **Application-Servers** (10.168.1.0/24): Application deployments
- **Container-Hosts** (10.168.2.0/24): Container infrastructure
- **Database-Servers** (10.168.3.0/24): Database tier
- **Development** (10.168.100.0/24): Dev/test environments
- **Reserved-Internal** (10.168.240.0/21): Future expansion

## Usage

```yaml
- role: network_infrastructure_config
  vars:
    network_config_enabled: true
    primary_subnet:
      network: "10.168.0.0"
      prefix: 16
      gateway: "10.168.0.1"
```
