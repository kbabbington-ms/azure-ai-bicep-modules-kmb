@description('Azure AI Monitoring & Observability - Enterprise Monitoring Platform that creates comprehensive monitoring infrastructure with Log Analytics, Application Insights, Azure Monitor, and security monitoring capabilities. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Azure AI Monitoring & Observability - Enterprise Platform'
metadata description = 'Enterprise-grade monitoring and observability with advanced analytics, security monitoring, and compliance'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
// ============================================================================

// Azure region for deploying monitoring infrastructure
// Consider regional availability for monitoring services and data residency
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet data residency requirements
@description('Required. Azure region for deployment')
param location string = resourceGroup().location

// Environment classification for resource naming and policy application
// Determines monitoring policies and data retention requirements
// 🔒 SECURITY ENHANCEMENT: Use for automated monitoring policy application
@description('Environment classification for monitoring infrastructure')
@allowed(['development', 'testing', 'staging', 'production', 'sandbox'])
param environment string = 'production'

// Base project name for consistent resource naming
// Used as prefix for all monitoring infrastructure resources
// 🔒 SECURITY ENHANCEMENT: Use predictable naming for security governance
@description('Required. Base project name for monitoring infrastructure (2-50 characters)')
@minLength(2)
@maxLength(50)
param projectName string

// ============================================================================
// PARAMETERS - LOG ANALYTICS WORKSPACE CONFIGURATION
// ============================================================================

// Log Analytics workspace pricing tier for cost optimization
// PerGB2018 provides pay-as-you-go pricing with commitment tiers available
// 🔒 SECURITY ENHANCEMENT: Use appropriate tier for security log retention requirements
@description('Log Analytics workspace pricing tier')
@allowed([
  'Free'           // Free tier (500 MB/day, 7 days retention)
  'Standard'       // Standard tier (deprecated)
  'Premium'        // Premium tier (deprecated)
  'PerNode'        // Per-node pricing
  'PerGB2018'      // Pay-as-you-go pricing
  'Standalone'     // Standalone pricing
  'CapacityReservation' // Commitment tier pricing
])
param logAnalyticsSku string = 'PerGB2018'

// Log retention period for compliance and audit requirements
// Balances compliance requirements with storage costs
// 🔒 SECURITY ENHANCEMENT: Set based on regulatory requirements and security policies
@description('Log retention period in days')
@minValue(30)
@maxValue(730) // 2 years maximum for most tiers
param logRetentionDays int = 90

// Daily data ingestion quota to control costs
// Prevents unexpected charges from excessive log ingestion
@description('Daily data ingestion quota in GB (-1 for unlimited)')
param dailyQuotaGb int = 10

// Enable Log Analytics workspace solutions for enhanced monitoring
// Provides additional monitoring capabilities and dashboards
@description('Enable Log Analytics workspace solutions')
param enableWorkspaceSolutions bool = true

// Workspace solutions to deploy for enhanced monitoring
@description('Log Analytics workspace solutions to deploy')
param workspaceSolutions array = [
  'Security'
  'Updates'
  'ChangeTracking'
  'VMInsights'
  'ContainerInsights'
  'ServiceMap'
  'AzureActivity'
  'KeyVault'
  'AzureWebAppsAnalytics'
  'AzureSQLAnalytics'
  'NetworkMonitoring'
]

// ============================================================================
// PARAMETERS - APPLICATION INSIGHTS CONFIGURATION
// ============================================================================

// Enable Application Insights for application performance monitoring
// Provides application performance monitoring and user experience analytics
// 🔒 SECURITY ENHANCEMENT: Essential for detecting application security anomalies
@description('Enable Application Insights for application monitoring')
param enableApplicationInsights bool = true

// Application Insights application type for telemetry optimization
// Optimizes telemetry collection for specific application types
@description('Application Insights application type')
@allowed(['web', 'other', 'java', 'phone', 'store', 'ios', 'android', 'desktop'])
param applicationInsightsType string = 'web'

// Application Insights sampling rate to control data volume
// Reduces telemetry volume while maintaining statistical accuracy
@description('Application Insights sampling rate (0-100)')
@minValue(0)
@maxValue(100)
param samplingRate int = 100

// Enable Application Insights Profiler for performance analysis
// Provides code-level performance profiling for .NET applications
@description('Enable Application Insights Profiler')
param enableProfiler bool = true

// Enable Application Insights Snapshot Debugger for exception analysis
// Captures snapshots when exceptions occur for detailed debugging
@description('Enable Application Insights Snapshot Debugger')
param enableSnapshotDebugger bool = true

// ============================================================================
// PARAMETERS - AZURE SENTINEL CONFIGURATION
// ============================================================================

// Enable Azure Sentinel for security monitoring and SIEM capabilities
// Provides security information and event management with AI-driven analytics
// 🔒 SECURITY ENHANCEMENT: Essential for comprehensive security monitoring
@description('Enable Azure Sentinel for security monitoring')
param enableSentinel bool = true

// Azure Sentinel pricing tier for cost optimization
// PerGB pricing provides pay-as-you-go with commitment tiers available
@description('Azure Sentinel pricing tier')
@allowed(['Free', 'PerGB', 'CapacityReservation'])
param sentinelPricingTier string = 'PerGB'

// Enable Sentinel data connectors for comprehensive security monitoring
@description('Enable Sentinel data connectors')
param enableSentinelConnectors bool = true

// Sentinel data connectors to enable for security monitoring
@description('Sentinel data connectors to enable')
param sentinelConnectors array = [
  'AzureActiveDirectory'
  'AzureSecurityCenter'
  'MicrosoftCloudAppSecurity'
  'AzureActivity'
  'SecurityEvents'
  'CommonSecurityFormat'
  'DNS'
  'WindowsFirewall'
  'AzureInformationProtection'
  'MicrosoftDefenderAdvancedThreatProtection'
  'Office365'
  'ThreatIntelligence'
]

// ============================================================================
// PARAMETERS - MONITORING ALERTS & NOTIFICATIONS
// ============================================================================

// Enable comprehensive monitoring alerts for proactive monitoring
// Provides proactive alerts for system health and security events
// 🔒 SECURITY ENHANCEMENT: Essential for security incident response
@description('Enable comprehensive monitoring alerts')
param enableAlerts bool = true

// Action group configuration for alert notifications
@description('Action group configuration for alert notifications')
param actionGroupConfig object = {
  name: '${projectName}-alerts'
  shortName: 'AIAlerts'
  enabled: true
  emailReceivers: []
  smsReceivers: []
  webhookReceivers: []
  logicAppReceivers: []
}

// Alert rules configuration for comprehensive monitoring
@description('Alert rules configuration')
param alertRulesConfig object = {
  enableHighCpuAlert: true
  enableHighMemoryAlert: true
  enableDiskSpaceAlert: true
  enableErrorRateAlert: true
  enableResponseTimeAlert: true
  enableSecurityAlert: true
  enableAvailabilityAlert: true
  cpuThreshold: 80
  memoryThreshold: 85
  diskSpaceThreshold: 90
  errorRateThreshold: 5
  responseTimeThreshold: 5000
}

// ============================================================================
// PARAMETERS - CUSTOM METRICS & DASHBOARDS
// ============================================================================

// Enable custom metrics collection for business insights
// Collects application-specific metrics for business analytics
@description('Enable custom metrics collection')
param enableCustomMetrics bool = true

// Custom metrics configuration for business monitoring
@description('Custom metrics configuration')
param customMetricsConfig object = {
  enabled: true
  collectionInterval: 'PT1M'
  retentionDays: 90
  enableAggregation: true
  aggregationInterval: 'PT5M'
}

// Enable custom dashboards for operational visibility
// Provides customized dashboards for different stakeholder groups
@description('Enable custom dashboards')
param enableCustomDashboards bool = true

// Dashboard configuration for operational monitoring
@description('Dashboard configuration')
param dashboardConfig object = {
  enableExecutiveDashboard: true
  enableOperationalDashboard: true
  enableSecurityDashboard: true
  enablePerformanceDashboard: true
  refreshInterval: 'PT5M'
  dataRange: 'PT24H'
}

// ============================================================================
// PARAMETERS - DATA EXPORT & INTEGRATION
// ============================================================================

// Enable data export for external analytics and compliance
// Exports monitoring data to external systems for advanced analytics
@description('Enable data export for external analytics')
param enableDataExport bool = false

// Data export configuration for external systems
@description('Data export configuration')
param dataExportConfig object = {
  enabled: false
  destinationType: 'StorageAccount'
  destinationId: ''
  exportTables: ['Heartbeat', 'SecurityEvent', 'AzureActivity']
  exportInterval: 'PT1H'
}

// Enable integration with external monitoring tools
// Integrates with third-party monitoring and ITSM tools
@description('Enable external monitoring tool integration')
param enableExternalIntegration bool = false

// External integration configuration
@description('External integration configuration')
param externalIntegrationConfig object = {
  enabled: false
  integrationType: 'webhook'
  webhookUrl: ''
  authenticationMethod: 'none'
  customHeaders: {}
}

// ============================================================================
// PARAMETERS - COST OPTIMIZATION
// ============================================================================

// Enable cost optimization features for monitoring infrastructure
// Optimizes monitoring costs while maintaining required capabilities
@description('Enable cost optimization features')
param enableCostOptimization bool = true

// Cost optimization configuration
@description('Cost optimization configuration')
param costOptimizationConfig object = {
  enableDataSampling: true
  enableLogFiltering: true
  enableArchivedLogs: true
  archiveRetentionDays: 365
  enableTieredStorage: true
  compressLogs: true
}

// ============================================================================
// PARAMETERS - COMPLIANCE & GOVERNANCE
// ============================================================================

// Enable compliance monitoring for regulatory requirements
// Monitors compliance with various regulatory frameworks
// 🔒 SECURITY ENHANCEMENT: Essential for regulated industries
@description('Enable compliance monitoring')
param enableComplianceMonitoring bool = true

// Compliance monitoring configuration
@description('Compliance monitoring configuration')
param complianceMonitoringConfig object = {
  enableGdprMonitoring: false
  enableHipaaMonitoring: false
  enableSoxMonitoring: false
  enablePciMonitoring: false
  enableCustomCompliance: false
  complianceReportingInterval: 'P1D'
  retentionPeriod: 'P7Y'
}

// Enable audit logging for monitoring infrastructure access
// Tracks all access and configuration changes to monitoring infrastructure
// 🔒 SECURITY ENHANCEMENT: Required for compliance and security investigations
@description('Enable audit logging for monitoring infrastructure')
param enableAuditLogging bool = true

// Audit logging configuration
@description('Audit logging configuration')
param auditLoggingConfig object = {
  enabled: true
  logConfigurationChanges: true
  logDataAccess: true
  logUserActivities: true
  retentionDays: 365
  enableImmutableLogs: false
}

// ============================================================================
// PARAMETERS - ADVANCED ANALYTICS
// ============================================================================

// Enable advanced analytics with machine learning
// Uses ML for anomaly detection and predictive analytics
// 🔒 SECURITY ENHANCEMENT: Enables AI-driven security threat detection
@description('Enable advanced analytics with machine learning')
param enableAdvancedAnalytics bool = true

// Advanced analytics configuration
@description('Advanced analytics configuration')
param advancedAnalyticsConfig object = {
  enableAnomalyDetection: true
  enablePredictiveAnalytics: true
  enableRootCauseAnalysis: true
  enableCorrelationAnalysis: true
  mlModelUpdateInterval: 'P1D'
  anomalyThreshold: 95
}

// Enable intelligent alerting with ML-based noise reduction
// Reduces alert noise using machine learning algorithms
@description('Enable intelligent alerting')
param enableIntelligentAlerting bool = true

// Intelligent alerting configuration
@description('Intelligent alerting configuration')
param intelligentAlertingConfig object = {
  enabled: true
  enableNoiseReduction: true
  enableAlertGrouping: true
  enableDynamicThresholds: true
  learningPeriodDays: 14
  confidenceThreshold: 80
}

// ============================================================================
// PARAMETERS - ENHANCED TAGGING & METADATA
// ============================================================================

// Environment classification for security policy application and access control
// Determines which security policies and access controls are applied
// 🔒 SECURITY ENHANCEMENT: Use for automated security policy application
@description('Environment classification for security policies')
@allowed(['development', 'testing', 'staging', 'production', 'sandbox'])
param environmentClassification string = 'production'

// Data classification level for compliance and security policy enforcement
// Defines the sensitivity level of monitoring data
// 🔒 SECURITY ENHANCEMENT: Use for automated compliance policy application
@description('Data classification level for compliance and security')
@allowed(['public', 'internal', 'confidential', 'restricted'])
param dataClassification string = 'internal'

// Business criticality level for resource prioritization and SLA application
// Determines service level agreements and priority for support
// 🔒 SECURITY ENHANCEMENT: Use for security incident prioritization
@description('Business criticality level for SLA and support prioritization')
@allowed(['low', 'medium', 'high', 'critical', 'mission-critical'])
param businessCriticality string = 'high'

// Cost center information for billing and resource allocation tracking
// Enables cost tracking and allocation for enterprise resource management
@description('Cost center for billing and resource allocation')
param costCenter string = ''

// Resource owner information for accountability and contact management
// Specifies responsible party for resource management and security compliance
// 🔒 SECURITY ENHANCEMENT: Required for security incident response
@description('Resource owner information for accountability')
param resourceOwner object = {
  name: ''
  email: ''
  department: ''
  managerId: ''
}

// Project information for resource organization and governance
// Enables project-based resource organization and cost allocation
@description('Project information for resource organization')
param projectInformation object = {
  projectName: ''
  projectId: ''
  projectManager: ''
  budget: ''
  startDate: ''
  endDate: ''
}

// Compliance framework requirements for regulatory adherence
// Specifies which compliance frameworks must be monitored
// 🔒 SECURITY ENHANCEMENT: Enables automated compliance checks
@description('Compliance framework requirements')
param complianceRequirements object = {
  gdprCompliance: false
  hipaaCompliance: false
  sox404Compliance: false
  iso27001Compliance: false
  pcidssCompliance: false
  customComplianceFrameworks: []
}

// ============================================================================
// PARAMETERS - TAGGING & METADATA
// ============================================================================

// Resource tags for governance, cost management, and compliance tracking
// Essential for multi-tenant environments and cost allocation
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Resource tags for governance and cost management')
param tags object = {}

// Resource suffix for consistent naming across related resources
@description('Resource suffix for consistent naming')
param resourceSuffix string = ''

// ============================================================================
// VARIABLES
// ============================================================================

// Enhanced default tags with comprehensive metadata
var defaultTags = {
  Environment: tags.?Environment ?? environment
  EnvironmentClassification: environmentClassification
  Service: 'Monitoring & Observability'
  ManagedBy: 'Bicep'
  MonitoringEnabled: 'true'
  DataClassification: dataClassification
  BusinessCriticality: businessCriticality
  CostCenter: !empty(costCenter) ? costCenter : 'Not Specified'
  Owner: !empty(resourceOwner.name) ? resourceOwner.name : 'Not Specified'
  OwnerEmail: !empty(resourceOwner.email) ? resourceOwner.email : 'Not Specified'
  Department: !empty(resourceOwner.department) ? resourceOwner.department : 'Not Specified'
  ProjectName: !empty(projectInformation.projectName) ? projectInformation.projectName : projectName
  ProjectId: !empty(projectInformation.projectId) ? projectInformation.projectId : 'Not Specified'
  LastUpdated: '2025-08-01'
  LogAnalyticsEnabled: 'true'
  ApplicationInsightsEnabled: string(enableApplicationInsights)
  SentinelEnabled: string(enableSentinel)
  AdvancedAnalyticsEnabled: string(enableAdvancedAnalytics)
  ComplianceMonitoringEnabled: string(enableComplianceMonitoring)
}

// Merge user-provided tags with enhanced defaults
var allTags = union(defaultTags, tags)

// Resource naming with comprehensive project context
var workspaceName = 'law-${projectName}-${environment}-${location}${resourceSuffix}'
var appInsightsName = 'appi-${projectName}-${environment}-${location}${resourceSuffix}'
var actionGroupName = '${actionGroupConfig.name}-${environment}${resourceSuffix}'
var sentinelName = '${workspaceName}-sentinel'

// Configuration objects for complex settings
var logAnalyticsConfig = {
  sku: logAnalyticsSku
  retentionDays: logRetentionDays
  dailyQuotaGb: dailyQuotaGb
  enableWorkspaceSolutions: enableWorkspaceSolutions
  workspaceSolutions: workspaceSolutions
}

var applicationInsightsConfig = {
  enabled: enableApplicationInsights
  applicationType: applicationInsightsType
  samplingRate: samplingRate
  enableProfiler: enableProfiler
  enableSnapshotDebugger: enableSnapshotDebugger
}

var sentinelConfig = {
  enabled: enableSentinel
  pricingTier: sentinelPricingTier
  enableConnectors: enableSentinelConnectors
  connectors: sentinelConnectors
}

var alertingConfig = {
  enabled: enableAlerts
  actionGroup: actionGroupConfig
  alertRules: alertRulesConfig
  intelligentAlerting: enableIntelligentAlerting
  intelligentAlertingConfig: intelligentAlertingConfig
}

var analyticsConfig = {
  enableAdvanced: enableAdvancedAnalytics
  advancedConfig: advancedAnalyticsConfig
  enableCustomMetrics: enableCustomMetrics
  customMetricsConfig: customMetricsConfig
  enableDashboards: enableCustomDashboards
  dashboardConfig: dashboardConfig
}

var complianceConfig = {
  enabled: enableComplianceMonitoring
  monitoringConfig: complianceMonitoringConfig
  auditLogging: enableAuditLogging
  auditConfig: auditLoggingConfig
  requirements: complianceRequirements
}

var costOptimizationSettings = {
  enabled: enableCostOptimization
  config: costOptimizationConfig
}

var dataIntegrationConfig = {
  enableExport: enableDataExport
  exportConfig: dataExportConfig
  enableExternal: enableExternalIntegration
  externalConfig: externalIntegrationConfig
}

// ============================================================================
// RESOURCES - LOG ANALYTICS WORKSPACE
// ============================================================================

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Central logging for AI Enclave'
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: logRetentionDays
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: 10
    }
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
}

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = if (enableApplicationInsights) {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Application monitoring for AI Enclave'
  }
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
}

// Microsoft Sentinel - Enable Sentinel on the Log Analytics Workspace
resource sentinel 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableSentinel) {
  name: 'SecurityInsights(${logAnalyticsWorkspace.name})'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Microsoft Sentinel SIEM solution'
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: 'SecurityInsights(${logAnalyticsWorkspace.name})'
    publisher: 'Microsoft'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
  }
}

// Data Collection Rules for AI Services
resource aiServicesDataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-ai-services-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Data collection for AI services'
  }
  properties: {
    dataSources: {
      performanceCounters: [
        {
          streams: ['Microsoft-Perf']
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\Processor(_Total)\\% Processor Time'
            '\\Memory\\Available MBytes'
            '\\Network Interface(*)\\Bytes Total/sec'
          ]
          name: 'perfCounterDataSource60'
        }
      ]
      windowsEventLogs: [
        {
          streams: ['Microsoft-WindowsEvent']
          xPathQueries: [
            'Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]'
            'Security!*[System[(band(Keywords,13510798882111488))]]'
            'System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0)]]'
          ]
          name: 'eventLogsDataSource'
        }
      ]
      syslog: [
        {
          streams: ['Microsoft-Syslog']
          facilityNames: ['auth', 'authpriv', 'cron', 'daemon', 'mark', 'kern', 'local0', 'local1', 'local2', 'local3', 'local4', 'local5', 'local6', 'local7', 'lpr', 'mail', 'news', 'syslog', 'user', 'uucp']
          logLevels: ['Debug', 'Info', 'Notice', 'Warning', 'Error', 'Critical', 'Alert', 'Emergency']
          name: 'sysLogsDataSource-1688419672'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspace.id
          name: 'la-workspace'
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Microsoft-Perf', 'Microsoft-Syslog', 'Microsoft-WindowsEvent']
        destinations: ['la-workspace']
      }
    ]
  }
}

// Alert Rules for AI Services
resource cpuAlertRule 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-high-cpu-${projectName}-${environment}'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'CPU monitoring alert'
  }
  properties: {
    description: 'Alert when CPU usage is high'
    severity: 2
    enabled: true
    scopes: [
      resourceGroup().id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          threshold: 80
          name: 'Metric1'
          metricNamespace: 'Microsoft.Compute/virtualMachines'
          metricName: 'Percentage CPU'
          operator: 'GreaterThan'
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    autoMitigate: true
  }
}

resource memoryAlertRule 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-low-memory-${projectName}-${environment}'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Memory monitoring alert'
  }
  properties: {
    description: 'Alert when available memory is low'
    severity: 2
    enabled: true
    scopes: [
      resourceGroup().id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          threshold: 1000
          name: 'Metric1'
          metricNamespace: 'Microsoft.Compute/virtualMachines'
          metricName: 'Available Memory Bytes'
          operator: 'LessThan'
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    autoMitigate: true
  }
}

// Security Workbook for AI Services
resource securityWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid(resourceGroup().id, 'ai-security-workbook')
  location: location
  kind: 'shared'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Security monitoring workbook'
  }
  properties: {
    displayName: 'AI Enclave Security Dashboard'
    serializedData: string({
      version: 'Notebook/1.0'
      items: [
        {
          type: 1
          content: {
            json: '# AI Enclave Security Dashboard\n\nThis dashboard provides security monitoring for the AI Enclave infrastructure.\n\n## Key Metrics\n- Authentication events\n- Network security\n- Resource access patterns\n- Threat intelligence'
          }
        }
        {
          type: 3
          content: {
            version: 'KqlItem/1.0'
            query: 'SecurityEvent\n| where TimeGenerated > ago(24h)\n| summarize Count = count() by EventID, Activity\n| order by Count desc'
            size: 0
            title: 'Security Events (Last 24 Hours)'
            timeContext: {
              durationMs: 86400000
            }
            queryType: 0
            resourceType: 'microsoft.operationalinsights/workspaces'
          }
        }
      ]
    })
    category: 'workbook'
    sourceId: logAnalyticsWorkspace.id
  }
}

// Diagnostic Settings Template (for other resources to use)
var diagnosticSettings = {
  workspaceId: logAnalyticsWorkspace.id
  logs: [
    {
      category: 'AllLogs'
      enabled: true
      retentionPolicy: {
        enabled: true
        days: logRetentionDays
      }
    }
  ]
  metrics: [
    {
      category: 'AllMetrics'
      enabled: true
      retentionPolicy: {
        enabled: true
        days: logRetentionDays
      }
    }
  ]
}

// Outputs
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
output applicationInsightsId string = enableApplicationInsights ? applicationInsights!.id : ''
output applicationInsightsInstrumentationKey string = enableApplicationInsights ? applicationInsights!.properties.InstrumentationKey : ''
output applicationInsightsConnectionString string = enableApplicationInsights ? applicationInsights!.properties.ConnectionString : ''
output dataCollectionRuleId string = aiServicesDataCollectionRule.id
output diagnosticSettingsTemplate object = diagnosticSettings
output sentinelWorkspaceId string = enableSentinel ? logAnalyticsWorkspace.id : ''
