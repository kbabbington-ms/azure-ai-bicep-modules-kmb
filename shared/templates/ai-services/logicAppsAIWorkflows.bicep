// Logic Apps AI Workflows Resource Deployment Module
param name string
param location string = resourceGroup().location
param tags object = {}

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    // Add required properties here
  }
}

output logicAppId string = logicApp.id
