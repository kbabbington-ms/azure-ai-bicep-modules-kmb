// SFI-W1 Content Safety Policy Definition
// NOTE: Deploy this policy definition at the subscription, management group, or tenant scope.
param policyName string = 'Enforce Content Safety Security'

resource contentSafetyPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: 'Enforce Content Safety Security'
    description: 'Requires diagnostic logging, managed identity, and network restrictions for Content Safety accounts.'
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.ContentSafety/accounts'
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
