# Monitoring Module

Enterprise observability platform with Log Analytics, Application Insights, Microsoft Sentinel, and Azure Workbooks for comprehensive AI workload monitoring.

## Features

- **📈 Log Analytics**: Centralized logging with configurable retention
- **📱 Application Insights**: Application performance monitoring and analytics
- **🛡️ Microsoft Sentinel**: Security information and event management (SIEM)
- **📊 Azure Workbooks**: Custom dashboards and reporting
- **🚨 Alert Rules**: Proactive monitoring with automated responses
- **📊 Data Collection Rules**: Structured data collection for AI services
- **🔍 Query Analytics**: Advanced log analytics and KQL queries

## Usage

```bicep
module monitoring 'modules/monitoring/main.bicep' = {
  name: 'enterprise-monitoring'
  params: {
    location: 'eastus'
    environment: 'prod'
    projectName: 'ai-platform'
    
    // Feature configuration
    enableSentinel: true
    enableApplicationInsights: true
    
    // Retention configuration
    logRetentionDays: 90
    
    tags: {
      Environment: 'Production'
      Application: 'AI Platform'
      Purpose: 'Monitoring & Observability'
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
| `enableSentinel` | bool | `true` | Enable Microsoft Sentinel SIEM |
| `enableApplicationInsights` | bool | `true` | Enable Application Insights |
| `logRetentionDays` | int | `30` | Log retention period in days |

## Security Features

- **🔒 Private Access**: Disabled public network access for ingestion and queries
- **🔐 Identity-Based Access**: Azure AD authentication required
- **📝 Audit Logging**: Complete monitoring access audit trail
- **🛡️ Data Encryption**: Encryption at rest and in transit
- **📊 Access Control**: RBAC-based access to monitoring data
- **🚨 Security Analytics**: Advanced threat detection with Sentinel

## Monitoring Components

### Log Analytics Workspace
- **📊 Centralized Logging**: Single source for all log data
- **💰 Cost Management**: Daily quota and usage controls
- **🔍 Advanced Queries**: KQL query capabilities
- **📈 Performance**: Optimized for large-scale log ingestion
- **🔄 Integration**: Native integration with Azure services

### Application Insights
- **📱 APM**: Application performance monitoring
- **🔍 Distributed Tracing**: End-to-end request tracing
- **📊 Custom Metrics**: Application-specific monitoring
- **🚨 Smart Detection**: Anomaly detection and alerting
- **📈 Usage Analytics**: User behavior and application usage

### Microsoft Sentinel
- **🛡️ SIEM**: Security information and event management
- **🤖 AI-Powered**: Machine learning-based threat detection
- **📊 Security Analytics**: Advanced security analytics and investigation
- **🚨 Incident Management**: Automated incident response workflows
- **🔗 Threat Intelligence**: Integration with external threat feeds

## Data Collection

### AI Services Monitoring
- **🤖 Model Performance**: AI model metrics and performance
- **📊 Usage Analytics**: API call volumes and patterns
- **🔍 Error Tracking**: Detailed error analysis and trending
- **💰 Cost Tracking**: Resource usage and cost attribution

### Infrastructure Monitoring
- **🖥️ System Performance**: CPU, memory, disk, and network metrics
- **📦 Container Insights**: Kubernetes and container monitoring
- **🌐 Network Analytics**: Traffic flow and performance analysis
- **💾 Storage Metrics**: Storage performance and capacity monitoring

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `logAnalyticsWorkspaceId` | string | Resource ID of Log Analytics workspace |
| `logAnalyticsWorkspaceName` | string | Name of Log Analytics workspace |
| `applicationInsightsId` | string | Resource ID of Application Insights |
| `applicationInsightsInstrumentationKey` | string | Application Insights instrumentation key |
| `sentinelWorkspaceId` | string | Sentinel workspace resource ID |

## Dashboards and Workbooks

### Pre-built Dashboards
- **🤖 AI Services Overview**: Comprehensive AI service monitoring
- **🔒 Security Dashboard**: Security events and threat analysis
- **📊 Performance Dashboard**: Infrastructure performance metrics
- **💰 Cost Analytics**: Resource usage and cost optimization

### Custom Workbooks
- **📈 AI Model Performance**: Model-specific performance tracking
- **🔍 Troubleshooting**: Diagnostic and troubleshooting workflows
- **📊 Executive Summary**: High-level KPIs and status indicators
- **🚨 Security Incidents**: Security investigation and response

## Alerting

### Performance Alerts
- **⚡ High Latency**: API response time alerts
- **🔥 High Error Rate**: Application error rate monitoring
- **💾 Resource Utilization**: CPU, memory, and storage alerts
- **📊 Anomaly Detection**: ML-based anomaly alerting

### Security Alerts
- **🚨 Suspicious Activity**: Unusual access patterns
- **🔒 Failed Authentication**: Authentication failure alerts
- **📊 Data Exfiltration**: Large data transfer alerts
- **🛡️ Policy Violations**: Security policy violation notifications

## Cost Optimization

- **📊 Usage Analytics**: Monitor data ingestion costs
- **🔄 Data Lifecycle**: Automated log archival and cleanup
- **📈 Capacity Planning**: Right-sizing recommendations
- **💰 Budget Alerts**: Cost threshold notifications

## Integration Capabilities

- **🔗 Azure Services**: Native integration with all Azure services
- **📊 Third-party Tools**: Grafana, Prometheus, and Splunk integration
- **🤖 Automation**: Logic Apps and Azure Functions integration
- **📱 Mobile**: Azure mobile app notifications

## Compliance

This module supports the following compliance standards:
- **SOC 2 Type II**: Audit logging and monitoring controls
- **ISO 27001**: Information security monitoring requirements
- **GDPR**: Data processing and retention compliance
- **HIPAA**: Healthcare monitoring and audit requirements
