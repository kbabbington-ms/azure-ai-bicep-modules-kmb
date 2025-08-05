# Resource Module Development Standard

## 📋 Overview

This document defines the simplified standard for developing new Azure resource modules based on the patterns established in our enterprise-grade modules (Key Vault, Storage, Cognitive Services).

## 🎯 Core Requirements

### 1. **File Structure** (Required)
```
modules/<service-name>/
├── main.bicep                    # Primary module file
├── main.parameters.json          # Parameter defaults
└── README.md                     # Module documentation
```

### 2. **Bicep Template Structure** (Required)

```bicep
targetScope = 'resourceGroup'

// === STANDARD PARAMETER STRUCTURE ===

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment name for resource naming and tagging')
param environment string = 'dev'

@description('Project name for resource naming and tagging')
param projectName string = 'ai-enclave'

// === SERVICE-SPECIFIC PARAMETERS ===
@description('Service name (leave empty for auto-generation)')
param serviceName string = ''

// === SECURITY PARAMETERS (Choose applicable) ===
@description('Enable private endpoint')
param enablePrivateEndpoint bool = true

@description('Private endpoint subnet ID')
param privateEndpointSubnetId string = ''

@description('Enable customer-managed encryption')
param enableCustomerManagedEncryption bool = true

@description('Key Vault URI for encryption key')
param keyVaultUri string = ''

@description('Enable diagnostic settings')
param enableDiagnostics bool = true

@description('Log Analytics workspace ID')
param logAnalyticsWorkspaceId string = ''

@description('Tags to apply to all resources')
param tags object = {}

// === VARIABLES ===
var serviceNameGenerated = !empty(serviceName) ? serviceName : 'prefix-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'

// === MAIN RESOURCE ===
resource mainResource 'Microsoft.ServiceType/resourceType@2023-XX-XX' = {
  name: serviceNameGenerated
  location: location
  tags: union(tags, {
    Environment: environment
    Project: projectName
    Purpose: 'Service description'
  })
  // Add resource-specific properties
}

// === PRIVATE ENDPOINT (if applicable) ===
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (enablePrivateEndpoint && !empty(privateEndpointSubnetId)) {
  // Standard private endpoint configuration
}

// === DIAGNOSTIC SETTINGS (if applicable) ===
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && !empty(logAnalyticsWorkspaceId)) {
  // Standard diagnostic configuration
}

// === OUTPUTS ===
@description('Resource ID')
output resourceId string = mainResource.id

@description('Resource name')
output resourceName string = mainResource.name
```

## 🔒 Security Standards

### Must-Have Security Features
1. **Private Endpoints**: Default to `true` for enterprise services
2. **Customer-Managed Encryption**: Support Key Vault integration
3. **Network Isolation**: Disable public access by default
4. **Managed Identity**: Prefer over access keys
5. **Diagnostic Settings**: Enable comprehensive logging

### Security Parameter Pattern
```bicep
// Use this exact pattern for consistency
@description('Enable private endpoint')
param enablePrivateEndpoint bool = true

@description('Enable customer-managed encryption')
param enableCustomerManagedEncryption bool = true

@description('Enable diagnostic settings')
param enableDiagnostics bool = true
```

## 📊 Parameter Categories

### **Core Parameters** (Required in all modules)
- `location` - Resource location
- `environment` - Environment identifier
- `projectName` - Project identifier
- `serviceName` - Service name (with auto-generation)
- `tags` - Resource tags

### **Security Parameters** (Required for enterprise services)
- `enablePrivateEndpoint` - Private connectivity
- `privateEndpointSubnetId` - Network configuration
- `enableCustomerManagedEncryption` - Encryption control
- `keyVaultUri` - Key management
- `enableDiagnostics` - Monitoring

### **Service-Specific Parameters** (As needed)
- Service configuration
- SKU settings
- Feature toggles
- Integration settings

## 🏷️ Naming Conventions

### Resource Naming Pattern
```bicep
var serviceNameGenerated = !empty(serviceName) ? serviceName : '${prefix}-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
```

### Prefixes by Service Type
- `kv-` - Key Vault
- `st-` - Storage Account
- `cog-` - Cognitive Services
- `ml-` - Machine Learning
- `search-` - Cognitive Search
- `ai-` - AI Foundry
- `oai-` - Azure OpenAI

## 📝 Documentation Requirements

### README.md Structure
```markdown
# [Service Name] Module

Brief description of the service and module purpose.

## Features
- Key feature 1
- Key feature 2
- Security feature 3

## Usage
Basic usage example with Bicep code.

## Parameters
Table of key parameters with descriptions.

## Security Features
List of security capabilities and configurations.

## Outputs
Table of module outputs.
```

### Parameter Documentation
- Every parameter must have `@description`
- Security implications must be noted
- Default values must be secure

## 🧪 Quality Standards

### Required Validation
1. **Bicep Lint**: No errors or warnings
2. **Security Review**: All security features enabled by default
3. **Parameter Validation**: Appropriate constraints and defaults
4. **Output Coverage**: Essential outputs defined

### Testing Requirements
1. **Basic Deployment**: Default parameters work
2. **Security Configuration**: Security features function correctly
3. **Integration**: Works with other modules
4. **Error Handling**: Graceful failure scenarios

## 📋 Checklist for New Modules

### Development Phase
- [ ] Module follows file structure standard
- [ ] All core parameters included
- [ ] Security parameters appropriate for service
- [ ] Naming conventions followed
- [ ] Private endpoint support (if applicable)
- [ ] Customer-managed encryption (if applicable)
- [ ] Diagnostic settings included

### Documentation Phase
- [ ] README.md created with standard structure
- [ ] All parameters documented
- [ ] Usage examples provided
- [ ] Security features highlighted

### Validation Phase
- [ ] Bicep lint passes without errors
- [ ] Security review completed
- [ ] Parameters file created with secure defaults
- [ ] Basic deployment tested

## 🎯 Simplified Development Process

### 1. **Start with Template**
Copy an existing similar module (Key Vault for security-focused, Storage for data services, Cognitive Services for AI services).

### 2. **Customize Core Elements**
- Update service type and API version
- Modify service-specific parameters
- Adjust security features for service

### 3. **Add Security Features**
- Private endpoint (if supported)
- Customer-managed encryption (if supported)
- Network ACLs and access controls
- Diagnostic settings

### 4. **Document and Test**
- Create README with usage examples
- Add parameter descriptions
- Test basic deployment scenarios

## 🚀 Quick Start Template

```bicep
targetScope = 'resourceGroup'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment name')
param environment string = 'dev'

@description('Project name')
param projectName string = 'ai-enclave'

@description('[Service] name (leave empty for auto-generation)')
param serviceName string = ''

@description('Enable private endpoint')
param enablePrivateEndpoint bool = true

@description('Private endpoint subnet ID')
param privateEndpointSubnetId string = ''

@description('Enable diagnostic settings')
param enableDiagnostics bool = true

@description('Log Analytics workspace ID')
param logAnalyticsWorkspaceId string = ''

@description('Tags to apply to all resources')
param tags object = {}

var serviceNameGenerated = !empty(serviceName) ? serviceName : 'prefix-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'

resource mainService 'Microsoft.ServiceProvider/serviceType@2023-XX-XX' = {
  name: serviceNameGenerated
  location: location
  tags: union(tags, {
    Environment: environment
    Project: projectName
    Purpose: 'Service purpose description'
  })
  properties: {
    // Add service-specific properties
  }
}

@description('Service resource ID')
output serviceId string = mainService.id

@description('Service name')
output serviceName string = mainService.name
```

## 💡 Key Insights from Recent Modules

### From Key Vault Module
- **Premium SKU** for enterprise security (HSM-backed keys)
- **RBAC over Access Policies** for better governance
- **Comprehensive role assignments** for different user types

### From Storage Module
- **Multiple service endpoints** (blob, file, queue, table)
- **Data Lake Gen2 support** for analytics workloads
- **Lifecycle management** for cost optimization

### From Cognitive Services Module
- **Multi-service support** in single module
- **Custom Vision special handling** for training/prediction
- **Commitment plans** for cost management

## 🔄 Continuous Improvement

This standard will evolve based on:
- New Azure service capabilities
- Security best practice updates
- Developer feedback and usage patterns
- Compliance requirement changes

---

**Remember**: Security by default, enterprise-ready configurations, comprehensive documentation, and consistent patterns across all modules.
