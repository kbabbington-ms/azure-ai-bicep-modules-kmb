# Application Gateway with WAF Module

This module deploys Azure Application Gateway v2 with Web Application Firewall (WAF) for the AI Enclave.

## Resources Deployed

- **Azure Application Gateway v2**
  - WAF v2 tier with auto-scaling
  - Zone redundant deployment
  - HTTP to HTTPS redirection
  - SSL termination
  - Health probes

- **Web Application Firewall Policy**
  - OWASP Core Rule Set 3.2
  - Bot Manager Rule Set
  - Custom rate limiting rules
  - Geo-blocking for high-risk countries
  - Prevention mode

- **Public IP Address**
  - Standard SKU with static allocation
  - Zone redundant
  - DNS label for easy access

- **User Assigned Managed Identity**
  - For Key Vault certificate access
  - Minimal privilege access

## Features

- **Security**: WAF protection, geo-blocking, rate limiting, SSL policy
- **High Availability**: Zone redundancy, auto-scaling
- **Performance**: HTTP/2 support, connection draining
- **Monitoring**: Comprehensive diagnostic logging
- **Compliance**: Enterprise security standards

## Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| location | string | Azure region | resourceGroup().location |
| environment | string | Environment name | 'dev' |
| projectName | string | Project name | 'ai-enclave' |
| subnetId | string | Application Gateway subnet ID | Required |
| logAnalyticsWorkspaceId | string | Log Analytics workspace ID | '' |
| keyVaultId | string | Key Vault resource ID | '' |
| sslCertificateData | string | SSL certificate data (base64) | '' |
| sslCertificatePassword | securestring | SSL certificate password | '' |
| domainName | string | Domain name for HTTPS listener | 'ai-enclave.contoso.com' |

## Outputs

| Output | Description |
|--------|-------------|
| applicationGatewayId | Application Gateway resource ID |
| applicationGatewayName | Application Gateway name |
| publicIPAddress | Public IP address |
| publicIPFqdn | Public IP FQDN |
| wafPolicyId | WAF Policy resource ID |
| userAssignedIdentityId | User Assigned Identity resource ID |
| userAssignedIdentityPrincipalId | User Assigned Identity principal ID |

## WAF Protection

### OWASP Core Rule Set 3.2
- Protection against common web vulnerabilities
- SQL injection prevention
- Cross-site scripting (XSS) protection
- Command injection prevention

### Bot Manager Rule Set
- Bad bot detection and blocking
- Good bot identification
- Bot behavior analysis

### Custom Rules
- **Rate Limiting**: 100 requests per minute per IP
- **Geo-blocking**: Blocks traffic from high-risk countries (CN, RU, KP, IR)

## SSL Configuration

The module supports SSL certificate configuration in two ways:

1. **Certificate Data**: Provide base64-encoded certificate and password
2. **Key Vault Integration**: Reference certificates stored in Key Vault (requires keyVaultId)

## Backend Configuration

Default backend pools and health probes are configured. To add specific backends:

1. Update the `backendAddressPools` array
2. Configure appropriate health probes
3. Create routing rules for your applications

## Usage

```bash
# Deploy with Azure CLI
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters main.parameters.json

# Deploy with PowerShell
New-AzResourceGroupDeployment \
  -ResourceGroupName "myResourceGroup" \
  -TemplateFile "main.bicep" \
  -TemplateParameterFile "main.parameters.json"
```

## Dependencies

- Virtual Network with Application Gateway subnet (minimum /24)
- Log Analytics workspace (optional)
- Key Vault (optional, for certificate management)
- Backend applications/services

## Security Considerations

- WAF in Prevention mode blocks malicious traffic
- Rate limiting prevents abuse
- Geo-blocking reduces attack surface
- SSL policy uses secure protocols only
- User-assigned identity for certificate access
- All traffic logged for security analysis

## Monitoring

- Access logs capture all requests
- Performance logs track metrics
- Firewall logs record blocked traffic
- Metrics sent to Log Analytics workspace
- Alert rules can be configured for security events
