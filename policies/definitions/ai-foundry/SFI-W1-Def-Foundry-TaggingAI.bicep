// Policy Definition: SFI-W1-Def-Foundry-TaggingAI
@description('Require tags such as ModelOwner, DataClassification, and ComplianceLevel on all AI resources.')
param policyName string = 'SFI-W1-Def-Foundry-TaggingAI'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Resource Tagging for AI Workloads'
param policyDescription string = 'Require tags such as ModelOwner, DataClassification, and ComplianceLevel on all AI resources.'
param requiredTags array = [ 'ModelOwner', 'DataClassification', 'ComplianceLevel' ]

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
          description: 'Tags that must be present on AI resources.'
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
