// SFI Initiative: Compute Security Controls
@description('SFI-W1 Initiative for Compute security compliance including secure boot, trusted launch, and hardware security.')
param initiativeName string = 'SFI-W1-Initiative-Compute'
param initiativeDisplayName string = 'SFI-W1: Compute Security Controls'
param initiativeDescription string = 'Comprehensive security controls for compute resources including virtual machines and VMSS to ensure hardware-level security and trusted launch compliance with Microsoft Secure Future Initiative (SFI-W1).'

targetScope = 'subscription'

// Policy Definitions to include
var policyDefinitions = [
  {
    policyDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-Compute-RequireSecureBoot'
    parameters: {}
  }
]

resource sfiComputeInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'Compute'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
      sfiCompliance: 'W1'
    }
    policyDefinitions: policyDefinitions
  }
}

output initiativeId string = sfiComputeInitiative.id
output initiativeName string = sfiComputeInitiative.name
