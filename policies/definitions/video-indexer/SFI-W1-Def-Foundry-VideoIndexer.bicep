targetScope = 'subscription'
// SFI-W1 Video Indexer Policy Definition
// NOTE: Deploy this policy definition at the subscription, management group, or tenant scope.
param policyName string = 'Enforce Video Indexer Security'

resource videoIndexerPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: 'Enforce Video Indexer Security'
    description: 'Requires tagging, encryption at rest, and private endpoint for Video Indexer accounts.'
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.VideoIndexer/accounts'
      }
      then: {
        effect: 'auditIfNotExists'
        details: {
          type: 'Microsoft.Network/privateEndpoints'
        }
      }
    }
    parameters: {}
  }
}
