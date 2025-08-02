// Policy Definition: SFI-W1-Def-Foundry-RequireCreatedByTag (SFI Compliance)
@description('Ensures resource groups have the CreatedBy tag for SFI compliance.')
param policyName string = 'SFI-W1-Def-Foundry-RequireCreatedByTag'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Require CreatedBy Tag on Resource Groups'
param policyDescription string = 'Ensures resource groups have the CreatedBy tag for SFI compliance.'
param requiredTags array = [ 'CreatedBy' ]

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
    parameters: {
      requiredTags: {
        type: 'Array'
        metadata: {
          displayName: 'Required Tags'
          description: 'Tags that must be present on resource groups.'
        }
        defaultValue: requiredTags
      }
    }
    policyRule: {
      if: {
        not: {
          field: 'tags'
          contains: requiredTags
        }
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
