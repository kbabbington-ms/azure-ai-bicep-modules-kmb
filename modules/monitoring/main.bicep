@description('Comprehensive monitoring and observability for AI Enclave')
param location string = resourceGroup().location
param environment string = 'dev'
param projectName string = 'ai-enclave'
param enableSentinel bool = true
param enableApplicationInsights bool = true
param logRetentionDays int = 30

// Resource naming
var workspaceName = 'law-${projectName}-${environment}-${location}'
var appInsightsName = 'appi-${projectName}-${environment}-${location}'

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
