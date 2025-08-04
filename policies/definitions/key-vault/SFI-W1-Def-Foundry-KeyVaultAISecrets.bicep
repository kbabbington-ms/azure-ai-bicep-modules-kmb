// Policy Definition: SFI-W1-Def-Foundry-KeyVaultAISecrets
@description('Enforce that all AI workloads use Azure Key Vault for secrets and credentials.')
param policyName string = 'SFI-W1-Def-Foundry-KeyVaultAISecrets'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Key Vault Usage for AI Secrets'
param policyDescription string = 'Enforce that all AI workloads use Azure Key Vault for secrets and credentials.'

targetScope = 'subscription'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Security'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
    }
    parameters: {}
    policyRule: {
      if: {
        field: 'Microsoft.CognitiveServices/accounts/secretsSource'
        notEquals: 'KeyVault'
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
