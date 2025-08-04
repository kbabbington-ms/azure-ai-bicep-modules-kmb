@description('Spoke Virtual Network for AI Enclave')
param location string = resourceGroup().location
param environment string
param projectName string
param vnetName string
param spokeName string
param addressPrefix string
param hubVNetId string
param hubVNetName string
param subnets array

// Spoke Virtual Network
resource spokeVNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    VNetType: 'Spoke'
    SpokeName: spokeName
    Purpose: 'Spoke network for ${spokeName} workloads'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        serviceEndpoints: subnet.serviceEndpoints
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: 'Enabled'
        delegations: subnet.delegation != null ? [
          {
            name: 'delegation'
            properties: {
              serviceName: subnet.delegation
            }
          }
        ] : []
      }
    }]
  }
}

// Network Security Group for the spoke
resource spokeNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-${spokeName}-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    SpokeName: spokeName
    Purpose: 'NSG for ${spokeName} spoke'
  }
  properties: {
    securityRules: spokeName == 'ai-services' ? [
      {
        name: 'AllowHTTPSInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowVNetOutbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyInternetOutbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Deny'
          priority: 200
          direction: 'Outbound'
        }
      }
    ] : spokeName == 'compute' ? [
      {
        name: 'AllowHTTPInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443']
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowKubernetesAPI'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowVNetOutbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowHTTPSOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
    ] : [
      {
        name: 'AllowHTTPSInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowVNetOutbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
    ]
  }
}

// Associate NSG with all subnets (except delegated ones)
resource subnetNsgAssociation 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = [for (subnet, i) in subnets: if (subnet.delegation == null) {
  parent: spokeVNet
  name: subnet.name
  properties: {
    addressPrefix: subnet.addressPrefix
    serviceEndpoints: [for endpoint in subnet.serviceEndpoints: {
      service: endpoint
    }]
    networkSecurityGroup: {
      id: spokeNsg.id
    }
    privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}]

// VNet Peering from Spoke to Hub
resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  parent: spokeVNet
  name: 'peer-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hubVNetId
    }
  }
}

// VNet Peering from Hub to Spoke
resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  name: '${hubVNetName}/peer-to-${spokeName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVNet.id
    }
  }
}

// Route Table for spoke traffic routing
resource spokeRouteTable 'Microsoft.Network/routeTables@2023-11-01' = {
  name: 'rt-${spokeName}-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    SpokeName: spokeName
    Purpose: 'Route table for ${spokeName} spoke'
  }
  properties: {
    routes: [
      {
        name: 'RouteToInternet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.2.4' // Azure Firewall IP
        }
      }
      {
        name: 'RouteToHub'
        properties: {
          addressPrefix: '10.0.0.0/16'
          nextHopType: 'VNetLocal'
        }
      }
    ]
  }
}

// Outputs
output vnetId string = spokeVNet.id
output vnetName string = spokeVNet.name
output nsgId string = spokeNsg.id
output routeTableId string = spokeRouteTable.id
output subnetIds array = [for (subnet, i) in subnets: resourceId('Microsoft.Network/virtualNetworks/subnets', spokeVNet.name, subnet.name)]
output peeringId string = spokeToHubPeering.id
