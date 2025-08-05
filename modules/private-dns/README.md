# Private DNS Module

Comprehensive private DNS resolution for Azure services with private endpoints, ensuring secure and reliable name resolution for AI workloads.

## Features

- **🔒 Private DNS Zones**: Azure service DNS resolution for private endpoints
- **🔗 VNet Linking**: Automatic DNS resolution across networks
- **📝 Record Management**: Automated A record creation for private endpoints
- **🔄 Service Integration**: Seamless private endpoint DNS integration
- **🌐 Multi-Service Support**: DNS zones for all Azure AI and infrastructure services
- **📊 DNS Analytics**: Query resolution monitoring and troubleshooting
- **🛡️ Security**: Isolated DNS resolution without internet dependencies

## Usage

```bicep
module privateDns 'modules/private-dns/main.bicep' = {
  name: 'enterprise-private-dns'
  params: {
    environment: 'prod'
    projectName: 'ai-platform'
    
    // VNet configuration
    vnetIds: [
      '/subscriptions/.../providers/Microsoft.Network/virtualNetworks/hub-vnet',
      '/subscriptions/.../providers/Microsoft.Network/virtualNetworks/spoke-vnet'
    ]
    
    tags: {
      Environment: 'Production'
      Application: 'AI Platform'
      Purpose: 'Private DNS Resolution'
    }
  }
}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `environment` | string | `'dev'` | Environment designation (dev/test/prod) |
| `projectName` | string | `'ai-enclave'` | Project name for resource naming |
| `vnetIds` | array | `[]` | Array of VNet resource IDs for DNS linking |

## Security Features

- **🔒 Private Resolution**: DNS resolution without internet dependency
- **🛡️ Network Isolation**: DNS queries remain within private networks
- **🔐 Access Control**: RBAC-based DNS zone management
- **📝 Audit Logging**: DNS query and management audit trails
- **🌐 Conditional Forwarding**: Secure forwarding for hybrid scenarios

## Supported Private DNS Zones

### AI Services
| Service | Private DNS Zone |
|---------|------------------|
| **Cognitive Services** | `privatelink.cognitiveservices.azure.com` |
| **Azure OpenAI** | `privatelink.openai.azure.com` |
| **Machine Learning** | `privatelink.api.azureml.ms` |
| **Cognitive Search** | `privatelink.search.windows.net` |
| **Document Intelligence** | `privatelink.cognitiveservices.azure.com` |

### Infrastructure Services
| Service | Private DNS Zone |
|---------|------------------|
| **Storage (Blob)** | `privatelink.blob.core.windows.net` |
| **Storage (File)** | `privatelink.file.core.windows.net` |
| **Key Vault** | `privatelink.vaultcore.azure.net` |
| **SQL Database** | `privatelink.database.windows.net` |
| **Cosmos DB** | `privatelink.documents.azure.com` |
| **Container Registry** | `privatelink.azurecr.io` |
| **PostgreSQL** | `privatelink.postgres.database.azure.com` |
| **Redis Cache** | `privatelink.redis.cache.windows.net` |

### Platform Services
| Service | Private DNS Zone |
|---------|------------------|
| **Monitor** | `privatelink.monitor.azure.com` |
| **Service Bus** | `privatelink.servicebus.windows.net` |
| **Event Grid** | `privatelink.eventgrid.azure.net` |
| **Data Factory** | `privatelink.datafactory.azure.net` |

## DNS Resolution Flow

```
Application Request
        ↓
Private DNS Zone
        ↓
Private Endpoint IP
        ↓
Azure Service (Private)
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `dnsZoneIds` | object | Object containing all private DNS zone resource IDs |
| `cognitiveServicesZoneId` | string | Cognitive Services DNS zone resource ID |
| `openAiZoneId` | string | Azure OpenAI DNS zone resource ID |
| `machineLearningZoneId` | string | Machine Learning DNS zone resource ID |
| `storageZoneIds` | object | Storage service DNS zone resource IDs |
| `keyVaultZoneId` | string | Key Vault DNS zone resource ID |

## VNet Integration

This module automatically:
- **🔗 Links DNS Zones**: Connects DNS zones to specified VNets
- **🔄 Auto-Registration**: Enables auto-registration where supported
- **📊 Query Resolution**: Provides DNS resolution for linked VNets
- **🌐 Cross-VNet Resolution**: Enables DNS resolution across peered VNets

## Best Practices

### DNS Zone Management
- **📝 Consistent Naming**: Use standardized DNS zone names
- **🔗 VNet Linking**: Link all relevant VNets to DNS zones
- **📊 Monitoring**: Monitor DNS query resolution and failures
- **🔄 Automation**: Automate DNS record management

### Security Considerations
- **🔒 Access Control**: Implement RBAC for DNS zone management
- **📝 Audit Logging**: Enable diagnostic settings for DNS zones
- **🛡️ Network Policies**: Use network security groups for DNS traffic
- **🌐 Conditional Forwarding**: Secure external DNS resolution

## Troubleshooting

### Common Issues
- **❌ DNS Resolution Failures**: Verify VNet linking and zone configuration
- **🔄 Propagation Delays**: Allow time for DNS record propagation
- **🌐 External Dependencies**: Check conditional forwarding rules
- **📊 Query Analytics**: Use DNS analytics for troubleshooting

### Diagnostic Tools
- **🔍 nslookup/dig**: Command-line DNS resolution testing
- **📊 Azure Monitor**: DNS query metrics and logging
- **🛠️ Network Watcher**: Network connectivity troubleshooting
- **📈 DNS Analytics**: Comprehensive DNS query analysis

## Performance Optimization

- **⚡ Caching**: Local DNS caching for improved performance
- **🌐 Proximity**: Use geo-distributed DNS resolution
- **📊 Load Balancing**: Distribute DNS queries across resolvers
- **🔄 Health Checks**: Monitor DNS resolver health and availability

## Integration Scenarios

### Hybrid Connectivity
- **🌐 On-premises Integration**: Conditional forwarding for hybrid DNS
- **🔄 Site-to-Site VPN**: DNS resolution over VPN connections
- **📡 ExpressRoute**: Private connectivity with DNS resolution
- **☁️ Multi-cloud**: Cross-cloud DNS resolution strategies

## Compliance

This module supports the following compliance requirements:
- **SOC 2 Type II**: DNS security and audit controls
- **ISO 27001**: Network security and DNS management
- **NIST**: Cybersecurity framework DNS controls
- **GDPR**: Data residency through DNS resolution control
