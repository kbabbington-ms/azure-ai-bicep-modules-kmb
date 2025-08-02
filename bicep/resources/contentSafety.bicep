// Content Safety Resource Deployment Module
param name string
param location string = resourceGroup().location
param tags object = {}

resource contentSafety 'Microsoft.ContentSafety/accounts@2023-01-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    // Add required properties here
  }
}

output contentSafetyId string = contentSafety.id
