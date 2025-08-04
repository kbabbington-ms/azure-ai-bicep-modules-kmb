@description('Backup and disaster recovery for AI Enclave')
param location string = resourceGroup().location
param environment string = 'dev'
param projectName string = 'ai-enclave'
param logAnalyticsWorkspaceId string = ''
param enableSiteRecovery bool = true

// Resource naming
var recoveryVaultName = 'rsv-${projectName}-${environment}-${location}'
var backupStorageAccountName = 'stbkp${replace(projectName, '-', '')}${environment}${uniqueString(resourceGroup().id)}'
var siteRecoveryVaultName = 'srv-${projectName}-${environment}-${location}'

// Recovery Services Vault for Backup
resource recoveryVault 'Microsoft.RecoveryServices/vaults@2023-04-01' = {
  name: recoveryVaultName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Backup vault for AI Enclave'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Backup Storage Account
resource backupStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: backupStorageAccountName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Storage for backup data'
  }
  sku: {
    name: 'Standard_GRS'
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
      requireInfrastructureEncryption: true
    }
    accessTier: 'Cool'
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// VM Backup Policy
resource vmBackupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-04-01' = {
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
resource sqlBackupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-04-01' = {
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
resource fileShareBackupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-04-01' = {
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
resource siteRecoveryVault 'Microsoft.RecoveryServices/vaults@2023-04-01' = if (enableSiteRecovery) {
  name: siteRecoveryVaultName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Site recovery vault for disaster recovery'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Diagnostic Settings for Recovery Vault
resource recoveryVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
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
resource vaultBackupConfig 'Microsoft.RecoveryServices/vaults/backupconfig@2023-04-01' = {
  parent: recoveryVault
  name: 'vaultconfig'
  properties: {
    enhancedSecurityState: 'Enabled'
    softDeleteFeatureState: 'Enabled'
    softDeleteRetentionPeriodInDays: 14
    storageModelType: 'GeoRedundant'
    storageType: 'GeoRedundant'
    storageTypeState: 'Locked'
  }
}

// Backup Storage Redundancy
resource vaultStorageConfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2023-04-01' = {
  parent: recoveryVault
  name: 'vaultstorageconfig'
  properties: {
    storageModelType: 'GeoRedundant'
    crossRegionRestoreFlag: true
  }
}

// Outputs
output recoveryVaultId string = recoveryVault.id
output recoveryVaultName string = recoveryVault.name
output backupStorageAccountId string = backupStorageAccount.id
output backupStorageAccountName string = backupStorageAccount.name
output siteRecoveryVaultId string = enableSiteRecovery ? siteRecoveryVault.id : ''
output vmBackupPolicyId string = vmBackupPolicy.id
output sqlBackupPolicyId string = sqlBackupPolicy.id
output fileShareBackupPolicyId string = fileShareBackupPolicy.id
