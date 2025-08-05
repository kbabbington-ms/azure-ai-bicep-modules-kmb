# Virtual Network Module

Enterprise hub-spoke network topology optimized for Azure AI workloads with zero-trust security architecture and comprehensive network isolation.

## Features

- **🔒 Zero-Trust Architecture**: Deny-by-default with explicit allow rules
- **🏢 Hub-Spoke Design**: Centralized firewall with isolated spoke networks
- **🛡️ Private Connectivity**: Private endpoints and service endpoints
- **🚨 Azure Bastion**: Secure administrative access without public IPs
- **🔥 Azure Firewall**: Application and network layer protection
- **📊 Network Monitoring**: NSG flow logs and traffic analytics
- **🌐 DNS Integration**: Private DNS zones for service resolution

## Usage

```bicep
module virtualNetwork 'modules/virtual-network/main.bicep' = {
  name: 'enterprise-network'
  params: {
    virtualNetworkName: 'mycompany-vnet-prod'
    location: 'eastus'
    environment: 'prod'
    
    // Network configuration
    addressPrefix: '10.0.0.0/16'
    subnets: [
      {
        name: 'ai-services-subnet'
        addressPrefix: '10.0.1.0/24'
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Disabled'
      }
      {
        name: 'compute-subnet'
        addressPrefix: '10.0.2.0/24'
        serviceEndpoints: ['Microsoft.Storage', 'Microsoft.KeyVault']
      }
    ]
    
    // Security configuration
    enableDdosProtection: true
    enableFirewall: true
    enableBastion: true
    
    tags: {
      Environment: 'Production'
      Application: 'AI Platform'
      Security: 'High'
    }
  }
}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `virtualNetworkName` | string | *Required* | Name of the virtual network |
| `location` | string | `resourceGroup().location` | Azure region for deployment |
| `environment` | string | `'dev'` | Environment designation (dev/test/prod) |
| `addressPrefix` | string | `'10.0.0.0/16'` | Virtual network address space |
| `enableDdosProtection` | bool | `true` | Enable DDoS protection |
| `enableFirewall` | bool | `true` | Deploy Azure Firewall |
| `enableBastion` | bool | `true` | Deploy Azure Bastion |

## Security Features

- **🔒 Zero-Trust Network**: Default deny with explicit allow rules
- **🛡️ Azure Firewall**: IDPS and application layer filtering
- **🚨 DDoS Protection**: Advanced DDoS mitigation
- **🔐 Private Endpoints**: Secure connectivity for Azure services
- **📊 Network Monitoring**: Flow logs and traffic analytics
- **🌐 DNS Security**: Private DNS zones and conditional forwarding

## Network Architecture

```
Hub VNet (10.0.0.0/16)
├── AzureFirewallSubnet (10.0.0.0/26)
├── AzureBastionSubnet (10.0.0.64/26)
├── GatewaySubnet (10.0.0.128/27)
└── Spoke VNets
    ├── AI Services Subnet (10.0.1.0/24)
    ├── Compute Subnet (10.0.2.0/24)
    ├── Data Subnet (10.0.3.0/24)
    └── Management Subnet (10.0.4.0/24)
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `virtualNetworkId` | string | Resource ID of the virtual network |
| `virtualNetworkName` | string | Name of the virtual network |
| `subnets` | array | Array of subnet resource IDs |
| `firewallId` | string | Azure Firewall resource ID (if enabled) |
| `bastionId` | string | Azure Bastion resource ID (if enabled) |

## Subnets

| Subnet | Purpose | Size | Features |
|--------|---------|------|----------|
| AzureFirewallSubnet | Firewall deployment | /26 | Required for Azure Firewall |
| AzureBastionSubnet | Bastion deployment | /26 | Required for Azure Bastion |
| ai-services-subnet | AI service private endpoints | /24 | Private endpoint support |
| compute-subnet | Compute resources | /24 | Service endpoints enabled |
| data-subnet | Data services | /24 | Storage and database connectivity |

## AI Workload Optimization

This network module is optimized for AI workloads with:
- **🤖 AI Service Integration**: Dedicated subnets for AI services
- **📊 Data Pipeline Support**: High-bandwidth connectivity for data processing
- **🖥️ Compute Optimization**: Low-latency subnets for ML training
- **🔗 Service Mesh**: Efficient service-to-service communication
- **📈 Scalability**: Room for growth and additional services

## Compliance

This module supports the following compliance standards:
- **SOC 2 Type II**: Network segmentation and monitoring
- **ISO 27001**: Network security controls
- **NIST**: Cybersecurity framework alignment
- **PCI DSS**: Network isolation requirements
