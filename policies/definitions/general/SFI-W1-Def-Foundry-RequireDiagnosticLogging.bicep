// Policy Definition: SFI-W1-Def-Foundry-RequireDiagnosticLogging (SFI Compliance)
@description('Ensures diagnostic logging is enabled for all supported resources.')
param policyName string = 'SFI-W1-Def-Foundry-RequireDiagnosticLogging'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Require Diagnostic Logging'
param policyDescription string = 'Ensures diagnostic logging is enabled for all supported resources.'

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
        field: 'Microsoft.Insights/diagnosticSettings.enabled'
        equals: false
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
