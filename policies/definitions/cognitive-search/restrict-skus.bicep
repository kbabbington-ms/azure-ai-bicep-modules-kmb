// Policy: Restrict Cognitive Search SKUs
// Description: Ensures only approved SKUs are used for Cognitive Search
// SFI-W1: Resource governance and performance standards
// AzTS: Service tier restrictions and compliance

targetScope = 'subscription'

resource restrictSearchSKUs 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'restrict-search-skus'
  properties: {
    displayName: 'Azure Cognitive Search services should use approved SKUs only'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'Azure Cognitive Search services should only use approved SKUs to ensure performance standards, cost control, and compliance with organizational governance policies.'
    metadata: {
      version: '1.0.0'
      category: 'Search'
      sfiCompliance: 'Resource Governance, Performance Standards'
      aztsCompliance: 'Service Tier Management, Compliance'
      preview: false
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Deny'
      }
      allowedSKUs: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed SKUs'
          description: 'List of approved SKUs for Azure Cognitive Search services'
        }
        defaultValue: [
          'standard'
          'standard2'
          'standard3'
        ]
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Search/searchServices'
          }
          {
            field: 'Microsoft.Search/searchServices/sku.name'
            notIn: '[parameters(\'allowedSKUs\')]'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

output policyDefinitionId string = restrictSearchSKUs.id
