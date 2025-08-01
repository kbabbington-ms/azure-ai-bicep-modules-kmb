# Azure AI Document Intelligence Module

## Overview

This Bicep module creates a comprehensive Azure AI Document Intelligence service with advanced document processing capabilities, enterprise security features, and production-ready monitoring. The module supports prebuilt models, custom model training, batch processing, and secure document handling with compliance-ready configurations.

## Features

### 🔒 Security Features
- **Private Endpoints**: Secure network access within your virtual network
- **Customer-Managed Encryption**: Enhanced data protection with your own encryption keys
- **Managed Identity**: Secure authentication without storing credentials
- **Network Access Controls**: IP-based restrictions and firewall rules
- **Audit Logging**: Comprehensive logging for compliance and security monitoring
- **Zero-Trust Architecture**: Security-first design with minimal exposure

### 📋 Document Processing Capabilities
- **Prebuilt Models**: Out-of-the-box support for invoices, receipts, business cards, ID documents, W-2 forms, contracts
- **Custom Models**: Train models for organization-specific document types
- **Composed Models**: Combine multiple models for complex document workflows
- **Batch Processing**: Efficient processing of large document volumes
- **Layout Analysis**: Extract text, tables, and structure from documents
- **Multi-Language Support**: Process documents in various languages

### 📊 Monitoring & Analytics
- **Application Insights Integration**: Performance monitoring and usage analytics
- **Automated Alerts**: Proactive monitoring for failures and performance issues
- **Log Analytics Integration**: Centralized logging and analysis
- **Custom Metrics**: Track document processing metrics and trends
- **Health Monitoring**: Service availability and performance tracking

### 💾 Storage & Data Management
- **Dedicated Storage Account**: Secure storage for training data and processed documents
- **Container Organization**: Structured storage for different document types and processing stages
- **Data Retention Policies**: Configurable retention for compliance requirements
- **Encryption at Rest**: Secure storage with customer-managed or service-managed keys
- **Access Controls**: Fine-grained permissions for document access

## Prerequisites

### Required Resources
- **Azure Subscription**: With sufficient permissions to create resources
- **Resource Group**: Target resource group for deployment
- **Regional Availability**: Document Intelligence is available in specific regions

### Optional Dependencies
- **Virtual Network & Subnet**: Required for private endpoint deployment
- **Key Vault**: Required for customer-managed encryption
- **Log Analytics Workspace**: For centralized logging and monitoring
- **Application Insights**: For enhanced monitoring (auto-created if not provided)

## Quick Start

### Basic Deployment
```bash
# Deploy with minimal configuration
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters documentIntelligenceName=mydocintel location=eastus
```

### Production Deployment
```bash
# Deploy with full production features
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters @main.parameters.json
```

### PowerShell Deployment
```powershell
# Deploy using PowerShell
New-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "main.bicep" `
  -TemplateParameterFile "main.parameters.json"
```

## Configuration Examples

### Development Environment
```json
{
  "documentIntelligenceName": { "value": "docintel-dev" },
  "location": { "value": "eastus" },
  "documentIntelligenceSku": { "value": "F0" },
  "enablePrivateEndpoint": { "value": false },
  "enableCustomerManagedKey": { "value": false },
  "enableDedicatedStorage": { "value": true },
  "maxCustomModels": { "value": 5 }
}
```

### Production Environment
```json
{
  "documentIntelligenceName": { "value": "docintel-prod" },
  "location": { "value": "eastus" },
  "documentIntelligenceSku": { "value": "S0" },
  "enablePrivateEndpoint": { "value": true },
  "subnetId": { "value": "/subscriptions/.../subnets/documents" },
  "enableCustomerManagedKey": { "value": true },
  "keyVaultId": { "value": "/subscriptions/.../vaults/mykeyvault" },
  "enableAuditLogging": { "value": true },
  "dataRetentionDays": { "value": 2555 },
  "maxCustomModels": { "value": 50 }
}
```

### High-Security Environment
```json
{
  "documentIntelligenceName": { "value": "docintel-secure" },
  "location": { "value": "eastus" },
  "enablePrivateEndpoint": { "value": true },
  "enableCustomerManagedKey": { "value": true },
  "enableApiKeyAuth": { "value": false },
  "enableManagedIdentity": { "value": true },
  "allowedIpAddresses": { "value": ["10.0.0.0/24", "192.168.1.0/24"] },
  "enableStorageEncryption": { "value": true },
  "enableAuditLogging": { "value": true }
}
```

## Parameters Reference

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `documentIntelligenceName` | string | Base name for Document Intelligence resources (2-24 characters) |
| `location` | string | Azure region for deployment (limited regional availability) |

### Core Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `documentIntelligenceSku` | string | `S0` | Service tier (`F0` for free, `S0` for standard) |
| `enablePrebuiltModels` | bool | `true` | Enable prebuilt models for common document types |
| `enableCustomModels` | bool | `true` | Enable custom model training capabilities |
| `maxCustomModels` | int | `10` | Maximum number of custom models (1-100) |
| `enableComposedModels` | bool | `true` | Enable composed models for complex workflows |

### Security Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enablePrivateEndpoint` | bool | `false` | Enable private endpoints for secure access |
| `subnetId` | string | `''` | Subnet resource ID for private endpoint |
| `enableCustomerManagedKey` | bool | `false` | Enable customer-managed encryption keys |
| `keyVaultId` | string | `''` | Key Vault resource ID for encryption |
| `enableManagedIdentity` | bool | `true` | Enable managed identity authentication |
| `allowedIpAddresses` | array | `[]` | Allowed IP addresses or CIDR ranges |
| `enableAuditLogging` | bool | `true` | Enable audit logging for compliance |
| `dataRetentionDays` | int | `365` | Data retention period (30-2555 days) |

### Storage Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableDedicatedStorage` | bool | `true` | Enable dedicated storage account |
| `storageAccountSku` | string | `Standard_LRS` | Storage account SKU |
| `enableStorageEncryption` | bool | `false` | Enable storage encryption with CMK |
| `storageContainers` | array | See template | Storage containers for document workflow |

### Monitoring Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableApplicationInsights` | bool | `true` | Enable Application Insights monitoring |
| `applicationInsightsId` | string | `''` | Existing Application Insights resource ID |
| `logAnalyticsWorkspaceId` | string | `''` | Log Analytics workspace resource ID |
| `enableAlerts` | bool | `true` | Enable monitoring alerts |

## Outputs

### Service Configuration
```json
{
  "documentIntelligenceConfig": {
    "name": "Service name",
    "id": "Resource ID",
    "endpoint": "Service endpoint URL",
    "customDomain": "Custom domain name",
    "sku": "Service tier",
    "location": "Deployment region"
  }
}
```

### API Access
```json
{
  "apiConfig": {
    "endpoint": "API endpoint URL",
    "apiKeyAuthEnabled": "boolean",
    "managedIdentityEnabled": "boolean",
    "privateEndpointEnabled": "boolean",
    "corsEnabled": "boolean"
  }
}
```

### Monitoring Configuration
```json
{
  "monitoringConfig": {
    "applicationInsights": {
      "name": "Application Insights name",
      "instrumentationKey": "Instrumentation key",
      "connectionString": "Connection string"
    },
    "alertsEnabled": "boolean",
    "auditLoggingEnabled": "boolean"
  }
}
```

## Document Processing Models

### Prebuilt Models
- **Invoice**: Extract key information from invoices
- **Receipt**: Process retail receipts and expense reports
- **Business Card**: Extract contact information from business cards
- **Identity Document**: Process IDs, passports, and driver's licenses
- **W-2**: Extract information from W-2 tax forms
- **Contract**: Analyze contracts and legal documents
- **Layout**: Extract text, tables, and document structure
- **General Document**: Process any document type

### Custom Models
- Train models for organization-specific document types
- Supervised learning with labeled training data
- Support for forms, documents, and structured data
- Model versioning and management capabilities

### Composed Models
- Combine multiple models for complex workflows
- Sequential processing of different document types
- Enhanced accuracy through model collaboration
- Advanced document classification

## Security Best Practices

### Network Security
```json
{
  "enablePrivateEndpoint": true,
  "subnetId": "/subscriptions/.../subnets/documents",
  "allowedIpAddresses": ["10.0.0.0/16"],
  "enableCors": false
}
```

### Data Protection
```json
{
  "enableCustomerManagedKey": true,
  "keyVaultId": "/subscriptions/.../vaults/mykeyvault",
  "enableStorageEncryption": true,
  "enableAuditLogging": true,
  "dataRetentionDays": 2555
}
```

### Access Control
```json
{
  "enableApiKeyAuth": false,
  "enableManagedIdentity": true,
  "allowedIpAddresses": ["192.168.1.0/24"]
}
```

## Monitoring and Alerting

### Key Metrics
- **Processing Volume**: Number of documents processed
- **Processing Latency**: Time to process documents
- **Error Rate**: Failed processing attempts
- **API Usage**: Request patterns and throttling
- **Storage Usage**: Storage consumption trends

### Alert Configuration
- **Processing Failures**: Alert on high error rates
- **High Latency**: Alert on performance degradation
- **Capacity Limits**: Alert on approaching quotas
- **Security Events**: Alert on unauthorized access attempts

### Log Analysis
```kusto
// Query processing errors
DocumentIntelligenceLogs
| where Level == "Error"
| summarize count() by bin(TimeGenerated, 1h)
| render timechart

// Analyze processing performance
DocumentIntelligenceLogs
| where OperationName == "DocumentAnalysis"
| summarize avg(Duration) by bin(TimeGenerated, 15m)
| render timechart
```

## Integration Examples

### REST API Integration
```python
import requests
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

# Get API key from Key Vault
credential = DefaultAzureCredential()
secret_client = SecretClient(vault_url="https://mykeyvault.vault.azure.net/", credential=credential)
api_key = secret_client.get_secret("document-intelligence-key").value

# Process document
headers = {
    'Ocp-Apim-Subscription-Key': api_key,
    'Content-Type': 'application/json'
}

data = {
    'source': 'https://mystorageaccount.blob.core.windows.net/documents/invoice.pdf'
}

response = requests.post(
    'https://mydocintel.cognitiveservices.azure.com/formrecognizer/documentModels/prebuilt-invoice:analyze',
    headers=headers,
    json=data
)
```

### Azure SDK Integration
```python
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.identity import DefaultAzureCredential

# Initialize client with managed identity
credential = DefaultAzureCredential()
client = DocumentAnalysisClient(
    endpoint="https://mydocintel.cognitiveservices.azure.com/",
    credential=credential
)

# Analyze document
with open("invoice.pdf", "rb") as f:
    poller = client.begin_analyze_document("prebuilt-invoice", document=f)
    result = poller.result()

# Extract invoice data
for document in result.documents:
    print(f"Invoice ID: {document.fields.get('InvoiceId', {}).value}")
    print(f"Total: {document.fields.get('InvoiceTotal', {}).value}")
```

## Troubleshooting

### Common Issues

#### Deployment Failures
- **Issue**: Private endpoint deployment fails
- **Solution**: Ensure subnet has private endpoint policies disabled
- **Check**: Verify subnet ID format and permissions

#### Authentication Issues
- **Issue**: Managed identity authentication fails
- **Solution**: Verify RBAC assignments and identity configuration
- **Check**: Ensure service principal has required permissions

#### Processing Errors
- **Issue**: Document processing fails with 4xx errors
- **Solution**: Check document format, size limits, and API quotas
- **Check**: Verify endpoint URL and authentication

### Diagnostic Commands

```bash
# Check service status
az cognitiveservices account show --name mydocintel --resource-group myRG

# List available models
az cognitiveservices account list-models --name mydocintel --resource-group myRG

# Check private endpoint status
az network private-endpoint show --name mydocintel-pe --resource-group myRG

# View audit logs
az monitor log-analytics query --workspace myWorkspace --analytics-query "
DocumentIntelligenceLogs
| where TimeGenerated > ago(1h)
| order by TimeGenerated desc
"
```

## Cost Optimization

### Right-Sizing Recommendations
- **Development**: Use F0 tier for testing and development
- **Production**: Use S0 tier for production workloads with SLA
- **Storage**: Use Standard_LRS for most workloads, Premium for high-performance needs
- **Monitoring**: Disable detailed monitoring in development environments

### Cost Monitoring
```kusto
// Monitor processing costs
Usage
| where ResourceUri contains "formrecognizer"
| summarize TotalCost = sum(PretaxCost) by bin(Date, 1d)
| render timechart
```

## Compliance and Governance

### Regulatory Compliance
- **SOC 2**: Comprehensive audit logging and access controls
- **HIPAA**: Private endpoints and customer-managed encryption
- **GDPR**: Data retention policies and audit capabilities
- **ISO 27001**: Security controls and monitoring

### Data Governance
- **Data Classification**: Tag resources with data sensitivity levels
- **Retention Policies**: Configure appropriate data retention periods
- **Access Controls**: Implement principle of least privilege
- **Audit Trails**: Maintain comprehensive audit logs

## Support and Documentation

### Azure Documentation
- [Document Intelligence Overview](https://docs.microsoft.com/azure/applied-ai-services/form-recognizer/)
- [Custom Models](https://docs.microsoft.com/azure/applied-ai-services/form-recognizer/concept-custom)
- [API Reference](https://docs.microsoft.com/rest/api/formrecognizer/)
- [Pricing Information](https://azure.microsoft.com/pricing/details/form-recognizer/)

### Sample Applications
- [Document Processing Pipeline](https://github.com/Azure-Samples/cognitive-services-quickstart-code)
- [Custom Model Training](https://github.com/Azure-Samples/cognitive-services-REST-api-samples)
- [Batch Processing Examples](https://github.com/Azure-Samples/azure-ai-formrecognizer-samples)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-08-01 | Initial release with comprehensive Document Intelligence capabilities |

## Contributing

This module is part of the Azure AI Bicep Modules project. For contributions, bug reports, or feature requests, please follow the project's contribution guidelines.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
