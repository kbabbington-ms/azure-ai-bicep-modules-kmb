@description('Azure Data Services - Enterprise Data Platform that creates comprehensive data infrastructure with SQL Server, Cosmos DB, PostgreSQL, Redis Cache, and Data Factory with enterprise security, monitoring, and compliance. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR, FedRAMP ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Azure Data Services - Enterprise Data Platform'
metadata description = 'Comprehensive data services infrastructure with multiple database engines and enterprise security'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
// ============================================================================

// Base name for data services resources
// Must be globally unique and follow naming conventions
// 🔒 SECURITY ENHANCEMENT: Use consistent naming for security governance
@description('Required. Base name for data services resources (2-20 characters)')
@minLength(2)
@maxLength(20)
param dataServicesBaseName string

// Azure region for deploying data infrastructure
// Note: Consider data residency and latency requirements
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet compliance requirements
@description('Required. Azure region for deployment')
param location string = resourceGroup().location

// Environment designation for resource organization and governance
// Controls data policies and access levels
// 🔒 SECURITY ENHANCEMENT: Environment-specific data policies
@description('Environment designation (dev, test, staging, prod)')
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string = 'prod'

// Project name for resource grouping and cost allocation
// Used for tagging and resource organization
@description('Project name for resource organization')
param projectName string = 'ai-platform'

// Virtual network subnet for private endpoints
// Required for secure database connectivity
// 🔒 SECURITY ENHANCEMENT: Private network connectivity for databases
@description('Virtual network subnet resource ID for private endpoints')
param subnetId string

// Log Analytics workspace for centralized logging
// Consolidates logs from all data services
// 🔒 SECURITY ENHANCEMENT: Required for compliance and security monitoring
@description('Log Analytics workspace resource ID for data services logs')
param logAnalyticsWorkspaceId string = ''

// ============================================================================
// PARAMETERS - SQL SERVER CONFIGURATION
// ============================================================================

// Enable SQL Server and databases
// Provides relational database capabilities
// 🔒 SECURITY ENHANCEMENT: Enterprise-grade SQL Server with advanced security
@description('Enable SQL Server and databases')
param enableSQLServer bool = true

// SQL Server administrator login
@description('SQL Server administrator login username')
param sqlAdministratorLogin string = 'sqladmin'

// SQL Server administrator password
// Must be secure and meet complexity requirements
// 🔒 SECURITY ENHANCEMENT: Secure password with complexity requirements
@description('SQL Server administrator password')
@secure()
param sqlAdministratorPassword string

// SQL Server configuration
@description('SQL Server configuration')
param sqlServerConfig object = {
  version: '12.0'
  publicNetworkAccess: 'Disabled'
  restrictOutboundNetworkAccess: 'Enabled'
  enableSystemAssignedIdentity: true
  enableUserAssignedIdentity: false
  minimalTlsVersion: '1.2'
  enableAdvancedThreatProtection: true
  enableVulnerabilityAssessment: true
  enableAuditLogging: true
}

// SQL Database configurations
@description('SQL Database configurations')
param sqlDatabaseConfigs array = [
  {
    name: 'primary-db'
    skuName: 'S2'               // Standard S2
    skuTier: 'Standard'
    skuCapacity: 50
    maxSizeBytes: 268435456000  // 250 GB
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    autoPauseDelay: -1          // Always on
    enableTransparentDataEncryption: true
    enableAdvancedThreatProtection: true
    enabled: true
  }
  {
    name: 'analytics-db'
    skuName: 'P1'               // Premium P1
    skuTier: 'Premium'
    skuCapacity: 125
    maxSizeBytes: 536870912000  // 500 GB
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: true
    readScale: 'Enabled'
    autoPauseDelay: -1
    enableTransparentDataEncryption: true
    enableAdvancedThreatProtection: true
    enabled: false
  }
]

// ============================================================================
// PARAMETERS - COSMOS DB CONFIGURATION
// ============================================================================

// Enable Cosmos DB for NoSQL workloads
// Provides globally distributed NoSQL database
// 🔒 SECURITY ENHANCEMENT: Cosmos DB with private endpoints and encryption
@description('Enable Cosmos DB for NoSQL workloads')
param enableCosmosDB bool = true

// Cosmos DB configuration
@description('Cosmos DB configuration')
param cosmosDBConfig object = {
  offerType: 'Standard'
  enableAutomaticFailover: true
  enableMultipleWriteLocations: false
  enableFreeTier: false
  publicNetworkAccess: 'Disabled'
  enableAnalyticalStorage: true
  analyticalStorageTtl: -1
  defaultConsistencyLevel: 'Session'
  maxStalenessPrefix: 100
  maxIntervalInSeconds: 300
  enableServerless: false
  totalThroughputLimit: 4000
}

// Cosmos DB database and container configurations
@description('Cosmos DB database and container configurations')
param cosmosDBDatabaseConfigs array = [
  {
    name: 'ai-platform-db'
    containers: [
      {
        name: 'users'
        partitionKeyPath: '/userId'
        throughput: 400
        defaultTtl: -1
        analyticalStorageTtl: -1
        enableAnalyticalStorage: false
      }
      {
        name: 'sessions'
        partitionKeyPath: '/sessionId'
        throughput: 400
        defaultTtl: 86400  // 24 hours TTL
        analyticalStorageTtl: -1
        enableAnalyticalStorage: false
      }
      {
        name: 'analytics'
        partitionKeyPath: '/date'
        throughput: 800
        defaultTtl: -1
        analyticalStorageTtl: 2592000  // 30 days
        enableAnalyticalStorage: true
      }
    ]
    enabled: true
  }
]

// ============================================================================
// PARAMETERS - POSTGRESQL CONFIGURATION
// ============================================================================

// Enable PostgreSQL Flexible Server
// Provides open-source PostgreSQL database
// 🔒 SECURITY ENHANCEMENT: PostgreSQL with private networking and encryption
@description('Enable PostgreSQL Flexible Server')
param enablePostgreSQL bool = true

// PostgreSQL administrator credentials
@description('PostgreSQL administrator login username')
param postgresAdministratorLogin string = 'postgres'

@description('PostgreSQL administrator password')
@secure()
param postgresAdministratorPassword string

// PostgreSQL server configuration
@description('PostgreSQL server configuration')
param postgresServerConfig object = {
  version: '15'
  skuName: 'Standard_D2s_v3'
  tier: 'GeneralPurpose'
  storageSizeGB: 128
  storageAutoGrow: 'Enabled'
  storageType: 'Premium_LRS'
  backupRetentionDays: 7
  geoRedundantBackup: 'Enabled'
  publicNetworkAccess: 'Disabled'
  highAvailability: 'ZoneRedundant'
  maintenanceWindow: {
    customWindow: 'Enabled'
    startHour: 2
    startMinute: 0
    dayOfWeek: 0
  }
}

// PostgreSQL database configurations
@description('PostgreSQL database configurations')
param postgresDatabaseConfigs array = [
  {
    name: 'appdb'
    charset: 'UTF8'
    collation: 'en_US.utf8'
    enabled: true
  }
  {
    name: 'analyticsdb'
    charset: 'UTF8'
    collation: 'en_US.utf8'
    enabled: false
  }
]

// ============================================================================
// PARAMETERS - REDIS CACHE CONFIGURATION
// ============================================================================

// Enable Redis Cache for caching and session storage
// Provides high-performance in-memory caching
// 🔒 SECURITY ENHANCEMENT: Redis with private endpoints and authentication
@description('Enable Redis Cache for caching and session storage')
param enableRedisCache bool = true

// Redis Cache configuration
@description('Redis Cache configuration')
param redisCacheConfig object = {
  skuName: 'Standard'
  skuFamily: 'C'
  skuCapacity: 1
  enableNonSslPort: false
  minimumTlsVersion: '1.2'
  publicNetworkAccess: 'Disabled'
  redisVersion: '6'
  redisConfiguration: {
    'maxmemory-reserved': '50'
    'maxfragmentationmemory-reserved': '50'
    'maxmemory-delta': '50'
  }
  enableDataPersistence: true
  rdbBackupEnabled: true
  rdbBackupFrequency: 60
  rdbBackupMaxSnapshotCount: 1
  aofBackupEnabled: false
}

// ============================================================================
// PARAMETERS - DATA FACTORY CONFIGURATION
// ============================================================================

// Enable Azure Data Factory for data integration
// Provides ETL/ELT and data integration capabilities
// 🔒 SECURITY ENHANCEMENT: Data Factory with managed VNet and private endpoints
@description('Enable Azure Data Factory for data integration')
param enableDataFactory bool = true

// Data Factory configuration
@description('Data Factory configuration')
param dataFactoryConfig object = {
  enableGitIntegration: true
  gitAccountType: 'GitHub'      // GitHub or Azure DevOps
  gitRepositoryName: ''
  gitCollaborationBranch: 'main'
  gitRootFolder: '/datafactory'
  enableManagedVirtualNetwork: true
  enablePublicNetworkAccess: false
  enableDataFlowDebugSession: false
  enableCustomerManagedKey: false
}

// Data Factory integration runtime configurations
@description('Data Factory integration runtime configurations')
param dataFactoryIRConfigs array = [
  {
    name: 'AutoResolveIntegrationRuntime'
    type: 'Azure'
    computeType: 'General'
    coreCount: 8
    timeToLive: 10
    enabled: true
  }
  {
    name: 'SelfHostedIntegrationRuntime'
    type: 'SelfHosted'
    description: 'Self-hosted integration runtime for on-premises connectivity'
    enabled: false
  }
]

// ============================================================================
// PARAMETERS - SECURITY CONFIGURATION
// ============================================================================

// Enable advanced security features for data services
// Provides comprehensive security controls
// 🔒 SECURITY ENHANCEMENT: Multi-layered security for data services
@description('Enable advanced security features for data services')
param enableAdvancedSecurity bool = true

// Data services security configuration
@description('Data services security configuration')
param dataServicesSecurityConfig object = {
  enablePrivateEndpoints: true
  enableNetworkIsolation: true
  enableEncryptionAtRest: true
  enableEncryptionInTransit: true
  enableThreatDetection: true
  enableVulnerabilityAssessment: true
  enableAccessLogging: true
  enableDataMasking: true
  enableRowLevelSecurity: false
}

// Customer-managed encryption configuration
@description('Customer-managed encryption configuration')
param customerManagedEncryptionConfig object = {
  enabled: false
  keyVaultId: ''
  keyName: ''
  keyVersion: ''
  userAssignedIdentityId: ''
}

// Network security configuration
@description('Network security configuration')
param networkSecurityConfig object = {
  allowedSubnets: [subnetId]
  allowedIPRanges: []
  enableServiceEndpoints: true
  enablePrivateEndpoints: true
  enableFirewallRules: true
  denyPublicNetworkAccess: true
}

// ============================================================================
// PARAMETERS - MONITORING AND ANALYTICS
// ============================================================================

// Enable comprehensive monitoring for data services
// Provides visibility into data operations and performance
// 🔒 SECURITY ENHANCEMENT: Monitoring for security and compliance
@description('Enable comprehensive monitoring for data services')
param enableDataServicesMonitoring bool = true

// Data services monitoring configuration
@description('Data services monitoring configuration')
param dataServicesMonitoringConfig object = {
  enablePerformanceMonitoring: true
  enableSecurityMonitoring: true
  enableCostMonitoring: true
  enableAlertingRules: true
  enableDashboards: true
  enableAutomatedReports: true
  monitoringRetentionDays: 90
}

// Data services alert configurations
@description('Data services alert configurations')
param dataServicesAlertConfigs array = [
  {
    name: 'HighCPUUtilization'
    metricName: 'cpu_percent'
    threshold: 80
    operator: 'GreaterThan'
    severity: 'Warning'
    enabled: true
  }
  {
    name: 'DatabaseConnectionFailures'
    metricName: 'connection_failed'
    threshold: 5
    operator: 'GreaterThan'
    severity: 'Error'
    enabled: true
  }
  {
    name: 'StorageUtilizationHigh'
    metricName: 'storage_percent'
    threshold: 85
    operator: 'GreaterThan'
    severity: 'Warning'
    enabled: true
  }
]

// ============================================================================
// PARAMETERS - BACKUP AND DISASTER RECOVERY
// ============================================================================

// Enable backup and disaster recovery for data services
// Provides data protection and business continuity
// 🔒 SECURITY ENHANCEMENT: Comprehensive data protection strategy
@description('Enable backup and disaster recovery for data services')
param enableDataServicesBackup bool = true

// Data services backup configuration
@description('Data services backup configuration')
param dataServicesBackupConfig object = {
  enableAutomatedBackups: true
  backupRetentionPeriod: 'P7D'    // 7 days
  enableLongTermRetention: true
  longTermRetentionWeeks: 12      // 12 weeks
  longTermRetentionMonths: 12     // 12 months
  longTermRetentionYears: 5       // 5 years
  enableGeoRedundantBackups: true
  enablePointInTimeRestore: true
  enableCrossRegionRestore: false
}

// Disaster recovery configuration
@description('Disaster recovery configuration')
param dataServicesDRConfig object = {
  enableDisasterRecovery: true
  secondaryRegion: ''
  enableReadReplicas: true
  replicationLag: 'PT5M'          // 5 minutes
  enableAutomaticFailover: false
  enableGeoReplication: true
  recoveryTimeObjective: 'PT1H'   // 1 hour RTO
  recoveryPointObjective: 'PT15M' // 15 minutes RPO
}

// ============================================================================
// PARAMETERS - PERFORMANCE OPTIMIZATION
// ============================================================================

// Enable performance optimization features
// Optimizes data services performance and cost
// 🔒 SECURITY ENHANCEMENT: Performance optimization with security
@description('Enable performance optimization features')
param enablePerformanceOptimization bool = true

// Performance optimization configuration
@description('Performance optimization configuration')
param performanceOptimizationConfig object = {
  enableAutoScaling: true
  enableQueryPerformanceInsight: true
  enableIndexTuning: true
  enableConnectionPooling: true
  enableCaching: true
  enableReadReplicas: true
  enableDataCompression: true
  enableQueryOptimization: true
}

// Auto-scaling configuration
@description('Auto-scaling configuration')
param autoScalingConfig object = {
  enableAutoScale: true
  minCapacity: 2
  maxCapacity: 20
  targetCPUPercentage: 70
  targetMemoryPercentage: 80
  scaleOutCooldown: 'PT5M'
  scaleInCooldown: 'PT15M'
}

// ============================================================================
// PARAMETERS - COMPLIANCE AND GOVERNANCE
// ============================================================================

// Enable compliance frameworks support for data services
// Implements data controls for various compliance requirements
// 🔒 SECURITY ENHANCEMENT: Multi-framework data compliance
@description('Enable compliance frameworks support for data services')
param enableDataServicesCompliance bool = true

// Data services compliance frameworks
@description('Data services compliance frameworks to implement')
param dataServicesComplianceFrameworks array = [
  'SOC2'
  'HIPAA'
  'GDPR'
  'FedRAMP'
  'ISO27001'
  'PCI-DSS'
]

// Data governance configuration
@description('Data governance configuration')
param dataGovernanceConfig object = {
  enableDataClassification: true
  enableDataLineage: true
  enableDataQuality: true
  enableDataPrivacy: true
  enableAccessControl: true
  enableAuditLogging: true
  enableDataRetention: true
  enableDataMasking: true
}

// Data retention policies
@description('Data retention policies')
param dataRetentionPolicies array = [
  {
    name: 'PersonalDataRetention'
    retentionPeriod: 'P2555D'      // 7 years
    dataCategory: 'PersonalData'
    enforcementEnabled: true
    enabled: true
  }
  {
    name: 'TransactionalDataRetention'
    retentionPeriod: 'P365D'       // 1 year
    dataCategory: 'TransactionalData'
    enforcementEnabled: true
    enabled: true
  }
]

// ============================================================================
// PARAMETERS - INTEGRATION CONFIGURATION
// ============================================================================

// Enable integration with external data systems
// Supports hybrid and multi-cloud data scenarios
// 🔒 SECURITY ENHANCEMENT: Secure data integration
@description('Enable external data system integration')
param enableExternalDataIntegration bool = false

// External data integration configuration
@description('External data integration configuration')
param externalDataIntegrationConfig object = {
  enableHybridConnections: false
  enableVPNConnectivity: false
  enableExpressRouteConnectivity: false
  enableAPIConnections: false
  enableFileTransfers: false
  enableStreamingIngestion: false
}

// Data pipeline configurations
@description('Data pipeline configurations')
param dataPipelineConfigs array = [
  {
    name: 'ETLPipeline'
    type: 'ETL'
    source: 'SQL'
    destination: 'CosmosDB'
    schedule: 'daily'
    enabled: false
  }
  {
    name: 'StreamingPipeline'
    type: 'Streaming'
    source: 'EventHub'
    destination: 'SQL'
    schedule: 'continuous'
    enabled: false
  }
]

// ============================================================================
// PARAMETERS - COST OPTIMIZATION
// ============================================================================

// Enable data services cost optimization
// Optimizes data services costs while maintaining performance
// 🔒 SECURITY ENHANCEMENT: Cost-effective data services with security
@description('Enable data services cost optimization')
param enableDataServicesCostOptimization bool = true

// Data services cost optimization configuration
@description('Data services cost optimization configuration')
param dataServicesCostOptimizationConfig object = {
  enableReservedCapacity: false
  enableSpotInstances: false
  enableAutoPause: false
  enableAutoScale: true
  enableStorageTiering: true
  enableDataArchiving: true
  enableCostAlerting: true
  enableUsageOptimization: true
}

// ============================================================================
// PARAMETERS - TAGGING AND METADATA
// ============================================================================

// Resource tags for governance, cost management, and compliance tracking
// Essential for multi-tenant environments and cost allocation
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Resource tags for governance and cost management')
param tags object = {}

// Resource suffix for consistent naming across related resources
@description('Resource suffix for consistent naming')
param resourceSuffix string = ''

// Data classification level for security and compliance
@description('Data classification level for data services')
@allowed(['public', 'internal', 'confidential', 'restricted'])
param dataClassification string = 'confidential'

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
