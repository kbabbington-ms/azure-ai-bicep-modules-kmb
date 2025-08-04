# Identity and Access Management Module

This module provides advanced identity and access management capabilities for the AI Enclave with custom role definitions, managed identities, and enterprise security controls.

## Resources Deployed

- **User Assigned Managed Identity**
  - Shared identity for AI Enclave services
  - Integrated with Azure services
  - Principle of least privilege

- **Custom Role Definitions**
  - AI Enclave Operator: Operations and AI workload management
  - AI Enclave Security Officer: Security and compliance management
  - AI Enclave Auditor: Read-only access for auditing

- **Role Assignments**
  - Azure AD group-based assignments
  - Managed identity service permissions
  - Granular access control

- **Enterprise Security Integration**
  - Conditional Access Policy templates
  - Activity log monitoring
  - Identity Protection readiness

## Features

- **Zero Trust Architecture**: Principle of least privilege access
- **Custom Roles**: AI-specific role definitions with minimal permissions
- **Managed Identity**: Service-to-service authentication without secrets
- **Auditing**: Comprehensive activity logging
- **Compliance**: Enterprise security standards alignment

## Custom Roles

### AI Enclave Operator
**Purpose**: Day-to-day operations and AI workload management

**Permissions**:
- Cognitive Services: Read, write, deployments
- Machine Learning: Workspaces, experiments, models
- Storage: Blob containers and data access
- Key Vault: Secret reading
- Application Insights: Monitoring and logs
- Container Registry: Pull and push images

### AI Enclave Security Officer
**Purpose**: Security management and compliance oversight

**Permissions**:
- Security Center: Policies and assessments
- Policy Insights: Compliance monitoring
- Key Vault: Access policy management
- Network Security: NSG and WAF policies
- Diagnostic Settings: Security logging

### AI Enclave Auditor
**Purpose**: Compliance auditing and read-only access

**Permissions**:
- Read access to all resources
- Log Analytics: Query capabilities
- Security assessments
- Policy compliance reports

## Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| location | string | Azure region | resourceGroup().location |
| environment | string | Environment name | 'dev' |
| projectName | string | Project name | 'ai-enclave' |
| logAnalyticsWorkspaceId | string | Log Analytics workspace ID | '' |
| adminGroupObjectId | string | Admin group object ID | '' |
| developerGroupObjectId | string | Developer group object ID | '' |
| auditorsGroupObjectId | string | Auditor group object ID | '' |

## Outputs

| Output | Description |
|--------|-------------|
| userAssignedIdentityId | Managed Identity resource ID |
| userAssignedIdentityPrincipalId | Managed Identity principal ID |
| userAssignedIdentityClientId | Managed Identity client ID |
| aiEnclaveOperatorRoleId | AI Enclave Operator role definition ID |
| aiEnclaveSecurityRoleId | AI Enclave Security Officer role definition ID |
| aiEnclaveAuditorRoleId | AI Enclave Auditor role definition ID |
| customRoleDefinitions | Array of custom role definitions |

## Prerequisites

### Azure AD Groups
Create the following Azure AD groups before deployment:

```powershell
# Connect to Azure AD
Connect-AzureAD

# Create AI Enclave Admin Group
$adminGroup = New-AzureADGroup -DisplayName "AI-Enclave-Admins" -MailEnabled $false -SecurityEnabled $true -MailNickName "AIEnclaveAdmins"

# Create AI Enclave Developer Group
$devGroup = New-AzureADGroup -DisplayName "AI-Enclave-Developers" -MailEnabled $false -SecurityEnabled $true -MailNickName "AIEnclaveDevelopers"

# Create AI Enclave Auditor Group
$auditorGroup = New-AzureADGroup -DisplayName "AI-Enclave-Auditors" -MailEnabled $false -SecurityEnabled $true -MailNickName "AIEnclaveAuditors"

# Add users to groups
Add-AzureADGroupMember -ObjectId $adminGroup.ObjectId -RefObjectId "user-object-id"
Add-AzureADGroupMember -ObjectId $devGroup.ObjectId -RefObjectId "user-object-id"
Add-AzureADGroupMember -ObjectId $auditorGroup.ObjectId -RefObjectId "user-object-id"
```

### Required Permissions
The deployment principal needs:
- `User Access Administrator` role
- `Contributor` role
- Permission to create custom role definitions

## Security Features

### Conditional Access (Azure AD Premium Required)
Template includes Conditional Access Policy for:
- Multi-factor authentication requirement
- Compliant device enforcement
- Location-based restrictions
- Session controls

### Identity Protection (Azure AD Premium P2 Required)
- Risk-based conditional access
- Identity risk detection
- Automated remediation

### Privileged Identity Management (Azure AD Premium P2 Required)
- Just-in-time access
- Time-bound role assignments
- Approval workflows
- Access reviews

## Usage

```bash
# Deploy with Azure CLI
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters main.parameters.json

# Deploy with PowerShell
New-AzResourceGroupDeployment \
  -ResourceGroupName "myResourceGroup" \
  -TemplateFile "main.bicep" \
  -TemplateParameterFile "main.parameters.json"
```

## Integration with Other Modules

The managed identity created by this module should be used across other modules:

```bicep
// In other modules, reference the managed identity
param userAssignedIdentityId string

resource myResource 'Microsoft.SomeService/resource@2023-01-01' = {
  // ...
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
}
```

## Security Considerations

- Custom roles follow principle of least privilege
- Managed identity eliminates credential management
- Activity logs capture all permission changes
- Role assignments are group-based for easier management
- Regular access reviews should be conducted
- Consider implementing PIM for privileged roles

## Compliance Features

- Audit trail for all access changes
- Separation of duties between roles
- Read-only auditor access
- Security-focused role for compliance oversight
- Integration with Azure Policy and Security Center
