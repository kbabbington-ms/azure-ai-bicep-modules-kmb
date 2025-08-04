// SFI Initiative: Virtual Network Security Controls
@description('SFI-W1 Initiative for Virtual Network security compliance including private subnets, NSG flow logs, and network isolation.')
param initiativeName string = 'SFI-W1-Initiative-VirtualNetwork'
param initiativeDisplayName string = 'SFI-W1: Virtual Network Security Controls'
param initiativeDescription string = 'Comprehensive security controls for virtual networks to ensure zero-trust architecture and network monitoring compliance with Microsoft Secure Future Initiative (SFI-W1).'

targetScope = 'subscription'

// Policy Definitions to include
var policyDefinitions = [
  {
    policyDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-VNet-RequirePrivateSubnets'
    parameters: {}
  }
  {
    policyDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-VNet-RequireNSGFlowLogs'
    parameters: {
      storageAccountResourceId: {
        value: '[parameters(\'storageAccountResourceId\')]'
      }
    }
  }
]

resource sfiVirtualNetworkInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'Network'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
      sfiCompliance: 'W1'
    }
    parameters: {
      storageAccountResourceId: {
        type: 'String'
        metadata: {
          displayName: 'Storage Account Resource ID for NSG Flow Logs'
          description: 'Resource ID of storage account for NSG flow logs'
        }
      }
    }
    policyDefinitions: policyDefinitions
  }
}

output initiativeId string = sfiVirtualNetworkInitiative.id
output initiativeName string = sfiVirtualNetworkInitiative.name
