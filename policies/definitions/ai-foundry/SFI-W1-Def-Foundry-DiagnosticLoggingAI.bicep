// Policy Definition: SFI-W1-Def-Foundry-DiagnosticLoggingAI
@description('Ensure diagnostic logging is enabled for all Azure AI resources.')
param policyName string = 'SFI-W1-Def-Foundry-DiagnosticLoggingAI'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Mandatory Diagnostic Logging for AI Services'
param policyDescription string = 'Ensure diagnostic logging is enabled for all Azure AI resources.'

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
        field: 'Microsoft.CognitiveServices/accounts/diagnosticSettings.enabled'
        equals: false
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
