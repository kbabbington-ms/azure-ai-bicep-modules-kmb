@description('Azure Bastion for secure administrative access')
param location string = resourceGroup().location
param environment string
param projectName string
param bastionSubnetId string

// Public IP for Azure Bastion
resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: 'pip-bastion-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Public IP for Azure Bastion'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: 'bastion-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
    }
  }
}

// Azure Bastion Host
resource bastionHost 'Microsoft.Network/bastionHosts@2023-11-01' = {
  name: 'bastion-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Secure administrative access to AI Enclave'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    enableTunneling: true
    enableIpConnect: true
    enableShareableLink: false
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnetId
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]
  }
}

// Outputs
output bastionResourceId string = bastionHost.id
output bastionFqdn string = bastionPublicIp.properties.dnsSettings.fqdn
output bastionPublicIpId string = bastionPublicIp.id
