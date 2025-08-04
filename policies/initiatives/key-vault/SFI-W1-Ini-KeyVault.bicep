// Policy Initiative: SFI-W1-Ini-KeyVault
@description('Comprehensive Key Vault security initiative for SFI-W1 compliance')
param initiativeName string = 'SFI-W1-Ini-KeyVault'
param initiativeDisplayName string = 'SFI-W1 Initiative for Azure Key Vault Security'
param initiativeDescription string = 'Groups SFI-W1 compliance policies for Azure Key Vault workloads including encryption, access control, monitoring, and network security.'

targetScope = 'subscription'

resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'Security'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
    }
    policyDefinitions: [
      // Core Security Controls
      {
        policyDefinitionReferenceId: 'requirePrivateEndpoint'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-RequireKeyVaultPrivateEndpoint')
        parameters: {}
      }
      {
        policyDefinitionReferenceId: 'disablePublicNetworkAccess'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-KeyVault-DisablePublicNetworkAccess')
        parameters: {}
      }
      {
        policyDefinitionReferenceId: 'requireRBAC'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-KeyVault-RequireRBAC')
        parameters: {}
      }
      // Data Protection
      {
        policyDefinitionReferenceId: 'requirePurgeProtection'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-KeyVault-RequirePurgeProtection')
        parameters: {}
      }
      {
        policyDefinitionReferenceId: 'requireSoftDelete'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-KeyVault-RequireSoftDelete')
        parameters: {
          minimumRetentionDays: {
            value: 90
          }
        }
      }
      {
        policyDefinitionReferenceId: 'requireCustomerManagedKeys'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-KeyVault-RequireCustomerManagedKeys')
        parameters: {
          allowedKeyTypes: {
            value: [
              'RSA'
              'RSA-HSM'
            ]
          }
          minimumKeySize: {
            value: 2048
          }
        }
      }
      // Identity and Access Management
      {
        policyDefinitionReferenceId: 'requireManagedIdentity'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-KeyVault-RequireManagedIdentity')
        parameters: {}
      }
      {
        policyDefinitionReferenceId: 'requireAISecretsInKeyVault'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-KeyVaultAISecrets')
        parameters: {}
      }
      // Monitoring and Compliance
      {
        policyDefinitionReferenceId: 'requireDiagnosticSettings'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-KeyVault-RequireDiagnosticSettings')
        parameters: {
          logAnalyticsWorkspaceId: {
            value: '[parameters(\'logAnalyticsWorkspaceId\')]'
          }
          requiredLogCategories: {
            value: [
              'AuditEvent'
              'AzurePolicyEvaluationDetails'
            ]
          }
        }
      }
    ]
    parameters: {
      logAnalyticsWorkspaceId: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics Workspace Resource ID'
          description: 'The resource ID of the Log Analytics workspace to send diagnostic logs to'
        }
      }
    }
  }
}
