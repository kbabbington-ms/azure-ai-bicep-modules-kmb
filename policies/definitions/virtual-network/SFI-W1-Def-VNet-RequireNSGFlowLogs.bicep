// Policy Definition: SFI-W1-Def-VNet-RequireNSGFlowLogs
@description('Require NSG flow logs enabled for network security monitoring and SFI-W1 compliance.')
param policyName string = 'SFI-W1-Def-VNet-RequireNSGFlowLogs'
param policyDisplayName string = 'SFI-W1-Def-VNet: Require NSG Flow Logs'
param policyDescription string = 'Enforce NSG flow logs to be enabled for all network security groups to provide comprehensive network monitoring for SFI-W1 compliance.'

targetScope = 'subscription'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
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
          displayName: 'Storage Account Resource ID'
          description: 'Resource ID of storage account for NSG flow logs'
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Network/networkSecurityGroups'
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Network/networkWatchers/flowLogs'
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Network/networkWatchers/flowLogs/enabled'
                equals: true
              }
              {
                field: 'Microsoft.Network/networkWatchers/flowLogs/targetResourceId'
                equals: '[field(\'id\')]'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  networkSecurityGroupId: {
                    type: 'string'
                  }
                  storageAccountResourceId: {
                    type: 'string'
                  }
                }
                variables: {
                  flowLogName: '[concat(\'flowLog-\', last(split(parameters(\'networkSecurityGroupId\'), \'/\')))]'
                }
                resources: [
                  {
                    type: 'Microsoft.Network/networkWatchers/flowLogs'
                    apiVersion: '2021-03-01'
                    name: '[concat(\'NetworkWatcher_\', resourceGroup().location, \'/\', variables(\'flowLogName\'))]'
                    properties: {
                      targetResourceId: '[parameters(\'networkSecurityGroupId\')]'
                      storageId: '[parameters(\'storageAccountResourceId\')]'
                      enabled: true
                      retentionPolicy: {
                        days: 90
                        enabled: true
                      }
                      format: {
                        type: 'JSON'
                        version: 2
                      }
                    }
                  }
                ]
              }
              parameters: {
                networkSecurityGroupId: {
                  value: '[field(\'id\')]'
                }
                storageAccountResourceId: {
                  value: '[parameters(\'storageAccountResourceId\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

output policyDefinitionId string = policyDefinition.id
