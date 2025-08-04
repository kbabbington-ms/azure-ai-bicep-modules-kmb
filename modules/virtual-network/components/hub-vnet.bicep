@description('Hub Virtual Network for AI Enclave')
param location string = resourceGroup().location
param environment string
param projectName string
param vnetName string
param addressPrefix string
param enableDdosProtection bool = true
param subnets array

// DDoS Protection Plan (if enabled)
resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2023-11-01' = if (enableDdosProtection) {
  name: 'ddos-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'DDoS Protection for AI Enclave Hub'
  }
}

// Hub Virtual Network
resource hubVNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    VNetType: 'Hub'
    Purpose: 'Hub network for AI Enclave'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    ddosProtectionPlan: enableDdosProtection ? {
      id: ddosProtectionPlan.id
    } : null
    enableDdosProtection: enableDdosProtection
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

// Network Security Group for Shared Services
resource sharedServicesNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-shared-services-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'NSG for shared services subnet'
  }
  properties: {
    securityRules: [
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
        name: 'AllowDNSInbound'
        properties: {
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '53'
          sourceAddressPrefix: 'VirtualNetwork'
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
    ]
  }
}

// Associate NSG with Shared Services subnet
resource sharedServicesSubnetNsgAssociation 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  parent: hubVNet
  name: 'SharedServicesSubnet'
  properties: {
    addressPrefix: '10.0.4.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.KeyVault'
      }
      {
        service: 'Microsoft.Storage'
      }
    ]
    networkSecurityGroup: {
      id: sharedServicesNsg.id
    }
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

// Outputs
output vnetId string = hubVNet.id
output vnetName string = hubVNet.name
output bastionSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVNet.name, 'AzureBastionSubnet')
output firewallSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVNet.name, 'AzureFirewallSubnet')
output gatewaySubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVNet.name, 'GatewaySubnet')
output sharedServicesSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', hubVNet.name, 'SharedServicesSubnet')
output nsgId string = sharedServicesNsg.id
output ddosProtectionPlanId string = enableDdosProtection ? ddosProtectionPlan.id : ''
output subnetIds array = [for (subnet, i) in subnets: resourceId('Microsoft.Network/virtualNetworks/subnets', hubVNet.name, subnet.name)]
