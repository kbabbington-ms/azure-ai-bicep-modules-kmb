// Policy Definition: SFI-W1-Def-DataServices-RequireSSLOnly
@description('Require SSL/TLS encryption for all database connections for SFI-W1 compliance.')
param policyName string = 'SFI-W1-Def-DataServices-RequireSSLOnly'
param policyDisplayName string = 'SFI-W1-Def-DataServices: Require SSL Only Connections'
param policyDescription string = 'Enforce SSL/TLS encryption for all database services including SQL, MySQL, PostgreSQL, and Cosmos DB for SFI-W1 compliance.'

targetScope = 'subscription'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'SQL'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
      sfiCompliance: 'W1'
    }
    policyRule: {
      if: {
        anyOf: [
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Sql/servers'
              }
              {
                anyOf: [
                  {
                    field: 'Microsoft.Sql/servers/minimalTlsVersion'
                    notEquals: '1.2'
                  }
                  {
                    field: 'Microsoft.Sql/servers/minimalTlsVersion'
                    exists: false
                  }
                ]
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.DBforMySQL/servers'
              }
              {
                anyOf: [
                  {
                    field: 'Microsoft.DBforMySQL/servers/sslEnforcement'
                    notEquals: 'Enabled'
                  }
                  {
                    field: 'Microsoft.DBforMySQL/servers/minimalTlsVersion'
                    notEquals: 'TLS1_2'
                  }
                ]
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.DBforPostgreSQL/servers'
              }
              {
                anyOf: [
                  {
                    field: 'Microsoft.DBforPostgreSQL/servers/sslEnforcement'
                    notEquals: 'Enabled'
                  }
                  {
                    field: 'Microsoft.DBforPostgreSQL/servers/minimalTlsVersion'
                    notEquals: 'TLS1_2'
                  }
                ]
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.DocumentDB/databaseAccounts'
              }
              {
                field: 'Microsoft.DocumentDB/databaseAccounts/disableKeyBasedMetadataWriteAccess'
                notEquals: true
              }
            ]
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

output policyDefinitionId string = policyDefinition.id
