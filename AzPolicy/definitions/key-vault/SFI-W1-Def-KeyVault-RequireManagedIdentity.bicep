// Policy Definition: SFI-W1-Def-KeyVault-RequireManagedIdentity
@description('Ensures Azure Key Vaults are accessed using managed identities only.')
param policyName string = 'SFI-W1-Def-KeyVault-RequireManagedIdentity'
param policyDisplayName string = 'SFI-W1-Def-KeyVault: Require Managed Identity Access'
param policyDescription string = 'Ensures Azure Key Vaults are accessed using managed identities, eliminating the need for stored credentials.'

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
        allOf: [
          {
            field: 'type'
            in: [
              'Microsoft.Web/sites'
              'Microsoft.CognitiveServices/accounts'
              'Microsoft.MachineLearningServices/workspaces'
              'Microsoft.App/containerApps'
            ]
          }
          {
            anyOf: [
              {
                field: 'identity.type'
                notIn: [
                  'SystemAssigned'
                  'UserAssigned'
                  'SystemAssigned,UserAssigned'
                ]
              }
              {
                field: 'identity'
                exists: false
              }
            ]
          }
        ]
      }
      then: {
        effect: 'audit'
      }
    }
  }
}
