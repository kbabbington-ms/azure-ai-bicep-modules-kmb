targetScope = 'subscription'

// SFI-W1 General Security Initiative
// Groups SFI-W1 general security and compliance policies applicable across all Azure AI services
param initiativeName string = 'SFI-W1-Ini-General'
param initiativeDisplayName string = 'SFI-W1 General Security Initiative'
param initiativeDescription string = 'Groups SFI-W1 general security and compliance policies applicable across all Azure AI and cloud services for consistent governance and security baseline.'

// SFI-W1 General Security Policy Initiative
resource generalSecurityInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'Security'
      version: '1.0.0'
      source: 'Azure General Security SFI'
    }
    policyDefinitions: [
      {
        policyDefinitionReferenceId: 'requireDiagnosticLogging'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-RequireDiagnosticLogging')
      }
      {
        policyDefinitionReferenceId: 'restrictPublicNetworkAccess'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-RestrictPublicNetworkAccess')
      }
      {
        policyDefinitionReferenceId: 'requireEncryptionAtRest'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-RequireEncryptionAtRest')
      }
      {
        policyDefinitionReferenceId: 'enforceManagedIdentityUsage'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-EnforceManagedIdentityUsage')
      }
      {
        policyDefinitionReferenceId: 'requireCreatedByTag'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-RequireCreatedByTag')
      }
      {
        policyDefinitionReferenceId: 'encryptionInTransit'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-EncryptionTransitAI')
      }
      {
        policyDefinitionReferenceId: 'auditLogRetention'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-LogRetentionAI')
      }
      {
        policyDefinitionReferenceId: 'dataResidencyCompliance'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-DataResidency')
      }
    ]
  }
}

output initiativeId string = generalSecurityInitiative.id
output initiativeName string = generalSecurityInitiative.name
