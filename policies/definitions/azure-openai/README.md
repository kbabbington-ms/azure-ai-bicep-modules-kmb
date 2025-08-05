# Azure OpenAI SFI-W1 Policy Documentation

## Overview

This directory contains comprehensive Azure Policy definitions and initiatives for Azure OpenAI services, ensuring compliance with Microsoft's Secure Future Initiative (SFI-W1) and Azure Trusted Security (AzTS) standards.

## 🎯 **Policy Architecture**

### **SFI-W1 Compliance Framework**
- **Network Isolation**: Mandatory private endpoints for zero-trust architecture
- **Data Protection**: Customer-managed encryption keys for data sovereignty
- **Responsible AI**: Content filtering and safety controls
- **Resource Governance**: SKU restrictions and standardized configurations
- **Audit & Monitoring**: Comprehensive diagnostic settings and logging

### **Policy Definitions**

| Policy Name | Purpose | SFI-W1 Controls | Effect Options |
|-------------|---------|-----------------|----------------|
| **SFI-W1-Def-OpenAI-RequirePrivateEndpoints** | Enforce private endpoint usage | Network Security, Zero-Trust | Audit, Deny |
| **SFI-W1-Def-OpenAI-RequireCustomerManagedKeys** | Enforce customer-managed encryption | Data Protection, Encryption | Audit, Deny |
| **SFI-W1-Def-OpenAI-RequireContentFiltering** | Enforce responsible AI controls | Content Safety, AI Governance | Audit, Deny |
| **SFI-W1-Def-OpenAI-RestrictSKUs** | Restrict to approved SKU tiers | Resource Governance, Cost Control | Audit, Deny |
| **SFI-W1-Def-OpenAI-RequireDiagnosticSettings** | Enable comprehensive logging | Monitoring, Audit Trail | AuditIfNotExists, DeployIfNotExists |

## 📋 **Policy Details**

### **1. SFI-W1-Def-OpenAI-RequirePrivateEndpoints**

**Purpose**: Ensures Azure OpenAI accounts use private endpoints exclusively for secure communication.

**Key Features**:
- ✅ Validates private endpoint configuration
- ✅ Checks public network access is disabled
- ✅ Ensures minimum private endpoint connections
- ✅ Supports location restrictions for data residency
- ✅ Configurable exclusions for testing environments

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
  "excludedResourceGroups": ["rg-test-dev"]
}
```

### **2. SFI-W1-Def-OpenAI-RequireCustomerManagedKeys**

**Purpose**: Enforces customer-managed encryption keys for enhanced data protection and sovereignty.

**Key Features**:
- ✅ Validates Key Vault integration
- ✅ Checks managed identity configuration
- ✅ Ensures proper key rotation settings
- ✅ Supports key vault location restrictions
- ✅ Validates encryption configuration completeness

**Parameters**:
- `effect`: Policy enforcement mode (Audit/Deny/Disabled)
- `allowedKeyVaultLocations`: Permitted Key Vault regions
- `excludedResourceGroups`: Resource groups to exempt from policy
- `requireKeyRotation`: Enforce automatic key rotation

**Security Benefits**:
- 🔐 Enhanced data sovereignty and control
- 🔐 Protection against Microsoft key compromise
- 🔐 Advanced key lifecycle management
- 🔐 Compliance with strict regulatory requirements

### **3. SFI-W1-Def-OpenAI-RequireContentFiltering**

**Purpose**: Ensures responsible AI usage through mandatory content filtering for model deployments.

**Key Features**:
- ✅ Validates content filtering configuration
- ✅ Enforces minimum filtering levels
- ✅ Checks required filter categories (hate, violence, sexual, self-harm)
- ✅ Supports model-specific filtering rules
- ✅ Configurable exceptions for research scenarios

**Parameters**:
- `effect`: Policy enforcement mode (Audit/Deny/Disabled)
- `allowedContentFilterLevel`: Minimum filtering intensity (low/medium/high)
- `requiredFilterCategories`: Mandatory content categories to filter
- `excludedResourceGroups`: Resource groups to exempt from policy
- `allowExceptions`: Permit justified exceptions for specific use cases

**Responsible AI Controls**:
- 🛡️ Prevents harmful content generation
- 🛡️ Ensures ethical AI usage patterns
- 🛡️ Supports regulatory compliance (EU AI Act)
- 🛡️ Provides audit trail for AI governance

### **4. SFI-W1-Def-OpenAI-RestrictSKUs**

**Purpose**: Restricts Azure OpenAI deployments to approved SKU tiers for cost control and standardization.

**Key Features**:
- ✅ Validates account SKU configurations
- ✅ Controls deployment model versions
- ✅ Limits deployments per account
- ✅ Supports high-tier SKU approval workflows
- ✅ Configurable exclusions for testing

**Parameters**:
- `effect`: Policy enforcement mode (Audit/Deny/Disabled)
- `allowedSKUs`: Permitted SKU names (S0, S1, S2, S3)
- `allowedModelVersions`: Approved model versions for deployment
- `maxDeploymentsPerAccount`: Maximum deployments per account (1-10)
- `requireApprovalForHighTierSKUs`: Require approval for premium SKUs

**Governance Benefits**:
- 💰 Cost control and budget management
- 💰 Standardized performance tiers
- 💰 Resource allocation optimization
- 💰 Compliance with organizational standards

### **5. SFI-W1-Def-OpenAI-RequireDiagnosticSettings**

**Purpose**: Enables comprehensive audit logging and monitoring for compliance and security.

**Key Features**:
- ✅ Automatic diagnostic settings deployment
- ✅ Multiple destination support (Log Analytics, Storage, Event Hub)
- ✅ Configurable log categories and retention
- ✅ Real-time security monitoring integration
- ✅ Compliance audit trail generation

**Parameters**:
- `effect`: Policy enforcement mode (AuditIfNotExists/DeployIfNotExists/Disabled)
- `logAnalyticsWorkspaceId`: Central logging workspace
- `storageAccountId`: Long-term retention storage
- `eventHubAuthorizationRuleId`: Real-time streaming endpoint
- `requiredLogCategories`: Mandatory log types (Audit, RequestResponse, Trace)
- `logRetentionDays`: Compliance retention period (30-730 days)

**Monitoring Coverage**:
- 📊 Complete API request/response logging
- 📊 User activity and access patterns
- 📊 Model usage and performance metrics
- 📊 Security events and anomaly detection

## 🚀 **Policy Initiative**

### **SFI-W1-Ini-OpenAI: Comprehensive Azure OpenAI Compliance**

The initiative combines all five policy definitions into a coordinated compliance framework with centralized configuration and modular enablement.

**Key Features**:
- 🎯 **Modular Control**: Enable/disable policy categories independently
- 🎯 **Global Configuration**: Centralized parameter management
- 🎯 **Flexible Enforcement**: Audit or Deny modes per policy group
- 🎯 **Exception Handling**: Configurable exclusions and overrides
- 🎯 **Compliance Reporting**: Built-in compliance status tracking

**Policy Groups**:
1. **Network Security**: Private endpoints and network isolation
2. **Data Protection**: Encryption and key management
3. **Responsible AI**: Content filtering and safety controls
4. **Resource Governance**: SKU restrictions and resource standards
5. **Monitoring**: Diagnostic settings and audit logging

**Initiative Parameters**:
```json
{
  "globalEffect": "Audit",
  "enableNetworkSecurity": true,
  "enableEncryption": true,
  "enableContentFiltering": true,
  "enableGovernance": true, 
  "enableMonitoring": true,
  "allowedLocations": ["eastus", "westus2"],
  "logAnalyticsWorkspaceId": "/subscriptions/.../workspaces/...",
  "excludedResourceGroups": ["rg-test", "rg-dev"]
}
```

## 📈 **Deployment Guide**

### **Prerequisites**
- Azure CLI 2.50+ or Azure PowerShell 5.1+
- Subscription Contributor + User Access Administrator roles
- Target subscription and resource group

### **Option 1: Individual Policy Deployment**
```bash
# Deploy specific policy
az deployment sub create \
  --name "deploy-openai-private-endpoints" \
  --location "eastus" \
  --template-file "SFI-W1-Def-OpenAI-RequirePrivateEndpoints.bicep"
```

### **Option 2: Complete Initiative Deployment**
```bash
# Deploy complete initiative
az deployment sub create \
  --name "deploy-openai-sfi-initiative" \
  --location "eastus" \
  --template-file "SFI-W1-Ini-OpenAI.bicep"
```

### **Option 3: PowerShell Deployment**
```powershell
# Deploy with PowerShell
New-AzSubscriptionDeployment `
  -Name "deploy-openai-sfi-initiative" `
  -Location "eastus" `
  -TemplateFile "SFI-W1-Ini-OpenAI.bicep"
```

## 🔧 **Policy Assignment**

### **Production Assignment Example**
```bash
# Assign initiative to subscription
az policy assignment create \
  --name "openai-sfi-compliance" \
  --display-name "Azure OpenAI SFI-W1 Compliance" \
  --policy-set-definition "/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policySetDefinitions/SFI-W1-Ini-OpenAI" \
  --scope "/subscriptions/{subscription-id}" \
  --params '{
    "globalEffect": {"value": "Deny"},
    "enableNetworkSecurity": {"value": true},
    "enableEncryption": {"value": true},
    "enableContentFiltering": {"value": true},
    "enableGovernance": {"value": true},
    "enableMonitoring": {"value": true}
  }'
```

### **Development/Testing Assignment**
```bash
# Assign with audit mode for development
az policy assignment create \
  --name "openai-sfi-audit" \
  --display-name "Azure OpenAI SFI-W1 Audit Mode" \
  --policy-set-definition "/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policySetDefinitions/SFI-W1-Ini-OpenAI" \
  --scope "/subscriptions/{subscription-id}" \
  --params '{
    "globalEffect": {"value": "Audit"},
    "excludedResourceGroups": {"value": ["rg-dev", "rg-test"]}
  }'
```

## 📊 **Compliance Monitoring**

### **Built-in Compliance Dashboard**
The policies integrate with Azure Policy compliance dashboard providing:
- Real-time compliance status
- Resource-level compliance details
- Non-compliant resource identification
- Remediation guidance and automation

### **Log Analytics Integration**
When deployed with diagnostic settings, the policies provide:
- Centralized compliance logging
- Advanced query capabilities with KQL
- Custom alert and dashboard creation
- Integration with Azure Sentinel for security monitoring

### **Compliance Reporting**
```kusto
// Example KQL query for OpenAI compliance monitoring
PolicyEvents
| where ResourceProvider == "Microsoft.CognitiveServices"
| where ResourceType == "accounts"
| where SubscriptionId == "{subscription-id}"
| summarize ComplianceCount = count() by ComplianceState, PolicyDefinitionName
| render columnchart
```

## 🔒 **Security Considerations**

### **Least Privilege Access**
Policies require specific role assignments:
- **Cognitive Services Contributor**: For policy evaluation
- **Log Analytics Contributor**: For diagnostic settings deployment
- **Key Vault Contributor**: For encryption key validation

### **Exception Management**
- Document all policy exceptions with business justification
- Implement time-limited exceptions with automatic expiry
- Regular review of excluded resource groups and resources
- Audit trail for all exception requests and approvals

### **Incident Response**
- Automated alerting for policy violations
- Integration with security incident response procedures
- Escalation procedures for critical policy violations
- Regular compliance review and reporting cycles

## 📚 **Additional Resources**

- [Microsoft SFI-W1 Documentation](https://docs.microsoft.com/en-us/security/sfi-w1)
- [Azure Policy Best Practices](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/best-practices)
- [Azure OpenAI Security Guidelines](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/security)
- [Responsible AI Principles](https://www.microsoft.com/en-us/ai/responsible-ai)

## 🏷️ **Version History**

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2025-08-04 | Complete SFI-W1 compliance overhaul, enhanced security controls |
| 1.0.0 | 2024-12-01 | Initial policy framework release |

---

**Last Updated**: August 4, 2025  
**Maintained By**: Azure AI Infrastructure Team  
**Contact**: azure-ai-policies@company.com
