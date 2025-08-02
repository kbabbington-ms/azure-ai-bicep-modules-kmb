// Policy Definition: SFI-W1-Def-Foundry-DataResidency
@description('Require all AI resources and data storage to be deployed in approved regions.')
param policyName string = 'SFI-W1-Def-Foundry-DataResidency'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Data Residency Enforcement'
param policyDescription string = 'Require all AI resources and data storage to be deployed in approved regions.'
param allowedLocations array = [ 'eastus', 'westeurope' ]

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
      allowedLocations: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed Locations'
          description: 'Locations that are allowed for AI resources and data storage.'
        }
        defaultValue: allowedLocations
      }
    }
    policyRule: {
      if: {
        field: 'location'
        notIn: allowedLocations
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
