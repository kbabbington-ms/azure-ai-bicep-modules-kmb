@description('Data services for AI Enclave - SQL, Cosmos DB, PostgreSQL, Redis Cache')
param location string = resourceGroup().location
param environment string = 'dev'
param projectName string = 'ai-enclave'
param subnetId string
param logAnalyticsWorkspaceId string = ''
param sqlAdministratorLogin string = 'sqladmin'

@secure()
param sqlAdministratorPassword string

// Resource naming
var sqlServerName = 'sql-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
var cosmosAccountName = 'cosmos-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
var postgresServerName = 'psql-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
var redisName = 'redis-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
var dataFactoryName = 'adf-${projectName}-${environment}-${location}'

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'SQL Server for AI workloads'
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: 'Enabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: 'aienclave-db'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Main database for AI applications'
  }
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 2
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 34359738368 // 32 GB
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    autoPauseDelay: 60
    minCapacity: json('0.5')
  }
}

// Private Endpoint for SQL Server
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: 'pe-${sqlServerName}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private endpoint for SQL Server'
  }
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'sql-connection'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: ['sqlServer']
        }
      }
    ]
  }
}

// Cosmos DB Account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosAccountName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Cosmos DB for AI workloads'
  }
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: true
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    publicNetworkAccess: 'Disabled'
    networkAclBypass: 'None'
    disableKeyBasedMetadataWriteAccess: true
    enableFreeTier: false
    enableAnalyticalStorage: true
    analyticalStorageConfiguration: {
      schemaType: 'WellDefined'
    }
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Zone'
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Cosmos DB Database
resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmosAccount
  name: 'aienclave'
  properties: {
    resource: {
      id: 'aienclave'
    }
  }
}

// Cosmos DB Container
resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: cosmosDatabase
  name: 'vectors'
  properties: {
    resource: {
      id: 'vectors'
      partitionKey: {
        paths: ['/id']
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/vector/*'
          }
        ]
      }
    }
  }
}

// Private Endpoint for Cosmos DB
resource cosmosPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: 'pe-${cosmosAccountName}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private endpoint for Cosmos DB'
  }
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'cosmos-connection'
        properties: {
          privateLinkServiceId: cosmosAccount.id
          groupIds: ['Sql']
        }
      }
    ]
  }
}

// PostgreSQL Flexible Server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: postgresServerName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'PostgreSQL for AI workloads'
  }
  sku: {
    name: 'Standard_B2s'
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
    version: '14'
    storage: {
      storageSizeGB: 128
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    network: {
      delegatedSubnetResourceId: subnetId
      privateDnsZoneArmResourceId: ''
    }
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Enabled'
      dayOfWeek: 0
      startHour: 2
      startMinute: 0
    }
  }
}

// Redis Cache
resource redisCache 'Microsoft.Cache/redis@2023-08-01' = {
  name: redisName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Redis cache for AI workloads'
  }
  properties: {
    sku: {
      name: 'Premium'
      family: 'P'
      capacity: 1
    }
    redisConfiguration: {
      'maxmemory-policy': 'allkeys-lru'
      'notify-keyspace-events': 'Ex'
    }
    enableNonSslPort: false
    publicNetworkAccess: 'Disabled'
    redisVersion: '6'
    subnetId: subnetId
    staticIP: '10.3.2.10'
  }
}

// Azure Data Factory
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Data factory for AI pipelines'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Private Endpoint for Data Factory
resource dataFactoryPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: 'pe-${dataFactoryName}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private endpoint for Data Factory'
  }
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'adf-connection'
        properties: {
          privateLinkServiceId: dataFactory.id
          groupIds: ['dataFactory']
        }
      }
    ]
  }
}

// Diagnostic Settings
resource sqlDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  scope: sqlDatabase
  name: 'sql-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'SQLInsights'
        enabled: true
      }
      {
        category: 'AutomaticTuning'
        enabled: true
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled: true
      }
      {
        category: 'Errors'
        enabled: true
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled: true
      }
      {
        category: 'Timeouts'
        enabled: true
      }
      {
        category: 'Blocks'
        enabled: true
      }
      {
        category: 'Deadlocks'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled: true
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled: true
      }
      {
        category: 'WorkloadManagement'
        enabled: true
      }
    ]
  }
}

resource cosmosDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  scope: cosmosAccount
  name: 'cosmos-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
      {
        category: 'QueryRuntimeStatistics'
        enabled: true
      }
      {
        category: 'PartitionKeyStatistics'
        enabled: true
      }
      {
        category: 'PartitionKeyRUConsumption'
        enabled: true
      }
      {
        category: 'ControlPlaneRequests'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Requests'
        enabled: true
      }
    ]
  }
}

// Outputs
output sqlServerId string = sqlServer.id
output sqlServerName string = sqlServer.name
output sqlDatabaseId string = sqlDatabase.id
output cosmosAccountId string = cosmosAccount.id
output cosmosAccountName string = cosmosAccount.name
output cosmosEndpoint string = cosmosAccount.properties.documentEndpoint
output postgresServerId string = postgresServer.id
output postgresServerName string = postgresServer.name
output redisCacheId string = redisCache.id
output redisCacheName string = redisCache.name
output redisHostName string = redisCache.properties.hostName
output dataFactoryId string = dataFactory.id
output dataFactoryName string = dataFactory.name
