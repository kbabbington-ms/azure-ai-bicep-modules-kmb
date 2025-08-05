@description('Route Tables for AI Enclave - Force traffic through Azure Firewall')
param location string = resourceGroup().location
param environment string
param projectName string
param firewallPrivateIP string = '10.0.2.4' // Azure Firewall private IP

// Route Table for AI Services Spoke
resource aiServicesRouteTable 'Microsoft.Network/routeTables@2023-11-01' = {
  name: 'rt-ai-services-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'AI services traffic routing'
  }
  properties: {
    routes: [
      // Force internet traffic through firewall
      {
        name: 'route-internet-via-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
      // Route to compute spoke via firewall
      {
        name: 'route-compute-via-firewall'
        properties: {
          addressPrefix: '10.2.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
      // Route to data services via firewall
      {
        name: 'route-data-via-firewall'
        properties: {
          addressPrefix: '10.3.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
      // Allow local VNet traffic
      {
        name: 'route-local-vnet'
        properties: {
          addressPrefix: '10.1.0.0/16'
          nextHopType: 'VnetLocal'
        }
      }
    ]
    disableBgpRoutePropagation: false
  }
}

// Route Table for Compute Spoke
resource computeRouteTable 'Microsoft.Network/routeTables@2023-11-01' = {
  name: 'rt-compute-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Compute services traffic routing'
  }
  properties: {
    routes: [
      // Force internet traffic through firewall
      {
        name: 'route-internet-via-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
      // Route to AI services via firewall
      {
        name: 'route-ai-services-via-firewall'
        properties: {
          addressPrefix: '10.1.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
      // Route to data services via firewall
      {
        name: 'route-data-via-firewall'
        properties: {
          addressPrefix: '10.3.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
      // Allow local VNet traffic
      {
        name: 'route-local-vnet'
        properties: {
          addressPrefix: '10.2.0.0/16'
          nextHopType: 'VnetLocal'
        }
      }
    ]
    disableBgpRoutePropagation: false
  }
}

// Route Table for Data Services Spoke
resource dataServicesRouteTable 'Microsoft.Network/routeTables@2023-11-01' = {
  name: 'rt-data-services-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Data services traffic routing'
  }
  properties: {
    routes: [
      // Force internet traffic through firewall
      {
        name: 'route-internet-via-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
      // Route to AI services via firewall
      {
        name: 'route-ai-services-via-firewall'
        properties: {
          addressPrefix: '10.1.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
      // Route to compute via firewall
      {
        name: 'route-compute-via-firewall'
        properties: {
          addressPrefix: '10.2.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
      // Allow local VNet traffic
      {
        name: 'route-local-vnet'
        properties: {
          addressPrefix: '10.3.0.0/16'
          nextHopType: 'VnetLocal'
        }
      }
    ]
    disableBgpRoutePropagation: false
  }
}

// Route Table for Hub (Gateway Subnet)
resource hubGatewayRouteTable 'Microsoft.Network/routeTables@2023-11-01' = {
  name: 'rt-hub-gateway-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Hub gateway traffic routing'
  }
  properties: {
    routes: [
      // Route spoke traffic via firewall
      {
        name: 'route-spokes-via-firewall'
        properties: {
          addressPrefix: '10.0.0.0/8'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
    ]
    disableBgpRoutePropagation: true
  }
}

// Route Table for Application Gateway Subnet
resource appGatewayRouteTable 'Microsoft.Network/routeTables@2023-11-01' = {
  name: 'rt-app-gateway-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Application Gateway traffic routing'
  }
  properties: {
    routes: [
      // Route backend traffic via firewall
      {
        name: 'route-backends-via-firewall'
        properties: {
          addressPrefix: '10.2.0.0/16' // Compute spoke
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIP
        }
      }
      // Allow internet access for Application Gateway
      {
        name: 'route-internet-direct'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
        }
      }
    ]
    disableBgpRoutePropagation: false
  }
}

// Outputs
output routeTableIds object = {
  aiServices: aiServicesRouteTable.id
  compute: computeRouteTable.id
  dataServices: dataServicesRouteTable.id
  hubGateway: hubGatewayRouteTable.id
  appGateway: appGatewayRouteTable.id
}

output aiServicesRouteTableId string = aiServicesRouteTable.id
output computeRouteTableId string = computeRouteTable.id
output dataServicesRouteTableId string = dataServicesRouteTable.id
output hubGatewayRouteTableId string = hubGatewayRouteTable.id
output appGatewayRouteTableId string = appGatewayRouteTable.id
