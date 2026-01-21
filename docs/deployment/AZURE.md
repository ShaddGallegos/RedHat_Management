# Azure Deployment Guide

Complete guide for deploying RHIS components on Microsoft Azure.

## Azure Prerequisites

### Azure Account Setup

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Set default subscription
az account set --subscription "subscription-id"
```

### Resource Group

```bash
# Create resource group
az group create \
  --name rhis-rg \
  --location eastus
```

## Network Setup

### Virtual Network

```bash
# Create virtual network
az network vnet create \
  --resource-group rhis-rg \
  --name rhis-vnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name management \
  --subnet-prefix 10.0.1.0/24

# Create additional subnet for databases
az network vnet subnet create \
  --resource-group rhis-rg \
  --vnet-name rhis-vnet \
  --name databases \
  --address-prefix 10.0.2.0/24

# Create subnet for execution nodes
az network vnet subnet create \
  --resource-group rhis-rg \
  --vnet-name rhis-vnet \
  --name execution \
  --address-prefix 10.0.3.0/24
```

### Network Security Groups

```bash
# Create network security group
az network nsg create \
  --resource-group rhis-rg \
  --name rhis-nsg

# Add security rules
az network nsg rule create \
  --resource-group rhis-rg \
  --nsg-name rhis-nsg \
  --name AllowHTTP \
  --priority 1000 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp

az network nsg rule create \
  --resource-group rhis-rg \
  --nsg-name rhis-nsg \
  --name AllowHTTPS \
  --priority 1010 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 443 \
  --access Allow \
  --protocol Tcp

az network nsg rule create \
  --resource-group rhis-rg \
  --nsg-name rhis-nsg \
  --name AllowSSH \
  --priority 1020 \
  --source-address-prefixes '10.0.0.0/16' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 \
  --access Allow \
  --protocol Tcp
```

## Virtual Machines

### Create VMs

```bash
# Create AAP VM
az vm create \
  --resource-group rhis-rg \
  --name aap-controller \
  --image UbuntuLTS \
  --size Standard_D8s_v3 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/id_rsa.pub \
  --nsg rhis-nsg \
  --subnet management \
  --vnet-name rhis-vnet \
  --os_generic-disk-size-gb 100 \
  --os_generic-disk-name aap-controller-os_generic

# Create Satellite VM
az vm create \
  --resource-group rhis-rg \
  --name scenario_satellite \
  --image RedHat:RHEL:9:9.1 \
  --size Standard_D16s_v3 \
  --admin-username redhat \
  --ssh-key-values ~/.ssh/id_rsa.pub \
  --nsg rhis-nsg \
  --subnet management \
  --vnet-name rhis-vnet \
  --os_generic-disk-size-gb 500 \
  --os_generic-disk-name scenario_satellite-os_generic

# Create IdM VM
az vm create \
  --resource-group rhis-rg \
  --name idm \
  --image RedHat:RHEL:9:9.1 \
  --size Standard_D8s_v3 \
  --admin-username redhat \
  --ssh-key-values ~/.ssh/id_rsa.pub \
  --nsg rhis-nsg \
  --subnet management \
  --vnet-name rhis-vnet \
  --os_generic-disk-size-gb 50 \
  --os_generic-disk-name idm-os_generic
```

### VM Size Recommendations

```
AAP Controller:
  Small: Standard_D8s_v3 (8 vCPU, 32 GB RAM)
  Medium: Standard_D16s_v3 (16 vCPU, 64 GB RAM)
  Large: Standard_D32s_v3 (32 vCPU, 128 GB RAM)

Satellite:
  Small: Standard_D16s_v3 (16 vCPU, 64 GB RAM)
  Medium: Standard_D32s_v3 (32 vCPU, 128 GB RAM)
  Large: Standard_D48s_v3 (48 vCPU, 192 GB RAM)

IdM:
  Small: Standard_D8s_v3 (8 vCPU, 32 GB RAM)
  Medium: Standard_D16s_v3 (16 vCPU, 64 GB RAM)
```

## Managed Disks

### Create Additional Disks

```bash
# Create disk for Satellite repos
az disk create \
  --resource-group rhis-rg \
  --name scenario_satellite-repos-disk \
  --size-gb 1000 \
  --sku Premium_LRS

# Attach to Satellite VM
az vm disk attach \
  --resource-group rhis-rg \
  --vm-name scenario_satellite \
  --disk scenario_satellite-repos-disk

# Create disk for AAP data
az disk create \
  --resource-group rhis-rg \
  --name aap-data-disk \
  --size-gb 500 \
  --sku Standard_LRS

# Attach to AAP VM
az vm disk attach \
  --resource-group rhis-rg \
  --vm-name aap-controller \
  --disk aap-data-disk
```

## Azure Database for PostgreSQL

### Create Managed Database

```bash
# Create database server
az postgres flexible-server create \
  --resource-group rhis-rg \
  --name rhis-db \
  --location eastus \
  --admin-user dbadmin \
  --admin-password SecurePassword123! \
  --sku-name Standard_D4s_v3 \
  --tier GeneralPurpose \
  --storage-size 256 \
  --version 14 \
  --backup-retention 30 \
  --geo-redundant-backup Enabled \
  --network-private-subnet /subscriptions/{sub-id}/resourceGroups/rhis-rg/providers/Microsoft.Network/virtualNetworks/rhis-vnet/subnets/databases

# Create databases
az postgres flexible-server db create \
  --resource-group rhis-rg \
  --server-name rhis-db \
  --database-name awx

az postgres flexible-server db create \
  --resource-group rhis-rg \
  --server-name rhis-db \
  --database-name foreman

az postgres flexible-server db create \
  --resource-group rhis-rg \
  --server-name rhis-db \
  --database-name ipa
```

## Load Balancer

### Setup Application Gateway

```bash
# Create public IP
az network public-ip create \
  --resource-group rhis-rg \
  --name rhis-pip \
  --sku Standard

# Create application gateway
az network application-gateway create \
  --name rhis-agw \
  --location eastus \
  --resource-group rhis-rg \
  --vnet-name rhis-vnet \
  --subnet management \
  --capacity 2 \
  --sku Standard_v2 \
  --http-settings-cookie-based-affinity Disabled \
  --frontend-port 443 \
  --http-settings-port 443 \
  --http-settings-protocol Https \
  --public-ip-address rhis-pip \
  --cert-file /path/to/cert.pfx \
  --cert-password CertPassword123!

# Create backend pool
az network application-gateway address-pool create \
  --gateway-name rhis-agw \
  --resource-group rhis-rg \
  --name aap-pool \
  --servers aap-controller.uksouth.cloudapp.azure.com

# Create HTTP settings
az network application-gateway http-settings create \
  --gateway-name rhis-agw \
  --resource-group rhis-rg \
  --name aap-settings \
  --port 443 \
  --protocol Https

# Create listener
az network application-gateway http-listener create \
  --gateway-name rhis-agw \
  --resource-group rhis-rg \
  --name aap-listener \
  --frontend-ip appGatewayFrontendIP \
  --frontend-port 443 \
  --protocol Https

# Create routing rule
az network application-gateway rule create \
  --gateway-name rhis-agw \
  --resource-group rhis-rg \
  --name aap-rule \
  --http-listener aap-listener \
  --rule-type PathBasedRouting \
  --address-pool aap-pool \
  --http-settings aap-settings
```

## Azure Monitor

### Setup Monitoring

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group rhis-rg \
  --workspace-name rhis-workspace

# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group rhis-rg \
  --workspace-name rhis-workspace \
  --query id -o tsv)

# Enable monitoring on VMs
az vm monitor metrics enable \
  --resource-group rhis-rg \
  --name aap-controller \
  --workspace-id $WORKSPACE_ID

# Create alert rule
az monitor metrics alert create \
  --resource-group rhis-rg \
  --name HighCPU \
  --description "Alert when CPU usage is high" \
  --scopes /subscriptions/{sub-id}/resourceGroups/rhis-rg/providers/Microsoft.Compute/virtualMachines/aap-controller \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m \
  --evaluation-frequency 1m
```

## Backup and Recovery

### Azure Backup

```bash
# Create recovery services vault
az backup vault create \
  --resource-group rhis-rg \
  --name rhis-vault \
  --location eastus

# Enable backup for VM
az backup protection enable-for-vm \
  --resource-group rhis-rg \
  --vault-name rhis-vault \
  --vm aap-controller \
  --policy-name DefaultPolicy

# Trigger backup
az backup protection backup-now \
  --resource-group rhis-rg \
  --vault-name rhis-vault \
  --container-name aap-controller \
  --item-name aap-controller \
  --retain-until 01-01-2025
```

## DNS

### Azure DNS

```bash
# Create DNS zone
az network dns zone create \
  --resource-group rhis-rg \
  --name example.com

# Create A record
az network dns record-set a create \
  --resource-group rhis-rg \
  --zone-name example.com \
  --name aap \
  --ttl 300

az network dns record-set a add-record \
  --resource-group rhis-rg \
  --zone-name example.com \
  --record-set-name aap \
  --ipv4-address 10.0.1.10
```

## Cost Optimization

### Recommendations

```bash
# Use reserved instances for long-term deployments
az reservations reservation list

# Use spot instances for non-critical workloads
az vm create \
  --resource-group rhis-rg \
  --name test-vm \
  --priority Spot \
  --eviction-policy Deallocate

# Monitor costs
az cost-management query create \
  --scope "subscriptions/{sub-id}" \
  --type Usage \
  --timeframe MonthToDate
```

---

See [Deployment Overview](./OVERVIEW.md) for general deployment concepts and [Operations](../operations/) for running RHIS on Azure.
