@description('VPN Gateway for hybrid connectivity to AI Enclave')
param location string = resourceGroup().location
param environment string
param projectName string
param gatewaySubnetId string
param logAnalyticsWorkspaceId string = ''
param vpnType string = 'RouteBased'
param gatewayType string = 'Vpn'
param gatewaySku string = 'VpnGw2AZ' // Zone-redundant SKU
param enableBgp bool = true
param onPremisesGatewayIp string = ''
param onPremisesAddressSpace array = []
param sharedKey string = ''

// Public IP for VPN Gateway (Active-Active requires 2 IPs)
resource vpnGatewayPublicIp1 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: 'pip-vpn-gw-1-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'VPN Gateway Public IP 1'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: 'vpn-gw-1-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
    }
  }
  zones: ['1', '2', '3']
}

resource vpnGatewayPublicIp2 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: 'pip-vpn-gw-2-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'VPN Gateway Public IP 2'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: 'vpn-gw-2-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
    }
  }
  zones: ['1', '2', '3']
}

// VPN Gateway (Active-Active for high availability)
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2023-11-01' = {
  name: 'vgw-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Site-to-site VPN for hybrid connectivity'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gatewaySubnetId
          }
          publicIPAddress: {
            id: vpnGatewayPublicIp1.id
          }
        }
      }
      {
        name: 'vnetGatewayConfig2'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gatewaySubnetId
          }
          publicIPAddress: {
            id: vpnGatewayPublicIp2.id
          }
        }
      }
    ]
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    gatewayType: gatewayType
    vpnType: vpnType
    enableBgp: enableBgp
    activeActive: true
    bgpSettings: enableBgp ? {
      asn: 65515
      bgpPeeringAddress: ''
      peerWeight: 0
    } : null
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: ['172.16.0.0/24'] // Point-to-site client pool
      }
      vpnClientProtocols: ['OpenVPN', 'IkeV2']
      vpnAuthenticationTypes: ['AAD'] // Azure AD authentication
      aadTenant: '${az.environment().authentication.loginEndpoint}${tenant().tenantId}/'
      aadAudience: '41b23e61-6c1e-4545-b367-cd054e0ed4b4' // Azure VPN Client ID
      aadIssuer: '${az.environment().authentication.loginEndpoint}${tenant().tenantId}/'
    }
  }
}

// Local Network Gateway for on-premises connectivity
resource localNetworkGateway 'Microsoft.Network/localNetworkGateways@2023-11-01' = if (!empty(onPremisesGatewayIp) && !empty(onPremisesAddressSpace)) {
  name: 'lgw-onprem-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'On-premises network gateway'
  }
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: onPremisesAddressSpace
    }
    gatewayIpAddress: onPremisesGatewayIp
    bgpSettings: enableBgp ? {
      asn: 65001 // On-premises ASN
      bgpPeeringAddress: onPremisesGatewayIp
      peerWeight: 0
    } : null
  }
}

// VPN Connection to on-premises
resource vpnConnection 'Microsoft.Network/connections@2023-11-01' = if (!empty(onPremisesGatewayIp) && !empty(sharedKey)) {
  name: 'cn-onprem-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Site-to-site VPN connection'
  }
  properties: {
    virtualNetworkGateway1: {
      id: vpnGateway.id
      properties: {}
    }
    localNetworkGateway2: {
      id: localNetworkGateway!.id
      properties: {}
    }
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    routingWeight: 10
    sharedKey: sharedKey
    enableBgp: enableBgp
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
    ipsecPolicies: [
      {
        saLifeTimeSeconds: 14400
        saDataSizeKilobytes: 102400000
        ipsecEncryption: 'AES256'
        ipsecIntegrity: 'SHA256'
        ikeEncryption: 'AES256'
        ikeIntegrity: 'SHA384'
        dhGroup: 'DHGroup24'
        pfsGroup: 'PFS24'
      }
    ]
  }
}

// Diagnostic settings for VPN Gateway
resource vpnGatewayDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'diag-vpn-gateway-${projectName}-${environment}'
  scope: vpnGateway
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

// Outputs
output vpnGatewayId string = vpnGateway.id
output vpnGatewayName string = vpnGateway.name
output vpnGatewayPublicIp1 string = vpnGatewayPublicIp1.properties.ipAddress
output vpnGatewayPublicIp2 string = vpnGatewayPublicIp2.properties.ipAddress
output localNetworkGatewayId string = !empty(onPremisesGatewayIp) ? localNetworkGateway!.id : ''
output vpnConnectionId string = !empty(onPremisesGatewayIp) && !empty(sharedKey) ? vpnConnection!.id : ''
