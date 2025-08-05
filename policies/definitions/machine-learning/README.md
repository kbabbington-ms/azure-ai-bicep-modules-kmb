# Azure Machine Learning SFI-W1 Policy Documentation

## Overview

This directory contains comprehensive Azure Policy definitions and initiatives for Azure Machine Learning services, ensuring compliance with Microsoft's Secure Future Initiative (SFI-W1) and Azure Trusted Security (AzTS) standards.

## 🎯 **Policy Architecture**

### **SFI-W1 Compliance Framework**
- **Network Isolation**: Mandatory private endpoints for zero-trust architecture
- **Data Protection**: Customer-managed encryption keys and datastore security
- **Identity Management**: Managed identity requirements for secure authentication
- **Resource Governance**: VM size restrictions and compute standardization
- **Audit & Monitoring**: Comprehensive diagnostic settings and logging

### **Policy Definitions**

| Policy Name | Purpose | SFI-W1 Controls | Effect Options |
|-------------|---------|-----------------|----------------|
| **SFI-W1-Def-ML-RequirePrivateEndpoints** | Enforce private endpoint usage | Network Security, Zero-Trust | Audit, Deny |
| **SFI-W1-Def-ML-RequireCustomerManagedKeys** | Enforce customer-managed encryption | Data Protection, Encryption | Audit, Deny |
| **SFI-W1-Def-ML-RequireManagedIdentity** | Enforce managed identity usage | Identity Management, Authentication | Audit, Deny |
| **SFI-W1-Def-ML-RestrictSKUs** | Restrict to approved VM sizes | Resource Governance, Cost Control | Audit, Deny |
| **SFI-W1-Def-ML-RequireDatastoreEncryption** | Enforce datastore encryption | Data Protection, Secure Storage | Audit, Deny |
| **SFI-W1-Def-ML-RequireDiagnosticSettings** | Enable comprehensive logging | Monitoring, Audit Trail | AuditIfNotExists, DeployIfNotExists |

## 📋 **Policy Details**

### **1. SFI-W1-Def-ML-RequirePrivateEndpoints**

**Purpose**: Ensures Azure ML workspaces use private endpoints exclusively for secure communication.

**Key Features**:
- ✅ Validates private endpoint configuration
- ✅ Checks public network access is disabled
- ✅ Ensures minimum private endpoint connections
- ✅ Supports location restrictions for data residency
- ✅ Configurable exclusions for development environments

**Parameters**:
- `effect`: Policy enforcement mode (Audit/Deny/Disabled)
- `allowedLocations`: Permitted Azure regions for deployment
- `excludedResourceGroups`: Resource groups to exempt from policy
- `minPrivateEndpoints`: Minimum required private endpoint connections (1-5)

**Implementation Example**:
```json
{
  "effect": "Deny",
  "allowedLocations": ["eastus", "westus2", "westeurope"],
  "minPrivateEndpoints": 1,
  "excludedResourceGroups": ["rg-ml-dev"]
}
```

### **2. SFI-W1-Def-ML-RequireCustomerManagedKeys**

**Purpose**: Enforces customer-managed encryption keys for ML workspace data protection.

**Key Features**:
- ✅ Validates Key Vault integration for workspace encryption
- ✅ Checks managed identity configuration for key access
- ✅ Ensures encryption status is enabled
- ✅ Supports key vault location restrictions
- ✅ Validates complete encryption configuration

**Parameters**:
- `effect`: Policy enforcement mode (Audit/Deny/Disabled)
- `allowedKeyVaultLocations`: Permitted Key Vault regions
- `excludedResourceGroups`: Resource groups to exempt from policy

**Security Benefits**:
- 🔐 Enhanced data sovereignty and control
- 🔐 Protection against Microsoft key compromise
- 🔐 Advanced key lifecycle management
- 🔐 Compliance with strict regulatory requirements

### **3. SFI-W1-Def-ML-RequireManagedIdentity**

**Purpose**: Ensures ML workspaces use managed identity for secure authentication.

**Key Features**:
- ✅ Validates managed identity configuration
- ✅ Supports system-assigned and user-assigned identities
- ✅ Ensures identity type compliance
- ✅ Configurable identity type requirements
- ✅ Exception handling for testing scenarios

**Parameters**:
- `effect`: Policy enforcement mode (Audit/Deny/Disabled)
- `excludedResourceGroups`: Resource groups to exempt from policy
- `requiredIdentityType`: Required identity type (SystemAssigned/UserAssigned/Both)

**Identity Benefits**:
- 🔑 Eliminates credential management overhead
- 🔑 Provides Azure AD integrated authentication
- 🔑 Enables fine-grained access control
- 🔑 Supports zero-trust architecture principles

### **4. SFI-W1-Def-ML-RestrictSKUs**

**Purpose**: Restricts ML compute to approved VM sizes for cost control and standardization.

**Key Features**:
- ✅ Validates compute instance VM sizes
- ✅ Controls compute cluster configurations
- ✅ Limits maximum node counts per cluster
- ✅ Supports approval workflows for high-tier VMs
- ✅ Configurable exclusions for research workloads

**Parameters**:
- `effect`: Policy enforcement mode (Audit/Deny/Disabled)
- `allowedVMSizes`: Permitted VM sizes (DS-series, NC-series, etc.)
- `maxNodes`: Maximum nodes per compute cluster (default: 10)
- `excludedResourceGroups`: Resource groups to exempt from policy

**Governance Benefits**:
- 💰 Cost control and budget management
- 💰 Standardized performance tiers
- 💰 Resource allocation optimization
- 💰 Compliance with organizational standards

### **5. SFI-W1-Def-ML-RequireDatastoreEncryption**

**Purpose**: Ensures ML datastores require proper encryption configuration.

**Key Features**:
- ✅ Validates datastore encryption settings
- ✅ Checks authentication method security
- ✅ Supports multiple datastore types (Blob, File, Data Lake)
- ✅ Ensures secure credential management
- ✅ Configurable datastore type restrictions

**Parameters**:
- `effect`: Policy enforcement mode (Audit/Deny/Disabled)
- `excludedResourceGroups`: Resource groups to exempt from policy
- `allowedDatastoreTypes`: Permitted datastore types

**Data Protection**:
- 🛡️ Secures data at rest and in transit
- 🛡️ Prevents unauthorized access to training data
- 🛡️ Ensures compliance with data governance policies
- 🛡️ Supports regulatory data protection requirements

### **6. SFI-W1-Def-ML-RequireDiagnosticSettings**

**Purpose**: Enables comprehensive audit logging and monitoring for ML workspaces.

**Key Features**:
- ✅ Automatic diagnostic settings deployment
- ✅ Multiple destination support (Log Analytics, Storage, Event Hub)
- ✅ Configurable log categories and retention
- ✅ ML-specific log categories (compute events, job tracking)
- ✅ Compliance audit trail generation

**Parameters**:
- `effect`: Policy enforcement mode (AuditIfNotExists/DeployIfNotExists/Disabled)
- `logAnalyticsWorkspaceId`: Central logging workspace
- `storageAccountId`: Long-term retention storage
- `eventHubAuthorizationRuleId`: Real-time streaming endpoint
- `requiredLogCategories`: Mandatory log types
- `logRetentionDays`: Compliance retention period (30-730 days)

**Monitoring Coverage**:
- 📊 Complete compute cluster event logging
- 📊 Job execution and performance tracking
- 📊 Resource utilization monitoring
- 📊 Security events and anomaly detection

## 🚀 **Policy Initiative**

### **SFI-W1-Ini-ML: Comprehensive Azure ML Compliance**

The initiative combines all six policy definitions into a coordinated compliance framework with centralized configuration and modular enablement.

**Key Features**:
- 🎯 **Modular Control**: Enable/disable policy categories independently
- 🎯 **Global Configuration**: Centralized parameter management
- 🎯 **Flexible Enforcement**: Audit or Deny modes per policy group
- 🎯 **Exception Handling**: Configurable exclusions and overrides
- 🎯 **Compliance Reporting**: Built-in compliance status tracking

**Policy Groups**:
1. **Network Security**: Private endpoints and network isolation
2. **Data Protection**: Encryption and secure storage controls
3. **Identity Management**: Managed identity and authentication
4. **Resource Governance**: VM size restrictions and compute standards
5. **Monitoring**: Diagnostic settings and audit logging

**Initiative Parameters**:
```json
{
  "enableNetworkSecurity": true,
  "enableDataProtection": true,
  "enableIdentityManagement": true,
  "enableResourceGovernance": true,
  "enableMonitoring": true,
  "allowedLocations": ["eastus", "westus2"],
  "allowedVMSizes": ["Standard_DS2_v2", "Standard_DS3_v2", "Standard_NC6"],
  "maxNodes": 10,
  "logAnalyticsWorkspaceId": "/subscriptions/.../workspaces/...",
  "excludedResourceGroups": ["rg-ml-dev", "rg-research"]
}
```

## 📈 **Deployment Guide**

### **Prerequisites**
- Azure CLI 2.50+ or Azure PowerShell 5.1+
- Machine Learning Contributor + User Access Administrator roles
- Target subscription and resource group

### **Option 1: Individual Policy Deployment**
```bash
# Deploy specific policy
az deployment sub create \
  --name "deploy-ml-private-endpoints" \
  --location "eastus" \
  --template-file "SFI-W1-Def-ML-RequirePrivateEndpoints.bicep"
```

### **Option 2: Complete Initiative Deployment**
```bash
# Deploy complete initiative
az deployment sub create \
  --name "deploy-ml-sfi-initiative" \
  --location "eastus" \
  --template-file "SFI-W1-Ini-ML.bicep"
```

### **Option 3: PowerShell Deployment**
```powershell
# Deploy with PowerShell
New-AzSubscriptionDeployment `
  -Name "deploy-ml-sfi-initiative" `
  -Location "eastus" `
  -TemplateFile "SFI-W1-Ini-ML.bicep"
```

## 🔧 **Policy Assignment**

### **Production Assignment Example**
```bash
# Assign initiative to subscription
az policy assignment create \
  --name "ml-sfi-compliance" \
  --display-name "Azure ML SFI-W1 Compliance" \
  --policy-set-definition "/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policySetDefinitions/SFI-W1-Ini-ML" \
  --scope "/subscriptions/{subscription-id}" \
  --params '{
    "privateEndpointsEffect": {"value": "Deny"},
    "encryptionEffect": {"value": "Deny"},
    "identityEffect": {"value": "Deny"},
    "skuRestrictionEffect": {"value": "Audit"},
    "datastoreEncryptionEffect": {"value": "Audit"},
    "diagnosticsEffect": {"value": "DeployIfNotExists"}
  }'
```

### **Development/Testing Assignment**
```bash
# Assign with audit mode for development
az policy assignment create \
  --name "ml-sfi-audit" \
  --display-name "Azure ML SFI-W1 Audit Mode" \
  --policy-set-definition "/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policySetDefinitions/SFI-W1-Ini-ML" \
  --scope "/subscriptions/{subscription-id}" \
  --params '{
    "privateEndpointsEffect": {"value": "Audit"},
    "encryptionEffect": {"value": "Audit"},
    "identityEffect": {"value": "Audit"},
    "excludedResourceGroups": {"value": ["rg-ml-dev", "rg-research"]}
  }'
```

## 📊 **Compliance Monitoring**

### **Built-in Compliance Dashboard**
The policies integrate with Azure Policy compliance dashboard providing:
- Real-time compliance status across all ML workspaces
- Resource-level compliance details with remediation guidance
- Non-compliant resource identification and prioritization
- Automated remediation capabilities for diagnostic settings

### **Log Analytics Integration**
When deployed with diagnostic settings, the policies provide:
- Centralized ML workspace logging and monitoring
- Advanced query capabilities with KQL for compliance analysis
- Custom alert and dashboard creation for ML governance
- Integration with Azure Sentinel for security monitoring

### **Compliance Reporting**
```kusto
// Example KQL query for ML compliance monitoring
PolicyEvents
| where ResourceProvider == "Microsoft.MachineLearningServices"
| where ResourceType == "workspaces"
| where SubscriptionId == "{subscription-id}"
| summarize ComplianceCount = count() by ComplianceState, PolicyDefinitionName
| render columnchart
```

## 🔒 **Security Considerations**

### **Least Privilege Access**
Policies require specific role assignments:
- **Machine Learning Contributor**: For policy evaluation and workspace management
- **Log Analytics Contributor**: For diagnostic settings deployment
- **Key Vault Contributor**: For encryption key validation
- **Network Contributor**: For private endpoint validation

### **Exception Management**
- Document all policy exceptions with business justification
- Implement time-limited exceptions with automatic expiry
- Regular review of excluded resource groups and resources
- Audit trail for all exception requests and approvals

### **ML-Specific Security**
- Model protection through secure compute environments
- Data lineage tracking through comprehensive logging
- Secure model deployment pipelines with identity validation
- Integration with Azure Security Center for ML security insights

## 📚 **Additional Resources**

- [Microsoft SFI-W1 Documentation](https://docs.microsoft.com/en-us/security/sfi-w1)
- [Azure Machine Learning Security](https://docs.microsoft.com/en-us/azure/machine-learning/concept-enterprise-security)
- [Azure Policy Best Practices](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/best-practices)
- [ML Workspace Security Configuration](https://docs.microsoft.com/en-us/azure/machine-learning/how-to-network-security-overview)

## 🏷️ **Version History**

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2025-08-04 | Complete SFI-W1 compliance overhaul, enhanced ML security controls |
| 1.0.0 | 2024-10-01 | Initial ML policy framework release |

---

**Last Updated**: August 4, 2025  
**Maintained By**: Azure AI Infrastructure Team  
**Contact**: azure-ai-policies@company.com
