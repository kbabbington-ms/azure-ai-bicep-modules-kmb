// Video Indexer Resource Deployment Module
param name string
param location string = resourceGroup().location
param tags object = {}

resource videoIndexer 'Microsoft.VideoIndexer/accounts@2022-05-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    // Add required properties here
  }
}

output videoIndexerId string = videoIndexer.id
