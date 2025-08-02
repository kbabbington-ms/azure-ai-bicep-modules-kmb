// Policy Definition: SFI-W1-Def-Foundry-AllowedAISku
@description('Restrict deployment to approved SKUs for Azure AI services.')
param policyName string = 'SFI-W1-Def-Foundry-AllowedAISku'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Allowed AI Service SKUs'
param policyDescription string = 'Restrict deployment to approved SKUs for Azure AI services.'
param allowedSkus array = [ 'Standard', 'Enterprise' ]

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
      allowedSkus: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed SKUs'
          description: 'SKUs that are allowed for AI services.'
        }
        defaultValue: allowedSkus
      }
    }
    policyRule: {
      if: {
        field: 'sku.name'
        notIn: allowedSkus
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
