targetScope = 'subscription'
// SFI-W1 Advanced Monitoring Policy Definition
// NOTE: Deploy this policy definition at the subscription, management group, or tenant scope.
param policyName string = 'Enforce Advanced Monitoring'

resource monitoringPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: 'Enforce Advanced Monitoring'
    description: 'Requires Log Analytics integration and diagnostic settings for all AI resources.'
    policyRule: {
      if: {
        field: 'type'
        in: ['Microsoft.VideoIndexer/accounts','Microsoft.ContentSafety/accounts','Microsoft.Logic/workflows']
      }
      then: {
        effect: 'auditIfNotExists'
        details: {
          type: 'Microsoft.OperationalInsights/workspaces'
        }
      }
    }
    parameters: {}
  }
}
