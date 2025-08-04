# 🧪 Key Vault Module - Test Scenarios

## 📋 Overview

This document provides comprehensive test scenarios for validating the Key Vault module across different enterprise configurations, security requirements, and operational scenarios.

## 🎯 Test Scenarios Matrix

### ✅ **Scenario 1: Maximum Security Configuration**
**Purpose**: Enterprise production workload with maximum security controls

```bicep
// Parameters for maximum security
{
  "keyVaultName": "kv-maxsec-prod-001",
  "sku": "premium",
  "enableSoftDelete": true,
  "enablePurgeProtection": true,
  "enableRbacAuthorization": true,
  "enableVaultForDeployment": false,
  "enableVaultForTemplateDeployment": false,
  "enableVaultForDiskEncryption": true,
  "publicNetworkAccess": "Disabled",
  "enablePrivateEndpoint": true,
  "privateEndpointSubnetId": "/subscriptions/.../subnets/private-endpoints",
  "networkAcls": {
    "defaultAction": "Deny",
    "bypass": "AzureServices"
  },
  "roleAssignments": [
    {
      "principalId": "...",
      "roleDefinitionId": "00482a5a-887f-4fb3-b363-3b7fe8e74483", // Key Vault Administrator
      "principalType": "User"
    }
  ]
}
```

**Expected Outcomes**:
- ✅ Private endpoint created and configured
- ✅ Public access completely disabled
- ✅ Premium SKU with HSM backing
- ✅ RBAC enabled, access policies disabled
- ✅ Soft delete and purge protection enabled

---

### ✅ **Scenario 2: Development Environment**
**Purpose**: Simplified configuration for development and testing

```bicep
// Parameters for development
{
  "keyVaultName": "kv-dev-test-001",
  "sku": "standard",
  "enableSoftDelete": true,
  "enablePurgeProtection": false,
  "enableRbacAuthorization": true,
  "publicNetworkAccess": "Enabled",
  "enablePrivateEndpoint": false,
  "networkAcls": {
    "defaultAction": "Allow"
  },
  "diagnosticSettings": {
    "enableAuditLogs": true,
    "retentionInDays": 30
  }
}
```

**Expected Outcomes**:
- ✅ Public access enabled for development ease
- ✅ Standard SKU for cost optimization
- ✅ Soft delete enabled, purge protection disabled
- ✅ Basic diagnostic logging configured

---

### ✅ **Scenario 3: RBAC Configuration**
**Purpose**: Complex role assignment scenarios

```bicep
// Parameters for RBAC testing
{
  "keyVaultName": "kv-rbac-test-001",
  "enableRbacAuthorization": true,
  "roleAssignments": [
    {
      "principalId": "admin-group-id",
      "roleDefinitionId": "00482a5a-887f-4fb3-b363-3b7fe8e74483", // Key Vault Administrator
      "principalType": "Group"
    },
    {
      "principalId": "devops-group-id", 
      "roleDefinitionId": "14b46e9e-c2b7-41b4-b07b-48a6ebf60603", // Key Vault Crypto Officer
      "principalType": "Group"
    },
    {
      "principalId": "app-service-principal",
      "roleDefinitionId": "4633458b-17de-408a-b874-0445c86b69e6", // Key Vault Secrets User
      "principalType": "ServicePrincipal"
    }
  ]
}
```

**Expected Outcomes**:
- ✅ Multiple role assignments created correctly
- ✅ Different principal types supported
- ✅ Appropriate permissions for each role

---

### ✅ **Scenario 4: VNet Integration**
**Purpose**: Network isolation and subnet restrictions

```bicep
// Parameters for VNet integration
{
  "keyVaultName": "kv-vnet-001",
  "publicNetworkAccess": "Disabled",
  "enablePrivateEndpoint": true,
  "privateEndpointSubnetId": "/subscriptions/.../subnets/kv-private",
  "privateDnsZoneId": "/subscriptions/.../privateDnsZones/privatelink.vaultcore.azure.net",
  "networkAcls": {
    "defaultAction": "Deny",
    "bypass": "AzureServices",
    "virtualNetworkRules": [
      {
        "id": "/subscriptions/.../subnets/trusted-subnet",
        "ignoreMissingVnetServiceEndpoint": false
      }
    ]
  }
}
```

**Expected Outcomes**:
- ✅ Private endpoint in specified subnet
- ✅ Private DNS zone integration
- ✅ VNet service endpoints configured
- ✅ Network access rules enforced

---

### ✅ **Scenario 5: HSM Premium Vault**
**Purpose**: Hardware security module backing

```bicep
// Parameters for HSM Premium
{
  "keyVaultName": "kv-hsm-premium-001",
  "sku": "premium",
  "enableRbacAuthorization": true,
  "enablePurgeProtection": true,
  "softDeleteRetentionInDays": 90,
  "roleAssignments": [
    {
      "principalId": "crypto-admin-id",
      "roleDefinitionId": "14b46e9e-c2b7-41b4-b07b-48a6ebf60603", // Key Vault Crypto Officer
      "principalType": "User"
    }
  ]
}
```

**Expected Outcomes**:
- ✅ Premium SKU with HSM support
- ✅ Extended soft delete retention
- ✅ Crypto officer role assigned
- ✅ Hardware-backed key operations

---

### ✅ **Scenario 6: Compliance Configuration (HIPAA/SOC2)**
**Purpose**: Regulatory compliance requirements

```bicep
// Parameters for compliance
{
  "keyVaultName": "kv-compliance-001",
  "sku": "premium",
  "enablePurgeProtection": true,
  "softDeleteRetentionInDays": 90,
  "publicNetworkAccess": "Disabled",
  "enablePrivateEndpoint": true,
  "diagnosticSettings": {
    "enableAuditLogs": true,
    "enableMetrics": true,
    "retentionInDays": 365
  },
  "tags": {
    "Environment": "Production",
    "Compliance": "HIPAA,SOC2",
    "DataClassification": "Sensitive",
    "BusinessCriticality": "High"
  }
}
```

**Expected Outcomes**:
- ✅ Extended audit log retention (365 days)
- ✅ Premium SKU for hardware backing
- ✅ Purge protection enabled
- ✅ Compliance tags applied

---

### ✅ **Scenario 7: Disaster Recovery**
**Purpose**: Backup and geo-redundancy testing

```bicep
// Parameters for DR
{
  "keyVaultName": "kv-dr-primary-001",
  "sku": "premium",
  "enableSoftDelete": true,
  "enablePurgeProtection": true,
  "softDeleteRetentionInDays": 90,
  "diagnosticSettings": {
    "enableAuditLogs": true,
    "retentionInDays": 180
  },
  "tags": {
    "DisasterRecovery": "Primary",
    "BackupFrequency": "Daily"
  }
}
```

**Expected Outcomes**:
- ✅ Geo-redundant storage configured
- ✅ Extended soft delete for recovery
- ✅ Audit trail for compliance
- ✅ DR tags for management

---

### ✅ **Scenario 8: Cross-Subscription Access**
**Purpose**: Multi-subscription enterprise scenarios

```bicep
// Parameters for cross-subscription
{
  "keyVaultName": "kv-cross-sub-001",
  "enableRbacAuthorization": true,
  "roleAssignments": [
    {
      "principalId": "subscription-b-admin-id",
      "roleDefinitionId": "21090545-7ca7-4776-b22c-e363652d74d2", // Key Vault Reader
      "principalType": "User"
    }
  ],
  "diagnosticSettings": {
    "workspaceId": "/subscriptions/other-sub/.../logAnalyticsWorkspace"
  }
}
```

**Expected Outcomes**:
- ✅ Cross-subscription RBAC assignments
- ✅ Cross-subscription diagnostic settings
- ✅ Proper permission delegation

---

### ✅ **Scenario 9: Service Integration**
**Purpose**: Azure service integration testing

```bicep
// Parameters for service integration
{
  "keyVaultName": "kv-service-int-001",
  "enableVaultForDeployment": true,
  "enableVaultForTemplateDeployment": true,
  "enableVaultForDiskEncryption": true,
  "roleAssignments": [
    {
      "principalId": "vm-managed-identity",
      "roleDefinitionId": "4633458b-17de-408a-b874-0445c86b69e6", // Key Vault Secrets User
      "principalType": "ServicePrincipal"
    }
  ]
}
```

**Expected Outcomes**:
- ✅ VM deployment access enabled
- ✅ ARM template deployment access
- ✅ Disk encryption access configured
- ✅ Managed identity access granted

---

### ✅ **Scenario 10: Monitoring and Alerting**
**Purpose**: Comprehensive monitoring setup

```bicep
// Parameters for monitoring
{
  "keyVaultName": "kv-monitoring-001",
  "diagnosticSettings": {
    "enableAuditLogs": true,
    "enableMetrics": true,
    "retentionInDays": 90
  },
  "monitoringAlerts": {
    "enableAccessAlerts": true,
    "enableFailureAlerts": true,
    "enableAdminAlerts": true,
    "actionGroupId": "/subscriptions/.../actionGroups/security-alerts"
  }
}
```

**Expected Outcomes**:
- ✅ Audit logs configured and flowing
- ✅ Metrics collection enabled
- ✅ Security alerts configured
- ✅ Action group notifications working

---

## 🧪 **Testing Methodology**

### **Pre-Deployment Validation**
1. **Bicep Template Validation**:
   ```bash
   az deployment group validate --resource-group test-rg --template-file key-vault.bicep --parameters @test-parameters.json
   ```

2. **What-If Analysis**:
   ```bash
   az deployment group what-if --resource-group test-rg --template-file key-vault.bicep --parameters @test-parameters.json
   ```

### **Post-Deployment Validation**
1. **Resource Verification**:
   - Verify Key Vault exists with correct configuration
   - Check private endpoint connectivity (if enabled)
   - Validate RBAC assignments
   - Test network access rules

2. **Security Validation**:
   - Attempt unauthorized access (should fail)
   - Verify audit logging is working
   - Test backup and recovery procedures
   - Validate compliance settings

3. **Functional Testing**:
   - Create and retrieve secrets
   - Test key operations (encrypt/decrypt)
   - Verify certificate management
   - Test service integrations

### **Performance Testing**
- Measure secret retrieval latency
- Test concurrent access scenarios
- Validate throughput limits
- Monitor resource utilization

---

## 📊 **Success Criteria**

### **✅ Deployment Success**
- [ ] All test scenarios deploy without errors
- [ ] Resource configurations match parameters
- [ ] Dependencies are properly configured
- [ ] Tags and metadata are applied correctly

### **✅ Security Validation**
- [ ] Access controls work as expected
- [ ] Network restrictions are enforced
- [ ] Audit logging captures all events
- [ ] Encryption settings are correct

### **✅ Operational Readiness**
- [ ] Monitoring and alerting function properly
- [ ] Backup procedures are documented
- [ ] Disaster recovery scenarios tested
- [ ] Support runbooks are complete

---

## 🔄 **Test Execution Schedule**

| Test Phase | Duration | Scenarios |
|------------|----------|-----------|
| **Phase 1** | Day 1 | Scenarios 1-3 (Core functionality) |
| **Phase 2** | Day 2 | Scenarios 4-6 (Security & Compliance) |
| **Phase 3** | Day 3 | Scenarios 7-9 (Advanced features) |
| **Phase 4** | Day 4 | Scenario 10 + Integration testing |

---

## 📞 **Support & Troubleshooting**

### **Common Issues**
1. **Private Endpoint Connectivity**: Check DNS resolution and network security groups
2. **RBAC Permissions**: Verify principal IDs and role assignments
3. **Network Access**: Review firewall rules and VNet configurations
4. **Soft Delete**: Remember 90-day retention period for permanent deletion

### **Debugging Commands**
```bash
# Check Key Vault status
az keyvault show --name <vault-name> --resource-group <rg-name>

# List role assignments
az role assignment list --scope <vault-resource-id>

# Check network access
az keyvault network-rule list --name <vault-name> --resource-group <rg-name>

# View audit logs
az monitor activity-log list --resource-group <rg-name> --resource-type Microsoft.KeyVault/vaults
```

---

**Last Updated**: August 1, 2025  
**Version**: 1.0  
**Maintainer**: AI Infrastructure Team
