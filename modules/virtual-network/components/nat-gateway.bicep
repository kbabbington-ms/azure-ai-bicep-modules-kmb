@description('NAT Gateway for secure outbound internet access')
param location string = resourceGroup().location
param environment string
param projectName string

// Public IP for NAT Gateway
resource natGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: 'pip-natgw-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Public IP for NAT Gateway'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}

// NAT Gateway
resource natGateway 'Microsoft.Network/natGateways@2023-11-01' = {
  name: 'natgw-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Secure outbound internet access for AI Enclave'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natGatewayPublicIp.id
      }
    ]
  }
}

// Outputs
output natGatewayId string = natGateway.id
output natGatewayPublicIpId string = natGatewayPublicIp.id
output natGatewayPublicIp string = natGatewayPublicIp.properties.ipAddress
