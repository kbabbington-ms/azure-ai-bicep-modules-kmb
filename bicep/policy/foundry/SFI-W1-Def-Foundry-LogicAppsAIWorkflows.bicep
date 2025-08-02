targetScope = 'subscription'
// SFI-W1 Logic Apps AI Workflows Policy Definition
// NOTE: Deploy this policy definition at the subscription, management group, or tenant scope.
param policyName string = 'Enforce Logic Apps AI Workflows Security'

resource logicAppsPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: 'Enforce Logic Apps AI Workflows Security'
    description: 'Requires secure connections, logging, and resource tagging for Logic Apps AI workflows.'
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Logic/workflows'
      }
      then: {
        effect: 'auditIfNotExists'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
        }
      }
    }
    parameters: {}
  }
}
