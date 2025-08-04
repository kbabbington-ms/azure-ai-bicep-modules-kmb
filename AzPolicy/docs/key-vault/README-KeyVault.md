# Azure Key Vault Security Policies - SFI-W1 Compliance

## Overview

This document outlines the comprehensive Azure Key Vault security policies implemented as part of the **SFI-W1 (Secure Foundational Infrastructure - Workload 1)** compliance framework. These policies ensure that Key Vaults meet enterprise security standards for AI workloads.

## Policy Initiative: SFI-W1-Ini-KeyVault

The Key Vault initiative groups 9 security policies that provide comprehensive protection across all aspects of Key Vault security.

### **Core Security Controls**

| Policy | Description | Effect | Scope |
|--------|-------------|--------|-------|
| `SFI-W1-Def-Foundry-RequireKeyVaultPrivateEndpoint` | Requires private endpoints for Key Vault access | Deny | All Key Vaults |
| `SFI-W1-Def-KeyVault-DisablePublicNetworkAccess` | Disables public network access | Deny | All Key Vaults |
| `SFI-W1-Def-KeyVault-RequireRBAC` | Enforces Azure RBAC authorization | Deny | All Key Vaults |

### **Data Protection**

| Policy | Description | Effect | Scope |
|--------|-------------|--------|-------|
| `SFI-W1-Def-KeyVault-RequirePurgeProtection` | Enables purge protection | Deny | All Key Vaults |
| `SFI-W1-Def-KeyVault-RequireSoftDelete` | Requires soft delete with 90-day retention | Deny | All Key Vaults |
| `SFI-W1-Def-KeyVault-RequireCustomerManagedKeys` | Enforces customer-managed encryption | AuditIfNotExists | Premium Key Vaults |

### **Identity and Access Management**

| Policy | Description | Effect | Scope |
|--------|-------------|--------|-------|
| `SFI-W1-Def-KeyVault-RequireManagedIdentity` | Requires managed identity access | Audit | AI Services |
| `SFI-W1-Def-Foundry-KeyVaultAISecrets` | Enforces Key Vault for AI secrets | Deny | AI Services |

### **Monitoring and Compliance**

| Policy | Description | Effect | Scope |
|--------|-------------|--------|-------|
| `SFI-W1-Def-KeyVault-RequireDiagnosticSettings` | Requires audit logging to Log Analytics | AuditIfNotExists | All Key Vaults |

## Security Controls Explained

### **🔒 Network Security**

#### **Private Endpoints Required**
- **Purpose**: Eliminates internet exposure of Key Vault endpoints
- **Implementation**: Forces all access through private endpoints within VNets
- **Compliance**: Meets zero-trust network requirements

#### **Public Network Access Disabled**
- **Purpose**: Prevents direct internet access to Key Vault
- **Implementation**: Sets `publicNetworkAccess: 'Disabled'`
- **Compliance**: Ensures network isolation

### **🛡️ Access Control**

#### **Azure RBAC Authorization**
- **Purpose**: Provides centralized, granular access control
- **Implementation**: Replaces vault access policies with Azure RBAC
- **Benefits**: 
  - Centralized identity management
  - Conditional access support
  - Audit trail integration
  - Principle of least privilege

#### **Managed Identity Access**
- **Purpose**: Eliminates stored credentials and connection strings
- **Implementation**: Requires services to use system or user-assigned managed identities
- **Benefits**:
  - No credential rotation needed
  - Automatic Azure AD integration
  - Enhanced security posture

### **💾 Data Protection**

#### **Purge Protection**
- **Purpose**: Prevents permanent deletion of Key Vault and its contents
- **Implementation**: `enablePurgeProtection: true`
- **Protection**: Even with delete permissions, resources cannot be permanently removed

#### **Soft Delete with Extended Retention**
- **Purpose**: Provides recovery window for accidentally deleted resources
- **Implementation**: 90-day retention period (configurable)
- **Recovery**: Deleted keys, secrets, and certificates can be recovered

#### **Customer-Managed Keys (CMK)**
- **Purpose**: Provides additional encryption control and compliance
- **Implementation**: Requires RSA or RSA-HSM keys with minimum 2048-bit size
- **Benefits**:
  - Enhanced data sovereignty
  - Customer control over encryption keys
  - Compliance with regulatory requirements

### **📊 Monitoring and Audit**

#### **Diagnostic Settings**
- **Purpose**: Comprehensive audit trail for compliance and security monitoring
- **Implementation**: Required log categories:
  - `AuditEvent`: All Key Vault access events
  - `AzurePolicyEvaluationDetails`: Policy compliance events
- **Integration**: Logs sent to centralized Log Analytics workspace

## Deployment Examples

### **Deploy Key Vault Initiative**

```bash
# Deploy the complete Key Vault security initiative
az deployment sub create \
  --template-file initiatives/key-vault/SFI-W1-Ini-KeyVault.bicep \
  --parameters logAnalyticsWorkspaceId="/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}"
```

### **Deploy Individual Policies**

```bash
# Deploy specific policies
az deployment sub create \
  --template-file definitions/key-vault/SFI-W1-Def-KeyVault-RequirePurgeProtection.bicep

az deployment sub create \
  --template-file definitions/key-vault/SFI-W1-Def-KeyVault-RequireRBAC.bicep
```

## Compliance Mapping

### **SFI-W1 Framework Alignment**

| SFI-W1 Control | Policy Implementation | Coverage |
|----------------|----------------------|----------|
| **Network Isolation** | Private endpoints + public access disabled | ✅ Complete |
| **Identity Management** | RBAC + managed identities | ✅ Complete |
| **Data Protection** | CMK + purge protection + soft delete | ✅ Complete |
| **Audit & Monitoring** | Diagnostic settings + audit events | ✅ Complete |
| **Access Control** | RBAC authorization model | ✅ Complete |

### **Industry Standards**

- **SOC 2 Type II**: Audit logging and access controls
- **ISO 27001**: Information security management
- **NIST Cybersecurity Framework**: Identify, Protect, Detect, Respond, Recover
- **GDPR**: Data protection and privacy controls

## Testing and Validation

### **Pre-Deployment Testing**

```bash
# Validate policy definitions
az policy definition create --mode All --rules "definitions/key-vault/*.bicep" --dry-run

# Test initiative compilation
az deployment sub validate \
  --template-file initiatives/key-vault/SFI-W1-Ini-KeyVault.bicep
```

### **Post-Deployment Validation**

```bash
# Check policy assignment
az policy assignment list --scope "/subscriptions/{subscription-id}"

# Verify compliance state
az policy state list --resource-type "Microsoft.KeyVault/vaults"
```

## Troubleshooting

### **Common Issues**

1. **Private Endpoint Creation Failures**
   - Ensure subnet has sufficient IP addresses
   - Verify DNS configuration for private endpoint resolution

2. **RBAC Permission Errors**
   - Assign appropriate Key Vault roles (Key Vault Administrator, etc.)
   - Ensure service principals have managed identity enabled

3. **Diagnostic Settings Deployment**
   - Verify Log Analytics workspace permissions
   - Check workspace region compatibility

### **Exemption Process**

For legitimate business cases requiring policy exemptions:

```bash
# Create policy exemption
az policy exemption create \
  --name "KeyVault-Legacy-Exception" \
  --policy-assignment "{assignment-id}" \
  --exemption-category "Waiver" \
  --expires "2025-12-31T23:59:59Z"
```

## Maintenance

### **Regular Reviews**
- **Monthly**: Review policy compliance reports
- **Quarterly**: Update policy parameters if needed
- **Annually**: Review and update security requirements

### **Updates**
- Monitor Azure policy updates and new features
- Test policy changes in non-production environments
- Maintain documentation with any policy modifications

---

**Document Version**: 1.0.0  
**Last Updated**: August 2, 2025  
**Next Review**: November 2, 2025
