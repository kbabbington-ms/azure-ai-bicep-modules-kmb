// Policy Definition: SFI-W1-Def-Foundry-ModelVersionControl
@description('Enforce use of approved model versions for AI workloads.')
param policyName string = 'SFI-W1-Def-Foundry-ModelVersionControl'
param policyDisplayName string = 'SFI-W1-Def-Foundry: AI Model Version Control'
param policyDescription string = 'Enforce use of approved model versions for AI workloads.'
param allowedModelVersions array = [ '1.0', '2.0' ]

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
      allowedModelVersions: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed Model Versions'
          description: 'Model versions that are allowed for AI workloads.'
        }
        defaultValue: allowedModelVersions
      }
    }
    policyRule: {
      if: {
        field: 'properties.model.version'
        notIn: allowedModelVersions
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
