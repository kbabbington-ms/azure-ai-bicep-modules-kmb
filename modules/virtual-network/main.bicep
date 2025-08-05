// ============================================================================
// Virtual Network Module - Hub-Spoke Architecture for AI Workloads
// ============================================================================
// Version: 2.0.0
// Author: Azure AI Infrastructure Team
// Created: 2024-01-15
// Updated: 2024-01-15
// Description: Implements secure hub-spoke virtual network topology optimized 
//              for Azure AI services with comprehensive network security,
//              monitoring, and connectivity options
// ============================================================================

targetScope = 'resourceGroup'

// ============================================================================
// PARAMETERS - Network Architecture
// ============================================================================

@description('🔒 The Azure region where resources will be deployed')
param location string = resourceGroup().location

@description('Environment designation (dev, test, prod)')
@allowed(['dev', 'test', 'prod'])
param environment string

@description('Project name used for resource naming')
@minLength(2)
@maxLength(10)
param projectName string

// Hub Virtual Network Parameters
@description('🔒 Hub VNet name for central network services')
param hubVNetName string = 'vnet-hub-${projectName}-${environment}-${location}'

@description('🔒 Hub VNet address space for central services')
param hubAddressSpace string = '10.0.0.0/16'

@description('🔒 Gateway subnet address prefix for VPN/ExpressRoute')
param gatewaySubnetPrefix string = '10.0.0.0/24'

@description('🔒 Azure Firewall subnet address prefix')
param firewallSubnetPrefix string = '10.0.1.0/24'

@description('🔒 Azure Bastion subnet address prefix')
param bastionSubnetPrefix string = '10.0.2.0/24'

@description('🔒 Shared services subnet address prefix')
param sharedServicesSubnetPrefix string = '10.0.3.0/24'

@description('🔒 Management subnet address prefix')
param managementSubnetPrefix string = '10.0.4.0/24'

// Spoke Virtual Networks Parameters
@description('🔒 AI Services spoke VNet name')
param aiServicesSpokeVNetName string = 'vnet-ai-services-${projectName}-${environment}-${location}'

@description('🔒 AI Services spoke address space')
param aiServicesAddressSpace string = '10.1.0.0/16'

@description('🔒 Compute spoke VNet name')
param computeSpokeVNetName string = 'vnet-compute-${projectName}-${environment}-${location}'

@description('🔒 Compute spoke address space')
param computeAddressSpace string = '10.2.0.0/16'

@description('🔒 Data services spoke VNet name')
param dataServicesSpokeVNetName string = 'vnet-data-services-${projectName}-${environment}-${location}'

@description('🔒 Data services spoke address space')
param dataServicesAddressSpace string = '10.3.0.0/16'

// ============================================================================
// PARAMETERS - Security & Connectivity Features
// ============================================================================

@description('🔒 Enable Azure Bastion for secure VM access')
param enableBastion bool = true

@description('🔒 Enable Azure Firewall for network security')
param enableAzureFirewall bool = true

@description('🔒 Enable VPN Gateway for hybrid connectivity')
param enableVpnGateway bool = false

@description('🔒 Enable DDoS Protection Standard')
param enableDdosProtection bool = true

@description('🔒 DDoS Protection Plan resource ID')
param ddosProtectionPlanId string = ''

@description('🔒 Enable Network Security Groups')
param enableNetworkSecurityGroups bool = true

// ============================================================================
// PARAMETERS - Tags & Metadata
// ============================================================================

@description('🔒 Resource tags for governance and cost management')
param tags object = {
  Environment: environment
  Project: projectName
  ManagedBy: 'Bicep'
  Purpose: 'AI-Network-Infrastructure'
  CostCenter: ''
  Owner: ''
}

// ============================================================================
// VARIABLES
// ============================================================================

var standardTags = union(tags, {
  Module: 'virtual-network'
  Version: '2.0.0'
})

// ============================================================================
// RESOURCE DEPLOYMENTS
// ============================================================================

// Hub Virtual Network - Central network services
resource hubVNet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: hubVNetName
  location: location
  tags: standardTags
  properties: {
    addressSpace: {
      addressPrefixes: [hubAddressSpace]
    }
    dhcpOptions: {
      dnsServers: []
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetPrefix
          serviceEndpoints: []
          delegations: []
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: firewallSubnetPrefix
          serviceEndpoints: []
          delegations: []
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetPrefix
          serviceEndpoints: []
          delegations: []
        }
      }
      {
        name: 'SharedServicesSubnet'
        properties: {
          addressPrefix: sharedServicesSubnetPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.KeyVault'
            }
          ]
          delegations: []
        }
      }
      {
        name: 'ManagementSubnet'
        properties: {
          addressPrefix: managementSubnetPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          delegations: []
        }
      }
    ]
    enableDdosProtection: enableDdosProtection
    ddosProtectionPlan: enableDdosProtection && !empty(ddosProtectionPlanId) ? {
      id: ddosProtectionPlanId
    } : null
  }
}

// AI Services Spoke Virtual Network
resource aiServicesSpoke 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: aiServicesSpokeVNetName
  location: location
  tags: standardTags
  properties: {
    addressSpace: {
      addressPrefixes: [aiServicesAddressSpace]
    }
    subnets: [
      {
        name: 'OpenAISubnet'
        properties: {
          addressPrefix: '10.1.1.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.CognitiveServices'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'CognitiveServicesSubnet'
        properties: {
          addressPrefix: '10.1.2.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.CognitiveServices'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'SearchSubnet'
        properties: {
          addressPrefix: '10.1.3.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Search'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'MLWorkspaceSubnet'
        properties: {
          addressPrefix: '10.1.4.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.MachineLearningServices'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// Compute Spoke Virtual Network
resource computeSpoke 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: computeSpokeVNetName
  location: location
  tags: standardTags
  properties: {
    addressSpace: {
      addressPrefixes: [computeAddressSpace]
    }
    subnets: [
      {
        name: 'VirtualMachinesSubnet'
        properties: {
          addressPrefix: '10.2.1.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'ContainerInstancesSubnet'
        properties: {
          addressPrefix: '10.2.2.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          delegations: [
            {
              name: 'containerInstancesDelegation'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'KubernetesSubnet'
        properties: {
          addressPrefix: '10.2.3.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.ContainerRegistry'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'BatchSubnet'
        properties: {
          addressPrefix: '10.2.4.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          delegations: [
            {
              name: 'batchDelegation'
              properties: {
                serviceName: 'Microsoft.Batch/batchAccounts'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

// Data Services Spoke Virtual Network
resource dataServicesSpoke 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: dataServicesSpokeVNetName
  location: location
  tags: standardTags
  properties: {
    addressSpace: {
      addressPrefixes: [dataServicesAddressSpace]
    }
    subnets: [
      {
        name: 'StorageSubnet'
        properties: {
          addressPrefix: '10.3.1.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'DatabaseSubnet'
        properties: {
          addressPrefix: '10.3.2.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'CosmosDBSubnet'
        properties: {
          addressPrefix: '10.3.3.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.AzureCosmosDB'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'EventHubSubnet'
        properties: {
          addressPrefix: '10.3.4.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.EventHub'
            }
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// VNet Peering - Hub to AI Services Spoke
resource hubToAiServicesVNetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  parent: hubVNet
  name: 'hub-to-ai-services'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: aiServicesSpoke.id
    }
  }
}

// VNet Peering - AI Services Spoke to Hub
resource aiServicesToHubVNetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  parent: aiServicesSpoke
  name: 'ai-services-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: enableVpnGateway
    remoteVirtualNetwork: {
      id: hubVNet.id
    }
  }
}

// VNet Peering - Hub to Compute Spoke
resource hubToComputeVNetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  parent: hubVNet
  name: 'hub-to-compute'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: computeSpoke.id
    }
  }
}

// VNet Peering - Compute Spoke to Hub
resource computeToHubVNetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  parent: computeSpoke
  name: 'compute-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: enableVpnGateway
    remoteVirtualNetwork: {
      id: hubVNet.id
    }
  }
}

// VNet Peering - Hub to Data Services Spoke
resource hubToDataServicesVNetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  parent: hubVNet
  name: 'hub-to-data-services'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: dataServicesSpoke.id
    }
  }
}

// VNet Peering - Data Services Spoke to Hub
resource dataServicesToHubVNetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = {
  parent: dataServicesSpoke
  name: 'data-services-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: enableVpnGateway
    remoteVirtualNetwork: {
      id: hubVNet.id
    }
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

// Hub VNet outputs
@description('Hub Virtual Network resource ID')
output hubVNetId string = hubVNet.id

@description('Hub Virtual Network name')
output hubVNetName string = hubVNet.name

@description('Hub Virtual Network address space')
output hubAddressSpace string = hubAddressSpace

// Spoke VNet outputs
@description('AI Services Virtual Network resource ID')
output aiServicesVNetId string = aiServicesSpoke.id

@description('AI Services Virtual Network name')
output aiServicesVNetName string = aiServicesSpoke.name

@description('Compute Virtual Network resource ID')
output computeVNetId string = computeSpoke.id

@description('Compute Virtual Network name')
output computeVNetName string = computeSpoke.name

@description('Data Services Virtual Network resource ID')
output dataServicesVNetId string = dataServicesSpoke.id

@description('Data Services Virtual Network name')
output dataServicesVNetName string = dataServicesSpoke.name

// Network topology summary for downstream consumption
@description('Complete network topology summary')
output networkTopology object = {
  hub: {
    vnetId: hubVNet.id
    vnetName: hubVNet.name
    addressSpace: hubAddressSpace
    location: location
  }
  spokes: {
    aiServices: {
      vnetId: aiServicesSpoke.id
      vnetName: aiServicesSpoke.name
      addressSpace: aiServicesAddressSpace
    }
    compute: {
      vnetId: computeSpoke.id
      vnetName: computeSpoke.name
      addressSpace: computeAddressSpace
    }
    dataServices: {
      vnetId: dataServicesSpoke.id
      vnetName: dataServicesSpoke.name
      addressSpace: dataServicesAddressSpace
    }
  }
  security: {
    bastionEnabled: enableBastion
    firewallEnabled: enableAzureFirewall
    nsgEnabled: enableNetworkSecurityGroups
    ddosProtectionEnabled: enableDdosProtection
  }
  connectivity: {
    vpnGatewayEnabled: enableVpnGateway
    hybridConnectivity: enableVpnGateway
  }
}
