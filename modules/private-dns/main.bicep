@description('Private DNS Zones for AI Enclave - Complete DNS resolution for all Azure services')
param environment string = 'dev'
param projectName string = 'ai-enclave'
param vnetIds array = []

// Create Private DNS Zones for AI Services
resource cognitiveServicesZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.cognitiveservices.azure.com'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Cognitive Services'
  }
}

resource openAiZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.openai.azure.com'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Azure OpenAI'
  }
}

resource machineLearningZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.api.azureml.ms'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Machine Learning'
  }
}

resource storageFileZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.file.${az.environment().suffixes.storage}'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Storage Files'
  }
}

resource storageBlobZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${az.environment().suffixes.storage}'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Storage Blobs'
  }
}

resource keyVaultZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Key Vault'
  }
}

resource searchZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.search.windows.net'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Cognitive Search'
  }
}

resource sqlZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${az.environment().suffixes.sqlServerHostname}'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for SQL Database'
  }
}

resource cosmosZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.documents.azure.com'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Cosmos DB'
  }
}

resource containerRegistryZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurecr.io'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Container Registry'
  }
}

// Link DNS Zones to VNets
resource cognitiveServicesVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: cognitiveServicesZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource openAiVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: openAiZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource machineLearningVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: machineLearningZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource storageFileVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: storageFileZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource storageBlobVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: storageBlobZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource keyVaultVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: keyVaultZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource searchVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: searchZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

// Outputs
output cognitiveServicesZoneId string = cognitiveServicesZone.id
output openAiZoneId string = openAiZone.id
output machineLearningZoneId string = machineLearningZone.id
output keyVaultZoneId string = keyVaultZone.id
output storageBlobZoneId string = storageBlobZone.id
output storageFileZoneId string = storageFileZone.id
output searchZoneId string = searchZone.id
output sqlZoneId string = sqlZone.id
output cosmosZoneId string = cosmosZone.id
output containerRegistryZoneId string = containerRegistryZone.id
