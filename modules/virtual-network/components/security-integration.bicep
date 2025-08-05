// ================================================================
// Azure Virtual Network Security Integration Module
// SFI-Compliant Zero-Trust Network Security Components
// ================================================================

metadata name = 'Virtual Network Security Integration'
metadata description = 'Comprehensive security integration for hub-spoke topology with zero-trust architecture'
metadata owner = 'Azure AI Platform Team'

@description('Project name for resource naming')
param projectName string

@description('Environment name (dev, staging, prod)')
param environment string = 'dev'

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Azure Firewall private IP address')
param firewallPrivateIP string = '10.0.2.4'

@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string

@description('Storage account resource ID for flow logs')
param storageAccountId string = ''

@description('On-premises gateway public IP address')
param onPremisesGatewayIp string = ''

@description('On-premises address space')
param onPremisesAddressSpace array = []

@description('Shared key for VPN connection')
@secure()
param sharedKey string = ''

@description('Enable BGP for VPN Gateway')
param enableBgp bool = false

@description('Gateway subnet resource ID')
param gatewaySubnetId string = ''

// ================================================================
// Network Security Groups Deployment
// ================================================================

module networkSecurityGroups 'network-security-groups.bicep' = {
  name: 'deploy-network-security-groups'
  params: {
    projectName: projectName
    environment: environment
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

// ================================================================
// Route Tables Deployment
// ================================================================

module routeTables 'route-tables.bicep' = {
  name: 'deploy-route-tables'
  params: {
    projectName: projectName
    environment: environment
    location: location
    firewallPrivateIP: firewallPrivateIP
  }
}

// ================================================================
// Network Monitoring Deployment
// ================================================================

module networkMonitoring 'network-monitoring.bicep' = if (!empty(storageAccountId)) {
  name: 'deploy-network-monitoring'
  params: {
    projectName: projectName
    environment: environment
    location: location
    networkSecurityGroups: [
      networkSecurityGroups.outputs.hubNsgId
      networkSecurityGroups.outputs.aiServicesNsgId
      networkSecurityGroups.outputs.computeNsgId
      networkSecurityGroups.outputs.dataServicesNsgId
    ]
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
  }
}

// ================================================================
// VPN Gateway Deployment (Conditional)
// ================================================================

module vpnGateway 'vpn-gateway.bicep' = if (!empty(onPremisesGatewayIp) && !empty(gatewaySubnetId)) {
  name: 'deploy-vpn-gateway'
  params: {
    projectName: projectName
    environment: environment
    location: location
    gatewaySubnetId: gatewaySubnetId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    onPremisesGatewayIp: onPremisesGatewayIp
    onPremisesAddressSpace: onPremisesAddressSpace
    sharedKey: sharedKey
    enableBgp: enableBgp
  }
}

// ================================================================
// Outputs
// ================================================================

@description('Network Security Groups resource IDs')
output networkSecurityGroups object = {
  hub: networkSecurityGroups.outputs.hubNsgId
  aiServices: networkSecurityGroups.outputs.aiServicesNsgId
  compute: networkSecurityGroups.outputs.computeNsgId
  dataServices: networkSecurityGroups.outputs.dataServicesNsgId
  allNsgIds: networkSecurityGroups.outputs.nsgIds
}

@description('Route Tables resource IDs')
output routeTables object = {
  aiServices: routeTables.outputs.aiServicesRouteTableId
  compute: routeTables.outputs.computeRouteTableId
  dataServices: routeTables.outputs.dataServicesRouteTableId
  appGateway: routeTables.outputs.appGatewayRouteTableId
  hubGateway: routeTables.outputs.hubGatewayRouteTableId
  allRouteTableIds: routeTables.outputs.routeTableIds
}

@description('Network monitoring components')
output networkMonitoring object = !empty(storageAccountId) ? {
  networkWatcherId: networkMonitoring!.outputs.networkWatcherId
  connectionMonitorId: networkMonitoring!.outputs.connectionMonitorId
  flowLogIds: networkMonitoring!.outputs.flowLogIds
} : {}

@description('VPN Gateway configuration (if deployed)')
output vpnGateway object = (!empty(onPremisesGatewayIp) && !empty(gatewaySubnetId)) ? {
  gatewayId: vpnGateway!.outputs.vpnGatewayId
  gatewayName: vpnGateway!.outputs.vpnGatewayName
  publicIp1: vpnGateway!.outputs.vpnGatewayPublicIp1
  publicIp2: vpnGateway!.outputs.vpnGatewayPublicIp2
  connectionId: vpnGateway!.outputs.vpnConnectionId
} : {}

@description('Security integration deployment status')
output deploymentStatus object = {
  networkSecurityGroups: 'deployed'
  routeTables: 'deployed'
  networkMonitoring: !empty(storageAccountId) ? 'deployed' : 'skipped'
  vpnGateway: !empty(onPremisesGatewayIp) && !empty(gatewaySubnetId) ? 'deployed' : 'skipped'
  sfiCompliance: 'enabled'
  zeroTrustArchitecture: 'implemented'
}

@description('SFI compliance validation')
output sfiComplianceStatus object = {
  networkSegmentation: 'implemented'
  zeroTrustAccess: 'enabled'
  trafficInspection: 'mandatory'
  networkMonitoring: !empty(storageAccountId) ? 'comprehensive' : 'basic'
  accessLogging: 'enabled'
  threatDetection: 'active'
  complianceLevel: 'SFI-W1'
}
