# Data Services Module

Complete data platform for Azure AI workloads including SQL Database, Cosmos DB, PostgreSQL, Redis Cache, and Data Factory with enterprise security and performance optimization.

## Features

- **🗄️ Azure SQL Database**: Relational data with enterprise security and AI integration
- **🌍 Cosmos DB**: Global NoSQL database with vector support for AI scenarios
- **🐘 PostgreSQL**: Flexible server with AI extensions and vector capabilities
- **⚡ Redis Cache**: High-performance caching layer for AI applications
- **🔗 Data Factory**: ETL/ELT pipelines for AI data processing
- **🔒 Private Connectivity**: All services with private endpoint support
- **📊 Analytics**: Built-in analytics and performance monitoring

## Usage

```bicep
module dataServices 'modules/data-services/main.bicep' = {
  name: 'enterprise-data-services'
  params: {
    location: 'eastus'
    environment: 'prod'
    projectName: 'ai-platform'
    
    // Network configuration
    subnetId: '/subscriptions/.../providers/Microsoft.Network/virtualNetworks/vnet/subnets/data-subnet'
    
    // SQL configuration
    sqlAdministratorLogin: 'sqladmin'
    sqlAdministratorPassword: 'SecurePassword123!'
    
    // Monitoring
    logAnalyticsWorkspaceId: '/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/logs'
    
    tags: {
      Environment: 'Production'
      Application: 'AI Platform'
      Purpose: 'Data Services'
    }
  }
}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region for deployment |
| `environment` | string | `'dev'` | Environment designation (dev/test/prod) |
| `projectName` | string | `'ai-enclave'` | Project name for resource naming |
| `subnetId` | string | *Required* | Subnet ID for private endpoints |
| `sqlAdministratorLogin` | string | `'sqladmin'` | SQL Server administrator username |
| `sqlAdministratorPassword` | securestring | *Required* | SQL Server administrator password |
| `logAnalyticsWorkspaceId` | string | `''` | Log Analytics workspace for monitoring |

## Security Features

- **🔒 Private Endpoints**: Secure connectivity for all data services
- **🔐 Encryption**: Customer-managed encryption where available
- **🌐 Network Isolation**: No public internet access by default
- **👤 Identity-Based Access**: Azure AD authentication preferred
- **📝 Audit Logging**: Comprehensive data access logging
- **🛡️ Threat Protection**: Advanced threat protection for databases

## Data Services

### Azure SQL Database
- **💾 Serverless**: Auto-scaling with pause/resume capabilities
- **📊 Performance**: General Purpose with burstable compute
- **🔒 Security**: Always Encrypted, TDE, and advanced threat protection
- **🤖 AI Integration**: Built-in machine learning and cognitive services

### Cosmos DB
- **🌍 Global Distribution**: Multi-region replication
- **📈 Autoscale**: Automatic throughput scaling
- **🧠 Vector Search**: Native vector search for AI scenarios
- **📊 Analytics**: Built-in analytics and change feed

### PostgreSQL Flexible Server
- **🐘 Latest Version**: PostgreSQL 14+ with AI extensions
- **📊 Performance**: Burstable and general purpose tiers
- **🧠 AI Extensions**: pgvector for vector operations
- **🔧 Flexibility**: Custom parameters and maintenance windows

### Redis Cache
- **⚡ High Performance**: In-memory caching with persistence
- **🔄 Replication**: Optional geo-replication
- **📊 Monitoring**: Built-in metrics and diagnostics
- **🔒 Security**: Private endpoints and SSL/TLS

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `sqlServerId` | string | Resource ID of SQL Server |
| `sqlServerFqdn` | string | Fully qualified domain name of SQL Server |
| `cosmosAccountId` | string | Resource ID of Cosmos DB account |
| `cosmosAccountEndpoint` | string | Cosmos DB account endpoint |
| `postgresServerId` | string | Resource ID of PostgreSQL server |
| `redisId` | string | Resource ID of Redis cache |
| `dataFactoryId` | string | Resource ID of Data Factory |

## AI/ML Integration

This module is optimized for AI/ML workloads with:
- **🤖 Vector Databases**: Cosmos DB and PostgreSQL with vector support
- **📊 Feature Store**: SQL Database optimized for ML feature storage
- **⚡ Real-time Inference**: Redis Cache for model result caching
- **🔄 Data Pipelines**: Data Factory for AI data processing workflows
- **📈 Analytics**: Built-in analytics for model training data

## Performance Optimization

- **📊 Intelligent Performance**: Auto-tuning and performance recommendations
- **🔄 Connection Pooling**: Optimized connection management
- **💾 Caching Strategy**: Multi-tier caching with Redis
- **📈 Scaling**: Auto-scaling based on workload patterns
- **🎯 Indexing**: AI-optimized indexing strategies

## Compliance

This module supports the following compliance standards:
- **SOC 2 Type II**: Data security and access controls
- **ISO 27001**: Database security standards
- **GDPR**: Data protection and privacy controls
- **HIPAA**: Healthcare data protection requirements
- **PCI DSS**: Payment data security standards
