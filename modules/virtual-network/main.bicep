@description('Virtual Network module for AI Enclave - Hub-Spoke topology with maximum security')
param location string = resourceGroup().location
param environment string = 'dev'
param projectName string = 'ai-enclave'
param enableDdosProtection bool = true
param enableBastion bool = true
param hubAddressPrefix string = '10.0.0.0/16'
param aiServicesAddressPrefix string = '10.1.0.0/16'
param computeAddressPrefix string = '10.2.0.0/16'
param dataServicesAddressPrefix string = '10.3.0.0/16'

// Resource naming
var resourceSuffix = '${projectName}-${environment}-${location}'
var hubVNetName = 'vnet-hub-${resourceSuffix}'
var aiServicesSpokeVNetName = 'vnet-ai-services-${resourceSuffix}'
var computeSpokeVNetName = 'vnet-compute-${resourceSuffix}'
var dataServicesSpokeVNetName = 'vnet-data-services-${resourceSuffix}'

// Hub VNet Configuration
module hubVNet './components/hub-vnet.bicep' = {
  name: 'hubVNet-deployment'
  params: {
    location: location
    environment: environment
    projectName: projectName
    vnetName: hubVNetName
    addressPrefix: hubAddressPrefix
    enableDdosProtection: enableDdosProtection
    subnets: [
      {
        name: 'AzureBastionSubnet'
        addressPrefix: '10.0.1.0/24'
        delegation: null
        serviceEndpoints: []
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.0.2.0/24'
        delegation: null
        serviceEndpoints: []
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'GatewaySubnet'
        addressPrefix: '10.0.3.0/24'
        delegation: null
        serviceEndpoints: []
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'SharedServicesSubnet'
        addressPrefix: '10.0.4.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.KeyVault', 'Microsoft.Storage']
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
  }
}

// AI Services Spoke VNet
module aiServicesSpoke './components/spoke-vnet.bicep' = {
  name: 'aiServicesSpoke-deployment'
  params: {
    location: location
    environment: environment
    projectName: projectName
    vnetName: aiServicesSpokeVNetName
    spokeName: 'ai-services'
    addressPrefix: aiServicesAddressPrefix
    hubVNetId: hubVNet.outputs.vnetId
    hubVNetName: hubVNetName
    subnets: [
      {
        name: 'OpenAISubnet'
        addressPrefix: '10.1.1.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.CognitiveServices']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'CognitiveServicesSubnet'
        addressPrefix: '10.1.2.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.CognitiveServices']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'MLWorkspaceSubnet'
        addressPrefix: '10.1.3.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.MachineLearningServices']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'AIFoundrySubnet'
        addressPrefix: '10.1.4.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.CognitiveServices']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'DocumentIntelSubnet'
        addressPrefix: '10.1.5.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.CognitiveServices']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'CognitiveSearchSubnet'
        addressPrefix: '10.1.6.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.Search']
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
  }
}

// Compute Spoke VNet
module computeSpoke './components/spoke-vnet.bicep' = {
  name: 'computeSpoke-deployment'
  params: {
    location: location
    environment: environment
    projectName: projectName
    vnetName: computeSpokeVNetName
    spokeName: 'compute'
    addressPrefix: computeAddressPrefix
    hubVNetId: hubVNet.outputs.vnetId
    hubVNetName: hubVNetName
    subnets: [
      {
        name: 'AKSSubnet'
        addressPrefix: '10.2.1.0/23'
        delegation: null
        serviceEndpoints: ['Microsoft.Storage', 'Microsoft.KeyVault']
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'VMSSSubnet'
        addressPrefix: '10.2.3.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.Storage']
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'ContainerAppsSubnet'
        addressPrefix: '10.2.4.0/24'
        delegation: 'Microsoft.App/environments'
        serviceEndpoints: []
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'FunctionAppsSubnet'
        addressPrefix: '10.2.5.0/24'
        delegation: 'Microsoft.Web/serverFarms'
        serviceEndpoints: ['Microsoft.Storage', 'Microsoft.KeyVault']
        privateEndpointNetworkPolicies: 'Enabled'
      }
    ]
  }
}

// Data Services Spoke VNet
module dataSpoke './components/spoke-vnet.bicep' = {
  name: 'dataSpoke-deployment'
  params: {
    location: location
    environment: environment
    projectName: projectName
    vnetName: dataServicesSpokeVNetName
    spokeName: 'data'
    addressPrefix: dataServicesAddressPrefix
    hubVNetId: hubVNet.outputs.vnetId
    hubVNetName: hubVNetName
    subnets: [
      {
        name: 'StorageSubnet'
        addressPrefix: '10.3.1.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.Storage']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'DatabaseSubnet'
        addressPrefix: '10.3.2.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.Sql', 'Microsoft.Storage']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'KeyVaultSubnet'
        addressPrefix: '10.3.3.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.KeyVault']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'BackupSubnet'
        addressPrefix: '10.3.4.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.Storage']
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
  }
}

// Azure Bastion (Optional)
module bastion './components/bastion.bicep' = if (enableBastion) {
  name: 'bastion-deployment'
  params: {
    location: location
    environment: environment
    projectName: projectName
    bastionSubnetId: hubVNet.outputs.bastionSubnetId
  }
}

// NAT Gateway for secure outbound
module natGateway './components/nat-gateway.bicep' = {
  name: 'natGateway-deployment'
  params: {
    location: location
    environment: environment
    projectName: projectName
  }
}

// Outputs
output hubVNetId string = hubVNet.outputs.vnetId
output hubVNetName string = hubVNetName
output aiServicesSpokeId string = aiServicesSpoke.outputs.vnetId
output computeSpokeId string = computeSpoke.outputs.vnetId
output dataServicesSpokeId string = dataSpoke.outputs.vnetId
output bastionFqdn string = enableBastion ? bastion!.outputs.bastionFqdn : ''
output bastionResourceId string = enableBastion ? bastion!.outputs.bastionResourceId : ''
output natGatewayId string = natGateway.outputs.natGatewayId
output networkSecurityGroupIds object = {
  aiServices: aiServicesSpoke.outputs.nsgId
  compute: computeSpoke.outputs.nsgId
  dataServices: dataSpoke.outputs.nsgId
  hub: hubVNet.outputs.nsgId
}
output subnetIds object = {
  hub: hubVNet.outputs.subnetIds
  aiServices: aiServicesSpoke.outputs.subnetIds
  compute: computeSpoke.outputs.subnetIds
  dataServices: dataSpoke.outputs.subnetIds
}
