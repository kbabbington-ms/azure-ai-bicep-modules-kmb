targetScope = 'subscription'

// SFI-W1 Logic Apps AI Workflows Initiative
// Groups SFI-W1 compliance policies for Azure Logic Apps AI integration workloads
param initiativeName string = 'SFI-W1-Ini-LogicApps'
param initiativeDisplayName string = 'SFI-W1 Initiative for Azure Logic Apps AI Workflows'
param initiativeDescription string = 'Groups SFI-W1 compliance policies for Azure Logic Apps AI workflows including AI service integrations, orchestration, and automated processing pipelines.'

// SFI-W1 Logic Apps AI Workflows Policy Initiative
resource logicAppsInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'Security'
      version: '1.0.0'
      source: 'Azure Logic Apps AI Workflows SFI'
    }
    policyDefinitions: [
      {
        policyDefinitionReferenceId: 'logicAppsAIWorkflows'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-LogicAppsAIWorkflows')
      }
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
        policyDefinitionReferenceId: 'keyVaultIntegration'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-KeyVaultAISecrets')
      }
      {
        policyDefinitionReferenceId: 'encryptionInTransit'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-EncryptionTransitAI')
      }
      {
        policyDefinitionReferenceId: 'workflowAuditLogging'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-LogRetentionAI')
      }
    ]
  }
}

output initiativeId string = logicAppsInitiative.id
output initiativeName string = logicAppsInitiative.name
