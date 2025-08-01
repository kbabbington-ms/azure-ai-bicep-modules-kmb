# Azure Cognitive Services Module Test Scenarios

## Test Scenario 1: Azure OpenAI with Maximum Security

### Description
Deploy Azure OpenAI service with all security features enabled: private endpoints, customer-managed encryption, disabled local auth, and comprehensive monitoring.

### Parameters
```json
{
  "cognitiveServiceName": { "value": "test-openai-secure" },
  "kind": { "value": "OpenAI" },
  "skuName": { "value": "S0" },
  "disableLocalAuth": { "value": true },
  "publicNetworkAccess": { "value": "Disabled" },
  "customSubDomainName": { "value": "test-openai-secure" },
  "networkAclsDefaultAction": { "value": "Deny" },
  "encryptionKeySource": { "value": "Microsoft.KeyVault" },
  "keyVaultUri": { "value": "https://test-kv.vault.azure.net/" },
  "keyVaultKeyName": { "value": "openai-key" },
  "managedIdentityType": { "value": "SystemAssigned" },
  "enablePrivateEndpoint": { "value": true },
  "enableDiagnosticSettings": { "value": true },
  "enableAlerts": { "value": true }
}
```

### Expected Outcomes
- ✅ OpenAI service with S0 SKU
- ✅ Private endpoint created
- ✅ Local auth disabled (Azure AD only)
- ✅ Customer-managed encryption enabled
- ✅ Network ACLs configured
- ✅ Diagnostic logging enabled
- ✅ System-assigned managed identity

---

## Test Scenario 2: Multi-Service Cognitive Services for Development

### Description
Deploy a multi-service Cognitive Services account for development/testing with basic security and public access.

### Parameters
```json
{
  "cognitiveServiceName": { "value": "test-multiservice-dev" },
  "kind": { "value": "CognitiveServices" },
  "skuName": { "value": "F0" },
  "disableLocalAuth": { "value": false },
  "publicNetworkAccess": { "value": "Enabled" },
  "networkAclsDefaultAction": { "value": "Allow" },
  "encryptionKeySource": { "value": "Microsoft.CognitiveServices" },
  "managedIdentityType": { "value": "None" },
  "enablePrivateEndpoint": { "value": false },
  "enableDiagnosticSettings": { "value": false },
  "enableAlerts": { "value": false }
}
```

### Expected Outcomes
- ✅ Multi-service account with F0 (free) SKU
- ✅ Public access enabled
- ✅ API key authentication enabled
- ✅ Platform-managed encryption
- ✅ No private endpoints
- ✅ Minimal monitoring

---

## Test Scenario 3: Speech Services with IP Restrictions

### Description
Deploy Speech Services with specific IP address allowlist and Azure Services bypass.

### Parameters
```json
{
  "cognitiveServiceName": { "value": "test-speech-restricted" },
  "kind": { "value": "SpeechServices" },
  "skuName": { "value": "S0" },
  "publicNetworkAccess": { "value": "Enabled" },
  "networkAclsDefaultAction": { "value": "Deny" },
  "networkAclsBypass": { "value": "AzureServices" },
  "allowedIpAddresses": { "value": ["203.0.113.0/24", "198.51.100.50"] },
  "customSubDomainName": { "value": "test-speech-restricted" },
  "managedIdentityType": { "value": "SystemAssigned" },
  "enableDiagnosticSettings": { "value": true }
}
```

### Expected Outcomes
- ✅ Speech Services with S0 SKU
- ✅ IP-based access restrictions
- ✅ Azure Services bypass enabled
- ✅ Custom subdomain configured
- ✅ System-assigned managed identity
- ✅ Diagnostic logging enabled

---

## Test Scenario 4: Computer Vision with VNet Integration

### Description
Deploy Computer Vision service with virtual network integration and user-assigned managed identity.

### Parameters
```json
{
  "cognitiveServiceName": { "value": "test-vision-vnet" },
  "kind": { "value": "ComputerVision" },
  "skuName": { "value": "S1" },
  "networkAclsDefaultAction": { "value": "Deny" },
  "allowedSubnetIds": { "value": ["/subscriptions/{sub}/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/ai-subnet"] },
  "managedIdentityType": { "value": "UserAssigned" },
  "userAssignedIdentityIds": { "value": { "/subscriptions/{sub}/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test-identity": {} } },
  "customSubDomainName": { "value": "test-vision-vnet" },
  "enablePrivateEndpoint": { "value": true },
  "privateEndpointSubnetId": { "value": "/subscriptions/{sub}/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/pe-subnet" }
}
```

### Expected Outcomes
- ✅ Computer Vision with S1 SKU
- ✅ VNet subnet access configured
- ✅ User-assigned managed identity
- ✅ Private endpoint in specified subnet
- ✅ Custom subdomain enabled

---

## Test Scenario 5: Form Recognizer with Multi-Region

### Description
Deploy Form Recognizer (Document Intelligence) with multi-region configuration for global availability.

### Parameters
```json
{
  "cognitiveServiceName": { "value": "test-formrec-global" },
  "kind": { "value": "FormRecognizer" },
  "skuName": { "value": "S0" },
  "enableMultiRegion": { "value": true },
  "multiRegionRoutingMethod": { "value": "Performance" },
  "additionalRegions": { "value": [
    { "name": "West Europe", "value": 1, "customsubdomain": "test-formrec-we" },
    { "name": "Southeast Asia", "value": 1, "customsubdomain": "test-formrec-sea" }
  ]},
  "customSubDomainName": { "value": "test-formrec-global" },
  "managedIdentityType": { "value": "SystemAssigned" },
  "enableDiagnosticSettings": { "value": true }
}
```

### Expected Outcomes
- ✅ Form Recognizer with S0 SKU
- ✅ Multi-region deployment
- ✅ Performance-based routing
- ✅ Additional regions configured
- ✅ Global custom subdomains

---

## Test Scenario 6: Text Analytics with User-Owned Storage

### Description
Deploy Text Analytics with user-owned storage for data residency compliance.

### Parameters
```json
{
  "cognitiveServiceName": { "value": "test-textanalytics-compliance" },
  "kind": { "value": "TextAnalytics" },
  "skuName": { "value": "S0" },
  "enableUserOwnedStorage": { "value": true },
  "userOwnedStorageAccounts": { "value": [
    {
      "storageAccountResourceId": "/subscriptions/{sub}/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage",
      "identityClientId": "{client-id}"
    }
  ]},
  "customSubDomainName": { "value": "test-textanalytics-compliance" },
  "restrictOutboundNetworkAccess": { "value": true },
  "allowedFqdnList": { "value": ["api.cognitive.microsoft.com"] },
  "managedIdentityType": { "value": "SystemAssigned" }
}
```

### Expected Outcomes
- ✅ Text Analytics with S0 SKU
- ✅ User-owned storage configured
- ✅ Outbound network restrictions
- ✅ FQDN allowlist configured
- ✅ Compliance-ready configuration

---

## Test Scenario 7: Custom Vision with RBAC

### Description
Deploy Custom Vision service with comprehensive RBAC assignments for different user types.

### Parameters
```json
{
  "cognitiveServiceName": { "value": "test-customvision-rbac" },
  "kind": { "value": "CustomVision.Training" },
  "skuName": { "value": "S0" },
  "customSubDomainName": { "value": "test-customvision-rbac" },
  "managedIdentityType": { "value": "SystemAssigned" },
  "roleAssignments": { "value": [
    {
      "principalId": "{data-scientist-group-id}",
      "roleDefinitionId": "Cognitive Services Contributor",
      "principalType": "Group",
      "description": "Data Scientists full access"
    },
    {
      "principalId": "{app-service-identity}",
      "roleDefinitionId": "Cognitive Services User",
      "principalType": "ServicePrincipal",
      "description": "Application read access"
    },
    {
      "principalId": "{readonly-users-group}",
      "roleDefinitionId": "Cognitive Services Data Reader",
      "principalType": "Group",
      "description": "Read-only access for auditors"
    }
  ]},
  "enableDiagnosticSettings": { "value": true },
  "enableAlerts": { "value": true }
}
```

### Expected Outcomes
- ✅ Custom Vision Training with S0 SKU
- ✅ Multiple RBAC assignments
- ✅ Group and service principal access
- ✅ Role-based permissions enforced
- ✅ Audit logging enabled

---

## Test Scenario 8: Face API with Restricted Outbound Access

### Description
Deploy Face API with maximum security restrictions for sensitive biometric data processing.

### Parameters
```json
{
  "cognitiveServiceName": { "value": "test-face-restricted" },
  "kind": { "value": "Face" },
  "skuName": { "value": "S0" },
  "disableLocalAuth": { "value": true },
  "publicNetworkAccess": { "value": "Disabled" },
  "restrictOutboundNetworkAccess": { "value": true },
  "allowedFqdnList": { "value": ["api.cognitive.microsoft.com", "management.azure.com"] },
  "networkAclsDefaultAction": { "value": "Deny" },
  "customSubDomainName": { "value": "test-face-restricted" },
  "encryptionKeySource": { "value": "Microsoft.KeyVault" },
  "keyVaultUri": { "value": "https://test-face-kv.vault.azure.net/" },
  "keyVaultKeyName": { "value": "face-api-key" },
  "managedIdentityType": { "value": "SystemAssigned" },
  "enablePrivateEndpoint": { "value": true },
  "enableDiagnosticSettings": { "value": true }
}
```

### Expected Outcomes
- ✅ Face API with maximum security
- ✅ All network access restricted
- ✅ Customer-managed encryption
- ✅ Private endpoints only
- ✅ Comprehensive audit logging
- ✅ Biometric data protection compliance

---

## Test Scenario 9: Language Understanding (LUIS) Legacy

### Description
Deploy LUIS service for existing applications with migration considerations.

### Parameters
```json
{
  "cognitiveServiceName": { "value": "test-luis-legacy" },
  "kind": { "value": "Luis" },
  "skuName": { "value": "S0" },
  "customSubDomainName": { "value": "test-luis-legacy" },
  "managedIdentityType": { "value": "SystemAssigned" },
  "publicNetworkAccess": { "value": "Enabled" },
  "networkAclsDefaultAction": { "value": "Allow" },
  "enableDiagnosticSettings": { "value": true },
  "migrationToken": { "value": "legacy-luis-migration-token" }
}
```

### Expected Outcomes
- ✅ LUIS service with S0 SKU
- ✅ Migration token configured
- ✅ Legacy application support
- ✅ Public access for existing integrations
- ✅ Diagnostic logging for migration tracking

---

## Test Scenario 10: Restore Deleted Cognitive Service

### Description
Restore a previously deleted Cognitive Services account with original configuration.

### Parameters
```json
{
  "cognitiveServiceName": { "value": "test-restored-service" },
  "kind": { "value": "CognitiveServices" },
  "skuName": { "value": "S0" },
  "restore": { "value": true },
  "customSubDomainName": { "value": "test-restored-service" },
  "managedIdentityType": { "value": "SystemAssigned" },
  "enableDiagnosticSettings": { "value": true }
}
```

### Expected Outcomes
- ✅ Service restored with original data
- ✅ Configuration preserved
- ✅ Identity and permissions restored
- ✅ Diagnostic logging enabled

---

## Test Execution Commands

### Validate Template
```bash
az deployment group validate \
  --resource-group test-rg \
  --template-file cognitive-services.bicep \
  --parameters @cognitive-services.parameters.json
```

### Deploy with Test Parameters
```bash
az deployment group create \
  --resource-group test-rg \
  --template-file cognitive-services.bicep \
  --parameters @cognitive-services.parameters.json \
  --name cognitive-services-test-deployment
```

### PowerShell Commands
```powershell
# Validate template
Test-AzResourceGroupDeployment `
  -ResourceGroupName "test-rg" `
  -TemplateFile "cognitive-services.bicep" `
  -TemplateParameterFile "cognitive-services.parameters.json"

# Deploy template
New-AzResourceGroupDeployment `
  -ResourceGroupName "test-rg" `
  -TemplateFile "cognitive-services.bicep" `
  -TemplateParameterFile "cognitive-services.parameters.json" `
  -Name "cognitive-services-test-deployment"
```

## Security Validation Checklist

- [ ] **Authentication**: Local auth disabled, Azure AD enforced
- [ ] **Network Security**: Private endpoints configured, network ACLs applied
- [ ] **Encryption**: Customer-managed keys configured where specified
- [ ] **Access Control**: RBAC assignments properly configured
- [ ] **Monitoring**: Diagnostic settings enabled, alerts configured
- [ ] **Compliance**: User-owned storage for data residency
- [ ] **Identity**: Managed identities configured for Azure resource access
- [ ] **Network Isolation**: VNet integration and IP restrictions working

## Performance Testing

After deployment, verify:
- Endpoint accessibility through private endpoints
- API response times within acceptable limits
- Multi-region routing functionality
- Throttling and rate limiting behavior
- Alert trigger conditions

## Cleanup Commands

```bash
# Delete test deployment
az deployment group delete \
  --resource-group test-rg \
  --name cognitive-services-test-deployment

# Delete test resource group
az group delete --name test-rg --yes
```
