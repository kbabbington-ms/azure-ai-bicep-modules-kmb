// Policy Definition: SFI-W1-Def-Foundry-RestrictPublicNetworkAccess (SFI Compliance)
@description('Ensures resources do not allow public network access, supporting SFI compliance.')
param policyName string = 'SFI-W1-Def-Foundry-RestrictPublicNetworkAccess'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Restrict Public Network Access'
param policyDescription string = 'Ensures resources do not allow public network access, supporting SFI compliance.'

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
        field: 'Microsoft.Network/publicIpAddresses.ipAddress'
        exists: true
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
