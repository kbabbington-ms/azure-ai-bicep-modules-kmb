# Backup & Recovery Module

Enterprise data protection and disaster recovery solution for Azure AI workloads with automated backup policies and site recovery capabilities.

## Features

- **🔄 Azure Backup**: VM and database backup with retention policies
- **🔄 Site Recovery**: Disaster recovery orchestration and failover
- **📊 Backup Reporting**: Compliance and recovery analytics
- **🔒 Security**: Backup encryption and access controls
- **💾 Storage Optimization**: Cost-effective backup storage with lifecycle management
- **🚨 Monitoring**: Backup failure alerts and recovery metrics
- **🛡️ Immutable Backups**: Protection against ransomware and accidental deletion

## Usage

```bicep
module backupRecovery 'modules/backup-recovery/main.bicep' = {
  name: 'enterprise-backup'
  params: {
    location: 'eastus'
    environment: 'prod'
    projectName: 'ai-platform'
    
    // Backup configuration
    enableSiteRecovery: true
    logAnalyticsWorkspaceId: '/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/logs'
    
    tags: {
      Environment: 'Production'
      Application: 'AI Platform'
      Purpose: 'Data Protection'
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
| `enableSiteRecovery` | bool | `true` | Enable disaster recovery capabilities |
| `logAnalyticsWorkspaceId` | string | `''` | Log Analytics workspace for monitoring |

## Security Features

- **🔒 Private Access**: Recovery vault with disabled public network access
- **🔐 Encryption**: Customer-managed encryption for backup data
- **🛡️ Access Control**: RBAC-based backup management
- **📝 Audit Logging**: Comprehensive backup operation logging
- **🚨 Immutable Backups**: Protection against tampering
- **🔄 Secure Transfer**: TLS 1.2+ for all backup operations

## Backup Policies

### VM Backup Policy
- **📅 Schedule**: Daily at 2:00 AM UTC
- **📊 Retention**: 
  - Daily: 30 days
  - Weekly: 12 weeks (Sunday)
  - Monthly: 12 months (First Sunday)
  - Yearly: 7 years (January)

### Database Backup Policy
- **📅 Schedule**: Every 4 hours with daily full backup
- **📊 Retention**:
  - Transaction log: 15 days
  - Full backup: 30 days
  - Weekly: 12 weeks
  - Monthly: 12 months

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `recoveryVaultId` | string | Resource ID of the Recovery Services vault |
| `recoveryVaultName` | string | Name of the Recovery Services vault |
| `backupStorageAccountId` | string | Resource ID of backup storage account |
| `siteRecoveryVaultId` | string | Resource ID of site recovery vault |

## Disaster Recovery

This module provides:
- **🌍 Cross-Region Replication**: Automated failover to secondary regions
- **🔄 Recovery Plans**: Orchestrated recovery procedures
- **⚡ RTO/RPO Optimization**: Configurable recovery time and point objectives
- **🧪 Test Failover**: Non-disruptive disaster recovery testing
- **📊 Recovery Analytics**: Recovery capability monitoring and reporting

## Cost Optimization

- **💾 Cool Storage**: Backup data stored in cost-effective tiers
- **🔄 Lifecycle Management**: Automated transition to archive storage
- **📊 Usage Analytics**: Backup storage optimization recommendations
- **⚖️ Retention Policies**: Automated cleanup of expired backups

## Compliance

This module supports the following compliance standards:
- **SOC 2 Type II**: Data protection and backup controls
- **ISO 27001**: Business continuity requirements
- **GDPR**: Data protection and retention compliance
- **HIPAA**: Healthcare data backup requirements
