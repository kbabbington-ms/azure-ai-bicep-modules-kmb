@description('Application Gateway with WAF for AI Enclave web applications')
param location string = resourceGroup().location
param environment string = 'dev'
param projectName string = 'ai-enclave'
param subnetId string
param logAnalyticsWorkspaceId string = ''
param keyVaultId string = ''
param sslCertificateData string = ''

@secure()
param sslCertificatePassword string = ''

param domainName string = 'ai-enclave.contoso.com'

// Resource naming
var appGatewayName = 'agw-${projectName}-${environment}-${location}'
var publicIpName = 'pip-${appGatewayName}'
var wafPolicyName = 'waf-${projectName}-${environment}'
var userAssignedIdentityName = 'id-${appGatewayName}'

// User Assigned Managed Identity for Key Vault access
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Managed Identity for Application Gateway'
  }
}

// Public IP for Application Gateway
resource publicIP 'Microsoft.Network/publicIPAddresses@2023-06-01' = {
  name: publicIpName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Public IP for Application Gateway'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: '${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
    }
  }
  zones: ['1', '2', '3']
}

// WAF Policy
resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-06-01' = {
  name: wafPolicyName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'WAF Policy for Application Gateway'
  }
  properties: {
    policySettings: {
      mode: 'Prevention'
      state: 'Enabled'
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      requestBodyCheck: true
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
          ruleGroupOverrides: []
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '0.1'
        }
      ]
      exclusions: []
    }
    customRules: [
      {
        name: 'RateLimitRule'
        priority: 100
        ruleType: 'RateLimitRule'
        action: 'Block'
        rateLimitDuration: 'OneMin'
        rateLimitThreshold: 100
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'IPMatch'
            matchValues: [
              '0.0.0.0/0'
            ]
          }
        ]
      }
      {
        name: 'GeoBlockRule'
        priority: 200
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'GeoMatch'
            matchValues: [
              'CN'
              'RU'
              'KP'
              'IR'
            ]
          }
        ]
      }
    ]
  }
}

// Application Gateway
resource appGateway 'Microsoft.Network/applicationGateways@2023-06-01' = {
  name: appGatewayName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Application Gateway with WAF'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    autoscaleConfiguration: {
      minCapacity: 2
      maxCapacity: 10
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'default-backend-pool'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'default-http-setting'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'default-health-probe')
          }
        }
      }
      {
        name: 'default-https-setting'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'default-https-probe')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'default-http-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
        }
      }
      {
        name: 'default-https-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'port_443')
          }
          protocol: 'Https'
          hostNames: [domainName]
          requireServerNameIndication: true
          sslCertificate: !empty(sslCertificateData) ? {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, 'default-ssl-cert')
          } : null
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'http-redirect-rule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'default-http-listener')
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', appGatewayName, 'http-to-https-redirect')
          }
        }
      }
      {
        name: 'default-https-rule'
        properties: {
          ruleType: 'Basic'
          priority: 200
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'default-https-listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, 'default-backend-pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, 'default-https-setting')
          }
        }
      }
    ]
    probes: [
      {
        name: 'default-health-probe'
        properties: {
          protocol: 'Http'
          host: '127.0.0.1'
          path: '/health'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: ['200-399']
          }
        }
      }
      {
        name: 'default-https-probe'
        properties: {
          protocol: 'Https'
          host: '127.0.0.1'
          path: '/health'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: ['200-399']
          }
        }
      }
    ]
    redirectConfigurations: [
      {
        name: 'http-to-https-redirect'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'default-https-listener')
          }
          includePath: true
          includeQueryString: true
        }
      }
    ]
    sslCertificates: !empty(sslCertificateData) ? [
      {
        name: 'default-ssl-cert'
        properties: {
          data: sslCertificateData
          password: sslCertificatePassword
        }
      }
    ] : []
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
      disabledRuleGroups: []
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
    }
    firewallPolicy: {
      id: wafPolicy.id
    }
    enableHttp2: true
    sslPolicy: {
      policyType: 'Predefined'
      policyName: 'AppGwSslPolicy20220101S'
    }
  }
  zones: ['1', '2', '3']
}

// Diagnostic Settings
resource appGatewayDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  scope: appGateway
  name: 'app-gateway-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Key Vault Access Policy (if Key Vault provided)
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = if (!empty(keyVaultId)) {
  name: '${last(split(keyVaultId, '/'))}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: userAssignedIdentity.properties.principalId
        permissions: {
          secrets: ['get']
          certificates: ['get']
        }
      }
    ]
  }
}

// Outputs
output applicationGatewayId string = appGateway.id
output applicationGatewayName string = appGateway.name
output publicIPAddress string = publicIP.properties.ipAddress
output publicIPFqdn string = publicIP.properties.dnsSettings.fqdn
output wafPolicyId string = wafPolicy.id
output userAssignedIdentityId string = userAssignedIdentity.id
output userAssignedIdentityPrincipalId string = userAssignedIdentity.properties.principalId
