// Policy Initiative: SFI-W1-Ini-Foundry for Azure AI Foundry
@description('Groups SFI-W1 compliance policies for Azure AI Foundry workloads.')
param initiativeName string = 'SFI-W1-Ini-Foundry'
param initiativeDisplayName string = 'SFI-W1 Initiative for Azure AI Foundry'
param initiativeDescription string = 'Groups SFI-W1 compliance policies for Azure AI Foundry workloads.'

targetScope = 'subscription'

resource requireCreatedByTag 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-RequireCreatedByTag'
}
resource restrictPublicNetworkAccess 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-RestrictPublicNetworkAccess'
}
resource requireDiagnosticLogging 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-RequireDiagnosticLogging'
}
resource enforceManagedIdentityUsage 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-EnforceManagedIdentityUsage'
}
resource requireEncryptionAtRest 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-RequireEncryptionAtRest'
}
resource requireKeyVaultPrivateEndpoint 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-RequireKeyVaultPrivateEndpoint'
}
resource allowedAISku 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-AllowedAISku'
}
resource modelVersionControl 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-ModelVersionControl'
}
resource dataResidency 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-DataResidency'
}
resource privateEndpointAI 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-PrivateEndpointAI'
}
resource diagnosticLoggingAI 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-DiagnosticLoggingAI'
}
resource keyVaultAISecrets 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-KeyVaultAISecrets'
}
resource taggingAI 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-TaggingAI'
}
resource managedIdentityAI 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-ManagedIdentityAI'
}
resource encryptionTransitAI 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-EncryptionTransitAI'
}
resource logRetentionAI 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: 'SFI-W1-Def-Foundry-LogRetentionAI'
}

resource policyInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
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
      {
        policyDefinitionReferenceId: 'requireCreatedByTag'
        policyDefinitionId: requireCreatedByTag.id
      },{
        policyDefinitionReferenceId: 'restrictPublicNetworkAccess'
        policyDefinitionId: restrictPublicNetworkAccess.id
      },{
        policyDefinitionReferenceId: 'requireDiagnosticLogging'
        policyDefinitionId: requireDiagnosticLogging.id
      },{
        policyDefinitionReferenceId: 'enforceManagedIdentityUsage'
        policyDefinitionId: enforceManagedIdentityUsage.id
      },{
        policyDefinitionReferenceId: 'requireEncryptionAtRest'
        policyDefinitionId: requireEncryptionAtRest.id
      },{
        policyDefinitionReferenceId: 'requireKeyVaultPrivateEndpoint'
        policyDefinitionId: requireKeyVaultPrivateEndpoint.id
      },{
        policyDefinitionReferenceId: 'allowedAISku'
        policyDefinitionId: allowedAISku.id
      },{
        policyDefinitionReferenceId: 'modelVersionControl'
        policyDefinitionId: modelVersionControl.id
      },{
        policyDefinitionReferenceId: 'dataResidency'
        policyDefinitionId: dataResidency.id
      },{
        policyDefinitionReferenceId: 'privateEndpointAI'
        policyDefinitionId: privateEndpointAI.id
      },{
        policyDefinitionReferenceId: 'diagnosticLoggingAI'
        policyDefinitionId: diagnosticLoggingAI.id
      },{
        policyDefinitionReferenceId: 'keyVaultAISecrets'
        policyDefinitionId: keyVaultAISecrets.id
      },{
        policyDefinitionReferenceId: 'taggingAI'
        policyDefinitionId: taggingAI.id
      },{
        policyDefinitionReferenceId: 'managedIdentityAI'
        policyDefinitionId: managedIdentityAI.id
      },{
        policyDefinitionReferenceId: 'encryptionTransitAI'
        policyDefinitionId: encryptionTransitAI.id
      },{
        policyDefinitionReferenceId: 'logRetentionAI'
        policyDefinitionId: logRetentionAI.id
      }
    ]
  }
}
