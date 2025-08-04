// Policy Definition: SFI-W1-Def-Compute-RequireSecureBoot
@description('Require secure boot and trusted launch for all compute resources for SFI-W1 compliance.')
param policyName string = 'SFI-W1-Def-Compute-RequireSecureBoot'
param policyDisplayName string = 'SFI-W1-Def-Compute: Require Secure Boot and Trusted Launch'
param policyDescription string = 'Enforce secure boot and trusted launch features for all virtual machines and VMSS to maintain hardware-level security for SFI-W1 compliance.'

targetScope = 'subscription'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Compute'
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
                equals: 'Microsoft.Compute/virtualMachines'
              }
              {
                anyOf: [
                  {
                    field: 'Microsoft.Compute/virtualMachines/securityProfile.securityType'
                    notEquals: 'TrustedLaunch'
                  }
                  {
                    field: 'Microsoft.Compute/virtualMachines/securityProfile.uefiSettings.secureBootEnabled'
                    notEquals: true
                  }
                  {
                    field: 'Microsoft.Compute/virtualMachines/securityProfile.uefiSettings.vTpmEnabled'
                    notEquals: true
                  }
                ]
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Compute/virtualMachineScaleSets'
              }
              {
                anyOf: [
                  {
                    field: 'Microsoft.Compute/virtualMachineScaleSets/virtualMachineProfile.securityProfile.securityType'
                    notEquals: 'TrustedLaunch'
                  }
                  {
                    field: 'Microsoft.Compute/virtualMachineScaleSets/virtualMachineProfile.securityProfile.uefiSettings.secureBootEnabled'
                    notEquals: true
                  }
                  {
                    field: 'Microsoft.Compute/virtualMachineScaleSets/virtualMachineProfile.securityProfile.uefiSettings.vTpmEnabled'
                    notEquals: true
                  }
                ]
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
