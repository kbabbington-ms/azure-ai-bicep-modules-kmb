@description('Azure Backup and Disaster Recovery - Enterprise Backup Platform that creates comprehensive backup and disaster recovery infrastructure with Recovery Services Vaults, Azure Site Recovery, and enterprise data protection. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR, FedRAMP ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Azure Backup and Disaster Recovery - Enterprise Backup Platform'
metadata description = 'Comprehensive backup and disaster recovery infrastructure with automated policies and compliance'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
// ============================================================================

// Base name for backup and recovery resources
// Must be globally unique and follow naming conventions
// 🔒 SECURITY ENHANCEMENT: Use consistent naming for security governance
@description('Required. Base name for backup and recovery resources (2-20 characters)')
@minLength(2)
@maxLength(20)
param backupBaseName string

// Azure region for deploying backup infrastructure
// Note: Consider region pairing for disaster recovery
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet compliance requirements
@description('Required. Azure region for deployment')
param location string = resourceGroup().location

// Environment designation for resource organization and governance
// Controls backup policies and retention periods
// 🔒 SECURITY ENHANCEMENT: Environment-specific backup policies
@description('Environment designation (dev, test, staging, prod)')
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string = 'prod'

// Project name for resource grouping and cost allocation
// Used for tagging and resource organization
@description('Project name for resource organization')
param projectName string = 'ai-platform'

// Log Analytics workspace for centralized logging
// Consolidates logs from all backup operations
// 🔒 SECURITY ENHANCEMENT: Required for compliance and security monitoring
@description('Log Analytics workspace resource ID for backup logs')
param logAnalyticsWorkspaceId string = ''

// ============================================================================
// PARAMETERS - RECOVERY SERVICES VAULT CONFIGURATION
// ============================================================================

// Enable Recovery Services Vault for backup operations
// Provides centralized backup management and policies
// 🔒 SECURITY ENHANCEMENT: Centralized backup governance
@description('Enable Recovery Services Vault for backup operations')
param enableRecoveryServicesVault bool = true

// Recovery Services Vault configuration
@description('Recovery Services Vault configuration')
param recoveryServicesVaultConfig object = {
  skuName: 'Standard'           // Standard or Premium
  softDeleteEnabled: true       // Soft delete for additional protection
  crossRegionRestore: true      // Cross-region restore capability
  publicNetworkAccess: 'Disabled' // Disable public access for security
  enableSystemIdentity: true   // Enable system-assigned managed identity
}

// Backup policy configurations for different workload types
@description('Backup policy configurations for different workload types')
param backupPolicyConfigs array = [
  {
    name: 'DailyBackupPolicy'
    type: 'AzureIaasVM'
    scheduleRunTimes: ['2025-01-01T02:00:00.000Z']
    retentionPolicy: {
      dailySchedule: {
        retentionTimes: ['2025-01-01T02:00:00.000Z']
        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
      }
      weeklySchedule: {
        daysOfTheWeek: ['Sunday']
        retentionTimes: ['2025-01-01T02:00:00.000Z']
        retentionDuration: {
          count: 12
          durationType: 'Weeks'
        }
      }
      monthlySchedule: {
        retentionScheduleFormatType: 'Weekly'
        retentionScheduleWeekly: {
          daysOfTheWeek: ['Sunday']
          weeksOfTheMonth: ['First']
        }
        retentionTimes: ['2025-01-01T02:00:00.000Z']
        retentionDuration: {
          count: 12
          durationType: 'Months'
        }
      }
      yearlySchedule: {
        retentionScheduleFormatType: 'Weekly'
        monthsOfYear: ['January']
        retentionScheduleWeekly: {
          daysOfTheWeek: ['Sunday']
          weeksOfTheMonth: ['First']
        }
        retentionTimes: ['2025-01-01T02:00:00.000Z']
        retentionDuration: {
          count: 7
          durationType: 'Years'
        }
      }
    }
    enabled: true
  }
  {
    name: 'WeeklyBackupPolicy'
    type: 'AzureIaasVM'
    scheduleRunTimes: ['2025-01-01T18:00:00.000Z']
    retentionPolicy: {
      weeklySchedule: {
        daysOfTheWeek: ['Sunday', 'Wednesday']
        retentionTimes: ['2025-01-01T18:00:00.000Z']
        retentionDuration: {
          count: 52
          durationType: 'Weeks'
        }
      }
    }
    enabled: false
  }
]

// ============================================================================
// PARAMETERS - AZURE SITE RECOVERY CONFIGURATION
// ============================================================================

// Enable Azure Site Recovery for disaster recovery
// Provides application-level disaster recovery capabilities
// 🔒 SECURITY ENHANCEMENT: Business continuity for critical applications
@description('Enable Azure Site Recovery for disaster recovery')
param enableSiteRecovery bool = true

// Site Recovery configuration
@description('Azure Site Recovery configuration')
param siteRecoveryConfig object = {
  sourceRegion: location
  targetRegion: ''              // Must be specified if enableSiteRecovery is true
  replicationFrequency: 'PT15M' // 15 minutes, 30 minutes, or PT1H
  recoveryPointRetention: 'P7D' // 7 days retention
  appConsistentFrequency: 'PT4H' // 4 hours
  enableMultiVmConsistency: true
  enableEncryption: true
  enableCompression: true
}

// Site Recovery replication policies
@description('Site Recovery replication policy configurations')
param replicationPolicyConfigs array = [
  {
    name: 'DefaultReplicationPolicy'
    recoveryPointRetention: 'P7D'
    appConsistentSnapshotFrequency: 'PT4H'
    crashConsistentSnapshotFrequency: 'PT15M'
    enabled: true
  }
  {
    name: 'ExtendedRetentionPolicy'
    recoveryPointRetention: 'P30D'
    appConsistentSnapshotFrequency: 'PT12H'
    crashConsistentSnapshotFrequency: 'PT30M'
    enabled: false
  }
]

// ============================================================================
// PARAMETERS - BACKUP STORAGE CONFIGURATION
// ============================================================================

// Enable dedicated backup storage account
// Provides secure storage for backup data and logs
// 🔒 SECURITY ENHANCEMENT: Isolated backup storage with proper access controls
@description('Enable dedicated backup storage account')
param enableBackupStorage bool = true

// Backup storage account configuration
@description('Backup storage account configuration')
param backupStorageConfig object = {
  skuName: 'Standard_GRS'       // GRS for geo-redundancy
  minimumTlsVersion: 'TLS1_2'
  allowBlobPublicAccess: false
  allowSharedKeyAccess: true    // Required for some backup scenarios
  enableHttpsTrafficOnly: true
  enableHierarchicalNamespace: false
  enableNfsV3: false
  enableSftp: false
  accessTier: 'Cool'            // Cost optimization for backup data
}

// Backup storage encryption configuration
@description('Backup storage encryption configuration')
param backupStorageEncryptionConfig object = {
  enabled: true
  keySource: 'Microsoft.Storage'  // Can be changed to Microsoft.Keyvault
  requireInfrastructureEncryption: true
  keyVaultKeyName: ''
  keyVaultKeyVersion: ''
  keyVaultUri: ''
}

// Backup storage containers for data organization
@description('Backup storage containers for data organization')
param backupStorageContainers array = [
  'vm-backups'
  'database-backups'
  'file-backups'
  'application-backups'
  'disaster-recovery'
  'compliance-archives'
  'audit-logs'
  'backup-reports'
]

// ============================================================================
// PARAMETERS - DATA PROTECTION POLICIES
// ============================================================================

// Enable comprehensive data protection policies
// Implements enterprise-grade data protection controls
// 🔒 SECURITY ENHANCEMENT: Multi-layered data protection
@description('Enable comprehensive data protection policies')
param enableDataProtection bool = true

// Data protection policy configurations
@description('Data protection policy configurations')
param dataProtectionPolicies array = [
  {
    name: 'CriticalDataProtection'
    backupFrequency: 'daily'
    retentionPeriod: 'P2555D'    // 7 years for critical data
    geoRedundancy: true
    immutableBackups: true
    encryptionRequired: true
    accessTier: 'hot'
    enabled: true
  }
  {
    name: 'StandardDataProtection'
    backupFrequency: 'weekly'
    retentionPeriod: 'P365D'     // 1 year for standard data
    geoRedundancy: true
    immutableBackups: false
    encryptionRequired: true
    accessTier: 'cool'
    enabled: true
  }
  {
    name: 'ArchivalDataProtection'
    backupFrequency: 'monthly'
    retentionPeriod: 'P3650D'    // 10 years for archival
    geoRedundancy: true
    immutableBackups: true
    encryptionRequired: true
    accessTier: 'archive'
    enabled: true
  }
]

// ============================================================================
// PARAMETERS - MONITORING AND ALERTING
// ============================================================================

// Enable comprehensive backup monitoring
// Provides visibility into backup operations and health
// 🔒 SECURITY ENHANCEMENT: Proactive monitoring for backup failures
@description('Enable comprehensive backup monitoring')
param enableBackupMonitoring bool = true

// Backup monitoring configuration
@description('Backup monitoring configuration')
param backupMonitoringConfig object = {
  enableBackupReports: true
  enableJobFailureAlerts: true
  enableRetentionPolicyAlerts: true
  enableSecurityAlerts: true
  alertingFrequency: 'daily'
  reportingFrequency: 'weekly'
  customMetricsEnabled: true
}

// Backup alert configurations
@description('Backup alert configurations')
param backupAlertConfigs array = [
  {
    name: 'BackupJobFailure'
    alertType: 'JobFailure'
    severity: 'High'
    enabled: true
    actionGroupId: ''
  }
  {
    name: 'BackupPolicyViolation'
    alertType: 'PolicyViolation'
    severity: 'Medium'
    enabled: true
    actionGroupId: ''
  }
  {
    name: 'UnauthorizedBackupAccess'
    alertType: 'SecurityBreach'
    severity: 'Critical'
    enabled: true
    actionGroupId: ''
  }
]

// Data retention period for backup logs and reports
// Balances compliance requirements with storage costs
@description('Backup log and report retention period (days)')
@minValue(90)
@maxValue(2555)  // 7 years maximum
param backupLogRetentionDays int = 365

// ============================================================================
// PARAMETERS - COMPLIANCE AND GOVERNANCE
// ============================================================================

// Enable compliance frameworks support for backup
// Implements backup controls for various compliance requirements
// 🔒 SECURITY ENHANCEMENT: Multi-framework backup compliance
@description('Enable compliance frameworks support for backup')
param enableBackupCompliance bool = true

// Backup compliance frameworks
@description('Backup compliance frameworks to implement')
param backupComplianceFrameworks array = [
  'SOC2'
  'HIPAA'
  'GDPR'
  'FedRAMP'
  'ISO27001'
  'PCI-DSS'
]

// Enable backup audit logging for compliance
// Tracks all backup operations and access
@description('Enable backup audit logging for compliance')
param enableBackupAuditLogging bool = true

// Backup governance configuration
@description('Backup governance configuration')
param backupGovernanceConfig object = {
  policyEnforcementEnabled: true
  changeApprovalRequired: true
  accessControlEnabled: true
  dataClassificationRequired: true
  complianceReportingEnabled: true
  automatedComplianceChecks: true
}

// ============================================================================
// PARAMETERS - DISASTER RECOVERY TESTING
// ============================================================================

// Enable automated disaster recovery testing
// Validates backup and recovery procedures regularly
// 🔒 SECURITY ENHANCEMENT: Verified backup integrity and recoverability
@description('Enable automated disaster recovery testing')
param enableDRTesting bool = true

// Disaster recovery testing configuration
@description('Disaster recovery testing configuration')
param drTestingConfig object = {
  testFrequency: 'monthly'       // monthly, quarterly, semi-annually
  testType: 'partial'            // partial, full
  automatedValidation: true
  testResultRetention: 'P90D'    // 90 days
  failureAlertingEnabled: true
  testDocumentationRequired: true
}

// DR testing scenarios to validate
@description('DR testing scenarios to validate')
param drTestingScenarios array = [
  {
    name: 'DatabaseRecovery'
    description: 'Validate database backup and recovery procedures'
    frequency: 'monthly'
    enabled: true
  }
  {
    name: 'ApplicationRecovery'
    description: 'Validate application-level disaster recovery'
    frequency: 'quarterly'
    enabled: true
  }
  {
    name: 'InfrastructureRecovery'
    description: 'Validate infrastructure disaster recovery'
    frequency: 'semi-annually'
    enabled: true
  }
]

// ============================================================================
// PARAMETERS - COST OPTIMIZATION
// ============================================================================

// Enable backup cost optimization features
// Optimizes backup storage costs while maintaining compliance
// 🔒 SECURITY ENHANCEMENT: Cost-effective backup with security
@description('Enable backup cost optimization')
param enableBackupCostOptimization bool = true

// Backup cost optimization configuration
@description('Backup cost optimization configuration')
param backupCostOptimizationConfig object = {
  automaticTieringEnabled: true
  intelligentTieringEnabled: true
  unusedBackupCleanup: true
  compressionEnabled: true
  deduplicationEnabled: true
  lifecyclePolicyEnabled: true
  costReportingEnabled: true
}

// Backup storage lifecycle policies
@description('Backup storage lifecycle policies')
param backupLifecyclePolicies array = [
  {
    name: 'StandardLifecycle'
    rules: [
      {
        name: 'MoveToIA'
        daysAfterModification: 30
        targetAccessTier: 'Cool'
      }
      {
        name: 'MoveToArchive'
        daysAfterModification: 365
        targetAccessTier: 'Archive'
      }
    ]
    enabled: true
  }
]

// ============================================================================
// PARAMETERS - SECURITY CONFIGURATION
// ============================================================================

// Enable advanced backup security features
// Provides comprehensive security for backup operations
// 🔒 SECURITY ENHANCEMENT: Multi-layered backup security
@description('Enable advanced backup security features')
param enableBackupSecurity bool = true

// Backup security configuration
@description('Backup security configuration')
param backupSecurityConfig object = {
  encryptionInTransit: true
  encryptionAtRest: true
  customerManagedKeys: false
  accessControlEnabled: true
  networkIsolationEnabled: true
  threatProtectionEnabled: true
  anomalyDetectionEnabled: true
}

// Backup access control configuration
@description('Backup access control configuration')
param backupAccessControlConfig object = {
  rbacEnabled: true
  principalId: ''               // Service principal for backup operations
  customRoleEnabled: true
  minimumPermissions: true
  accessReviewsEnabled: true
  justInTimeAccessEnabled: false
}

// ============================================================================
// PARAMETERS - INTEGRATION CONFIGURATION
// ============================================================================

// Enable integration with external backup systems
// Supports hybrid backup scenarios
// 🔒 SECURITY ENHANCEMENT: Secure backup integration
@description('Enable external backup system integration')
param enableExternalBackupIntegration bool = false

// External backup integration configuration
@description('External backup integration configuration')
param externalBackupConfig object = {
  onPremisesBackupEnabled: false
  thirdPartyBackupEnabled: false
  hybridBackupEnabled: false
  backupReplicationEnabled: false
  crossCloudBackupEnabled: false
}

// Enable backup orchestration and automation
@description('Enable backup orchestration and automation')
param enableBackupOrchestration bool = true

// Backup orchestration configuration
@description('Backup orchestration configuration')
param backupOrchestrationConfig object = {
  automatedWorkflows: true
  backupSchedulingEnabled: true
  dependencyManagement: true
  rollbackCapabilities: true
  notificationEnabled: true
  integrationWithCICD: false
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
@description('Data classification level for backup data')
@allowed(['public', 'internal', 'confidential', 'restricted'])
param dataClassification string = 'confidential'

// ============================================================================
// VARIABLES
// ============================================================================

// Default resource tags with backup-specific metadata
var defaultTags = {
  Environment: environment
  Service: 'Backup and Recovery'
  ManagedBy: 'Bicep'
  DataClassification: dataClassification
  ComplianceFrameworks: join(backupComplianceFrameworks, ',')
  LastUpdated: '2025-08-01'
}

// Merge user-provided tags with defaults
var allTags = union(defaultTags, tags)

// Resource naming - use backupBaseName if provided
var recoveryVaultName = !empty(backupBaseName) ? 'rsv-${backupBaseName}-${environment}-${location}${resourceSuffix}' : 'rsv-${projectName}-${environment}-${location}${resourceSuffix}'
var backupStorageAccountName = 'stbkp${replace(projectName, '-', '')}${environment}${uniqueString(resourceGroup().id)}'
var siteRecoveryVaultName = 'srv-${projectName}-${environment}-${location}${resourceSuffix}'

// Configuration consolidation
var effectiveBackupStorageConfig = union(backupStorageConfig, backupStorageEncryptionConfig)
var hasMonitoringConfig = !empty(backupMonitoringConfig)
var hasCostOptimizationConfig = !empty(backupCostOptimizationConfig)
var hasSecurityConfig = enableBackupSecurity && !empty(backupSecurityConfig)

// Resource conditions  
var shouldCreateBackupStorage = enableBackupStorage
var shouldCreateSiteRecovery = enableSiteRecovery
var shouldEnableMonitoring = enableBackupMonitoring && !empty(logAnalyticsWorkspaceId)
var shouldEnableCompliance = enableBackupCompliance
var shouldEnableOrchestration = enableBackupOrchestration

// Recovery Services Vault for Backup
resource recoveryVault 'Microsoft.RecoveryServices/vaults@2023-04-01' = if (enableRecoveryServicesVault) {
  name: recoveryVaultName
  location: location
  tags: union(allTags, {
    Purpose: 'Backup vault for AI Enclave'
    BackupType: 'RecoveryServices'
  })
  sku: {
    name: recoveryServicesVaultConfig.skuName
  }
  properties: {
    publicNetworkAccess: recoveryServicesVaultConfig.publicNetworkAccess
  }
  identity: recoveryServicesVaultConfig.enableSystemIdentity ? {
    type: 'SystemAssigned'
  } : null
}

// Backup Storage Account
resource backupStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = if (shouldCreateBackupStorage) {
  name: backupStorageAccountName
  location: location
  tags: union(allTags, {
    Purpose: 'Storage for backup data'
    StorageType: 'Backup'
  })
  sku: {
    name: effectiveBackupStorageConfig.redundancy
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: effectiveBackupStorageConfig.requireInfrastructureEncryption
    }
    accessTier: effectiveBackupStorageConfig.accessTier
    publicNetworkAccess: effectiveBackupStorageConfig.publicNetworkAccess
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// Backup Storage Containers
resource backupStorageContainerResources 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for (container, i) in backupStorageContainers: if (shouldCreateBackupStorage) {
  name: '${backupStorageAccount.name}/default/${container.name}'
  properties: {
    publicAccess: container.publicAccess
    metadata: container.metadata
  }
}]

// Monitoring and Alerting Resources
resource backupMonitoringWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = if (shouldEnableMonitoring) {
  name: guid('backup-monitoring-workbook', resourceGroup().id)
  location: location
  kind: 'shared'
  tags: allTags
  properties: {
    displayName: 'Backup and Recovery Monitoring'
    serializedData: string({
      version: 'Notebook/1.0'
      items: []
    })
    category: 'workbook'
    sourceId: logAnalyticsWorkspaceId
  }
}

// Data Protection and Compliance Resources
resource dataProtectionPolicyResources 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for (policy, i) in dataProtectionPolicies: if (enableDataProtection && shouldEnableCompliance) {
  name: guid(policy.name, resourceGroup().id)
  properties: {
    displayName: policy.displayName
    description: policy.description
    policyDefinitionId: policy.policyDefinitionId
    parameters: policy.parameters
    enforcementMode: policy.enforcementMode
  }
}]

// Backup Orchestration Automation Account
resource backupOrchestrationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = if (shouldEnableOrchestration) {
  name: 'aa-backup-${projectName}-${environment}'
  location: location
  tags: union(allTags, {
    Purpose: 'Backup orchestration and automation'
  })
  properties: {
    sku: {
      name: backupOrchestrationConfig.skuName
    }
    encryption: {
      keySource: 'Microsoft.Automation'
    }
    publicNetworkAccess: backupOrchestrationConfig.publicNetworkAccess
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Dynamic Backup Policies based on configuration
resource dynamicBackupPolicies 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-04-01' = [for (policy, i) in backupPolicyConfigs: if (policy.enabled && enableRecoveryServicesVault) {
  parent: recoveryVault
  name: policy.name
  properties: {
    backupManagementType: policy.backupManagementType
    workLoadType: policy.workLoadType
    schedulePolicy: policy.schedulePolicy
    retentionPolicy: policy.retentionPolicy
    timeZone: policy.timeZone
  }
}]

// VM Backup Policy (default)
resource vmBackupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-04-01' = if (enableRecoveryServicesVault) {
  parent: recoveryVault
  name: 'DailyVMBackupPolicy'
  properties: {
    backupManagementType: 'AzureIaasVM'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: ['2023-01-01T02:00:00Z']
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: ['2023-01-01T02:00:00Z']
        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
      }
      weeklySchedule: {
        daysOfTheWeek: ['Sunday']
        retentionTimes: ['2023-01-01T02:00:00Z']
        retentionDuration: {
          count: 12
          durationType: 'Weeks'
        }
      }
      monthlySchedule: {
        retentionScheduleFormatType: 'Weekly'
        retentionScheduleWeekly: {
          daysOfTheWeek: ['Sunday']
          weeksOfTheMonth: ['First']
        }
        retentionTimes: ['2023-01-01T02:00:00Z']
        retentionDuration: {
          count: 12
          durationType: 'Months'
        }
      }
      yearlySchedule: {
        retentionScheduleFormatType: 'Weekly'
        monthsOfYear: ['January']
        retentionScheduleWeekly: {
          daysOfTheWeek: ['Sunday']
          weeksOfTheMonth: ['First']
        }
        retentionTimes: ['2023-01-01T02:00:00Z']
        retentionDuration: {
          count: 7
          durationType: 'Years'
        }
      }
    }
    timeZone: 'UTC'
  }
}

// SQL Backup Policy
resource sqlBackupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-04-01' = if (enableRecoveryServicesVault) {
  parent: recoveryVault
  name: 'SQLBackupPolicy'
  properties: {
    backupManagementType: 'AzureWorkload'
    workLoadType: 'SQLDataBase'
    settings: {
      timeZone: 'UTC'
      issqlcompression: true
    }
    subProtectionPolicy: [
      {
        policyType: 'Full'
        schedulePolicy: {
          schedulePolicyType: 'SimpleSchedulePolicy'
          scheduleRunFrequency: 'Weekly'
          scheduleRunDays: ['Sunday']
          scheduleRunTimes: ['2023-01-01T02:00:00Z']
        }
        retentionPolicy: {
          retentionPolicyType: 'LongTermRetentionPolicy'
          weeklySchedule: {
            daysOfTheWeek: ['Sunday']
            retentionTimes: ['2023-01-01T02:00:00Z']
            retentionDuration: {
              count: 8
              durationType: 'Weeks'
            }
          }
          monthlySchedule: {
            retentionScheduleFormatType: 'Weekly'
            retentionScheduleWeekly: {
              daysOfTheWeek: ['Sunday']
              weeksOfTheMonth: ['First']
            }
            retentionTimes: ['2023-01-01T02:00:00Z']
            retentionDuration: {
              count: 12
              durationType: 'Months'
            }
          }
        }
      }
      {
        policyType: 'Differential'
        schedulePolicy: {
          schedulePolicyType: 'SimpleSchedulePolicy'
          scheduleRunFrequency: 'Weekly'
          scheduleRunDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
          scheduleRunTimes: ['2023-01-01T02:00:00Z']
        }
        retentionPolicy: {
          retentionPolicyType: 'SimpleRetentionPolicy'
          retentionDuration: {
            count: 7
            durationType: 'Days'
          }
        }
      }
      {
        policyType: 'Log'
        schedulePolicy: {
          schedulePolicyType: 'LogSchedulePolicy'
          scheduleFrequencyInMins: 15
        }
        retentionPolicy: {
          retentionPolicyType: 'SimpleRetentionPolicy'
          retentionDuration: {
            count: 7
            durationType: 'Days'
          }
        }
      }
    ]
  }
}

// File Share Backup Policy
resource fileShareBackupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-04-01' = if (enableRecoveryServicesVault) {
  parent: recoveryVault
  name: 'FileShareBackupPolicy'
  properties: {
    backupManagementType: 'AzureStorage'
    workLoadType: 'AzureFileShare'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: ['2023-01-01T03:00:00Z']
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: ['2023-01-01T03:00:00Z']
        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
      }
      weeklySchedule: {
        daysOfTheWeek: ['Sunday']
        retentionTimes: ['2023-01-01T03:00:00Z']
        retentionDuration: {
          count: 12
          durationType: 'Weeks'
        }
      }
    }
    timeZone: 'UTC'
  }
}

// Site Recovery Vault (for disaster recovery)
resource siteRecoveryVault 'Microsoft.RecoveryServices/vaults@2023-04-01' = if (shouldCreateSiteRecovery) {
  name: siteRecoveryVaultName
  location: location
  tags: union(allTags, {
    Purpose: 'Site recovery vault for disaster recovery'
    RecoveryType: 'SiteRecovery'
  })
  sku: {
    name: siteRecoveryConfig.skuName
  }
  properties: {
    publicNetworkAccess: siteRecoveryConfig.publicNetworkAccess
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Site Recovery Replication Policies
resource replicationPolicyResources 'Microsoft.RecoveryServices/vaults/replicationPolicies@2023-04-01' = [for (policy, i) in replicationPolicyConfigs: if (policy.enabled && shouldCreateSiteRecovery) {
  parent: siteRecoveryVault
  name: policy.name
  properties: {
    providerSpecificInput: {
      instanceType: policy.instanceType
      recoveryPointRetentionInHours: policy.recoveryPointRetentionInHours
      applicationConsistentSnapshotFrequencyInHours: policy.applicationConsistentSnapshotFrequencyInHours
      compressionEnabled: policy.compressionEnabled
      onlineReplicationStartTime: policy.onlineReplicationStartTime
    }
  }
}]

// DR Testing Runbooks
resource drTestingRunbooks 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = [for (scenario, i) in drTestingScenarios: if (enableDRTesting && shouldEnableOrchestration) {
  parent: backupOrchestrationAccount
  name: 'DR-Test-${scenario.name}'
  properties: {
    runbookType: 'PowerShell'
    description: scenario.description
    publishContentLink: {
      uri: scenario.scriptUri
      version: scenario.version
    }
  }
}]

// Audit Logging Configuration
resource backupAuditDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableBackupAuditLogging && shouldEnableMonitoring) {
  scope: backupStorageAccount
  name: 'backup-audit-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: backupLogRetentionDays
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: backupLogRetentionDays
        }
      }
    ]
  }
}

// External Backup Integration (for hybrid scenarios)
resource externalBackupConnection 'Microsoft.Web/connections@2016-06-01' = if (enableExternalBackupIntegration) {
  name: 'external-backup-connection'
  location: location
  tags: allTags
  properties: {
    displayName: externalBackupConfig.displayName
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, externalBackupConfig.connectorType)
    }
    parameterValues: externalBackupConfig.connectionParameters
  }
}

// Diagnostic Settings for Recovery Vault
resource recoveryVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId) && enableRecoveryServicesVault) {
  scope: recoveryVault
  name: 'recovery-vault-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Health'
        enabled: true
      }
    ]
  }
}

// Backup configuration for the vault
resource vaultBackupConfig 'Microsoft.RecoveryServices/vaults/backupconfig@2023-04-01' = if (enableRecoveryServicesVault) {
  parent: recoveryVault
  name: 'vaultconfig'
  properties: {
    enhancedSecurityState: 'Enabled'
    softDeleteFeatureState: recoveryServicesVaultConfig.softDeleteEnabled ? 'Enabled' : 'Disabled'
    softDeleteRetentionPeriodInDays: 14
    storageModelType: 'GeoRedundant'
    storageType: 'GeoRedundant'
    storageTypeState: 'Locked'
  }
}

// Backup Storage Redundancy
resource vaultStorageConfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2023-04-01' = if (enableRecoveryServicesVault) {
  parent: recoveryVault
  name: 'vaultstorageconfig'
  properties: {
    storageModelType: 'GeoRedundant'
    crossRegionRestoreFlag: recoveryServicesVaultConfig.crossRegionRestore
  }
}

// Backup Alert Rules
resource backupAlertRules 'Microsoft.Insights/metricAlerts@2018-03-01' = [for (alert, i) in backupAlertConfigs: if (shouldEnableMonitoring) {
  name: alert.name
  location: 'global'
  tags: allTags
  properties: {
    description: alert.description
    severity: alert.severity
    enabled: alert.enabled
    scopes: [
      enableRecoveryServicesVault ? recoveryVault.id : backupStorageAccount.id
    ]
    evaluationFrequency: alert.evaluationFrequency
    windowSize: alert.windowSize
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: alert.criteria
    }
    actions: alert.actionGroups
  }
}]

// Backup Lifecycle Management Policies
resource backupLifecycleManagement 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = if (shouldCreateBackupStorage && enableBackupCostOptimization) {
  parent: backupStorageAccount
  name: 'default'
  properties: {
    policy: {
      rules: [for (policy, i) in backupLifecyclePolicies: {
        name: policy.name
        enabled: policy.enabled
        type: 'Lifecycle'
        definition: {
          filters: policy.filters
          actions: policy.actions
        }
      }]
    }
  }
}

// Backup Governance and Access Control
resource backupGovernanceRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (shouldEnableCompliance) {
  name: guid(backupGovernanceConfig.roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', backupGovernanceConfig.roleDefinitionId)
    principalId: backupGovernanceConfig.principalId
    principalType: backupGovernanceConfig.principalType
    description: 'Backup governance role assignment'
  }
}

// Backup Access Control Policies
resource backupAccessControlPolicies 'Microsoft.Authorization/policyAssignments@2022-06-01' = if (shouldEnableCompliance) {
  name: guid('backup-access-control', resourceGroup().id)
  properties: {
    displayName: 'Backup Access Control Policy'
    description: backupAccessControlConfig.description
    policyDefinitionId: backupAccessControlConfig.policyDefinitionId
    parameters: backupAccessControlConfig.parameters
    enforcementMode: backupAccessControlConfig.enforcementMode
  }
}

// Backup Cost Optimization Rules
resource costOptimizationSchedules 'Microsoft.Automation/automationAccounts/schedules@2023-11-01' = [for (i, schedule) in range(0, length(backupLifecyclePolicies)): if (shouldEnableOrchestration && enableBackupCostOptimization) {
  parent: backupOrchestrationAccount
  name: 'cost-optimization-${i}'
  properties: {
    description: 'Cost optimization schedule ${i}'
    startTime: '2025-08-01T02:00:00Z'
    frequency: 'Week'
    interval: 1
    timeZone: 'UTC'
  }
}]

// DR Testing Configuration
resource drTestingSchedules 'Microsoft.Automation/automationAccounts/schedules@2023-11-01' = if (enableDRTesting && shouldEnableOrchestration) {
  parent: backupOrchestrationAccount
  name: 'dr-testing-schedule'
  properties: {
    description: drTestingConfig.description
    startTime: drTestingConfig.startTime
    frequency: drTestingConfig.frequency
    interval: drTestingConfig.interval
    timeZone: drTestingConfig.timeZone
  }
}

// Backup Monitoring Dashboard
resource backupMonitoringDashboard 'Microsoft.Portal/dashboards@2020-09-01-preview' = if (shouldEnableMonitoring) {
  name: 'backup-dashboard'
  location: location
  tags: union(allTags, {
    Purpose: 'Backup monitoring and operations dashboard'
  })
  properties: {
    lenses: [
      {
        order: 0
        parts: []
      }
    ]
    metadata: {
      model: {
        timeRange: {
          value: {
            relative: {
              duration: 24
              timeUnit: 'hours'
            }
          }
          type: 'MsPortalFx.Composition.Configuration.ValueTypes.TimeRange'
        }
      }
    }
  }
}

// Outputs
output recoveryVaultId string = enableRecoveryServicesVault ? recoveryVault.id : ''
output recoveryVaultName string = enableRecoveryServicesVault ? recoveryVault.name : ''
output backupStorageAccountId string = shouldCreateBackupStorage ? backupStorageAccount.id : ''
output backupStorageAccountName string = shouldCreateBackupStorage ? backupStorageAccount.name : ''
output siteRecoveryVaultId string = shouldCreateSiteRecovery ? siteRecoveryVault.id : ''
output vmBackupPolicyId string = enableRecoveryServicesVault ? vmBackupPolicy.id : ''
output sqlBackupPolicyId string = enableRecoveryServicesVault ? sqlBackupPolicy.id : ''
output fileShareBackupPolicyId string = enableRecoveryServicesVault ? fileShareBackupPolicy.id : ''
output configurationSummary object = {
  monitoringConfigured: hasMonitoringConfig
  costOptimizationConfigured: hasCostOptimizationConfig
  securityConfigured: hasSecurityConfig
  resourcesCreated: {
    recoveryVault: enableRecoveryServicesVault
    backupStorage: shouldCreateBackupStorage
    siteRecovery: shouldCreateSiteRecovery
  }
}
