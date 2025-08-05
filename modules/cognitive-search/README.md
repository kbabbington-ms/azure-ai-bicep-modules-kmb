# Cognitive Search Module

Enterprise Azure Cognitive Search service with AI-powered search capabilities, semantic search, and advanced security features.

## Features

- **🧠 Semantic Search**: Vector search and AI-powered ranking capabilities
- **🔒 Enterprise Security**: Private endpoints and customer-managed encryption
- **📊 Scale Management**: Auto-scaling with performance optimization
- **🔗 AI Integration**: Seamless connection to OpenAI and Cognitive Services
- **🎯 Custom Skills**: AI enrichment pipelines for content processing
- **🛡️ Network Isolation**: Private connectivity with no public access
- **📈 Advanced Analytics**: Search analytics and performance monitoring

## Usage

```bicep
module cognitiveSearch 'modules/cognitive-search/main.bicep' = {
  name: 'enterprise-search'
  params: {
    searchServiceName: 'mycompany-search-prod'
    location: 'eastus'
    environment: 'prod'
    
    // Service configuration
    sku: 'Standard'
    replicaCount: 2
    partitionCount: 1
    
    // Security configuration
    enablePrivateEndpoint: true
    privateEndpointSubnetId: '/subscriptions/.../subnets/search-subnet'
    enableCustomerManagedEncryption: true
    keyVaultUri: 'https://mykv.vault.azure.net/'
    
    // Network isolation
    publicNetworkAccess: 'Disabled'
    allowedIPRanges: []
    
    tags: {
      Environment: 'Production'
      Application: 'Search Platform'
      Security: 'High'
    }
  }
}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `searchServiceName` | string | *Required* | Name of the Cognitive Search service |
| `location` | string | `resourceGroup().location` | Azure region for deployment |
| `environment` | string | `'dev'` | Environment designation (dev/test/prod) |
| `sku` | string | `'Standard'` | Service tier (Basic/Standard/Standard2/Standard3) |
| `enablePrivateEndpoint` | bool | `true` | Enable private endpoint connectivity |
| `publicNetworkAccess` | string | `'Disabled'` | Public network access setting |
| `enableCustomerManagedEncryption` | bool | `true` | Enable customer-managed encryption |

## Security Features

- **🔒 Private Endpoints**: Secure connectivity without public internet exposure
- **🔐 Customer-Managed Keys**: Full control over encryption with Key Vault integration
- **🌐 Network Access Control**: IP restrictions and VNet integration
- **👤 Identity-Based Access**: Azure AD authentication with API keys disabled
- **📝 Audit Logging**: Comprehensive diagnostic settings and search analytics
- **🛡️ Data Protection**: Encryption at rest and in transit

## Search Capabilities

- **🔍 Full-Text Search**: Advanced text search with linguistic analysis
- **🧠 Semantic Search**: AI-powered search with natural language understanding
- **🎯 Vector Search**: Similarity search for AI and ML scenarios
- **📊 Faceted Search**: Dynamic filtering and navigation
- **🔗 AI Enrichment**: Content extraction and enhancement with Cognitive Services
- **📈 Search Analytics**: Query performance and usage insights

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `searchServiceId` | string | Resource ID of the Cognitive Search service |
| `searchServiceName` | string | Name of the search service |
| `searchServiceEndpoint` | string | Search service endpoint URL |
| `privateEndpointId` | string | Private endpoint resource ID (if enabled) |

## AI Integration

This module supports integration with:
- **🤖 Azure OpenAI**: Vector embeddings and semantic search
- **🧠 Cognitive Services**: Text analytics, OCR, and language detection
- **📄 Document Intelligence**: Document parsing and content extraction
- **🔗 Custom Skills**: Custom AI models and processing pipelines

## Compliance

This module supports the following compliance standards:
- **SOC 2 Type II**: Audit logging and access controls
- **ISO 27001**: Encryption and network security
- **GDPR**: Data residency and privacy controls
- **HIPAA**: Healthcare search scenarios (when properly configured)
