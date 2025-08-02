# Azure AI Services - Comprehensive Bicep Modules


## 🚀 Overview

This repository contains a comprehensive collection of Bicep modules for deploying secure Azure AI services and supporting infrastructure. In addition to service modules, we are actively developing and including Azure Policy definitions and initiatives for all AI resources. These policies help enforce security, compliance, and operational best practices across your environment.

### Policy-as-Code for AI Services
- **SFI Compliance**: Policy definitions and initiatives for Secure Foundational Infrastructure (SFI) requirements
- **AI Resource Coverage**: Policies for Cognitive Services, OpenAI, Machine Learning, Key Vault, Storage, Networking, and more
- **Initiative Grouping**: All policies are grouped in initiatives for easy assignment and management
- **Continuous Expansion**: We are expanding coverage to include all AI-related Azure resources as the project evolves


## 🏗️ Architecture Approach

### Security-First Design
- **Zero-Trust Network Architecture** - Deny by default, explicit allow rules
- **Identity-Based Authentication** - Managed identities preferred over access keys
- **Encryption at Rest and in Transit** - Customer-managed keys support
- **Compliance Ready** - Supports SOC 2, ISO 27001, PCI DSS, HIPAA, GDPR
- **Audit and Monitoring** - Comprehensive logging and diagnostics

### Modular Structure
- **Self-Contained Modules** - Each service in its own module
- **Reusable Components** - Parameterized for different environments
- **Testing Included** - Validation scripts and test scenarios
- **Documentation Rich** - Every parameter documented with security implications


## 📁 Repository Structure

```
azure-ai-bicep-modules/
├── bicep/policy/foundry/           # SFI policy definitions & initiatives for AI resources
│   ├── SFI-W1-Def-Foundry-*.bicep  # Individual policy definitions (tagging, encryption, network, etc.)
│   ├── SFI-W1-Ini-Foundry.bicep    # Initiative grouping all policies for AI Foundry
│   ├── DEPLOYMENT_INSTRUCTIONS.md  # Step-by-step deployment guide
│   └── README.md                   # Policy documentation
├── modules/

## ✅ Completed Modules

### 🗄️ Storage Account Module
**Location**: `modules/storage/`

A comprehensive Azure Storage Account module with all security features:

#### Key Features:
- **🔒 Security Hardened**: HTTPS-only, TLS 1.2+, no public access by default
- **🔐 Encryption**: Customer-managed keys, infrastructure encryption
- **🌐 Network Security**: Private endpoints, IP restrictions, VNet rules
- **🔑 Identity**: Managed identity support, Azure AD authentication
- **📊 Advanced Features**: Data Lake Gen2, SFTP, NFSv3, immutable storage
- **✅ Compliance**: SOX, HIPAA, GDPR ready configurations

### 🧠 Cognitive Services Module
**Location**: `modules/cognitive-services/`

Multi-service AI capabilities with comprehensive security:

#### Key Features:
- **🤖 All AI Services**: OpenAI, Speech, Vision, Language, Form Recognizer
- **🔒 Enterprise Security**: Private endpoints, customer-managed encryption
- **🎯 Service-Specific**: Dedicated configurations for each AI service type
- **🔐 Identity & RBAC**: Azure AD authentication with built-in roles
- **📊 Monitoring**: Comprehensive diagnostics and alerting
- **✅ Compliance**: SOC2, HIPAA, GDPR ready configurations

### 🤖 Azure OpenAI Service Module ⭐ **NEW**
**Location**: `modules/azure-openai/`

Dedicated Azure OpenAI module for enterprise generative AI:

#### Key Features:
- **🎯 Model Management**: GPT-4o, GPT-4o-mini, DALL-E 3, embeddings
- **🛡️ Content Safety**: Advanced content filtering with custom RAI policies
- **🔒 Maximum Security**: Private endpoints, customer-managed encryption
- **⚡ Enterprise Scale**: Multiple model deployments with capacity management
- **🎭 RBAC Integration**: AI-specific roles for developers and users
- **📊 Advanced Monitoring**: Token usage, performance, and security analytics

#### Usage Examples:
```bicep
// Enterprise OpenAI deployment
module openAI 'modules/azure-openai/main.bicep' = {
  name: 'enterprise-openai'
  params: {
    openAIAccountName: 'mycompany-openai-prod'
    customSubDomainName: 'mycompany-openai-prod'
    location: 'eastus'
    
    // Model deployments
    modelDeployments: [
      {
        name: 'gpt-4o'
        model: {
          format: 'OpenAI'
          name: 'gpt-4o'
          version: '2024-08-06'
        }
        capacity: 50
        raiPolicyName: 'strict-enterprise-policy'
      }
    ]
    
    // Maximum security
    publicNetworkAccess: 'Disabled'
    enablePrivateEndpoint: true
    enableCustomerManagedEncryption: true
    
    tags: {
      Environment: 'Production'
      Compliance: 'SOC2,HIPAA,GDPR'
    }
  }
}
```

#### Usage Examples:
```bicep
// Basic secure storage
module storage 'modules/storage/storage-account.bicep' = {
  name: 'secure-storage'
  params: {
    storageAccountName: 'mystgaccount'
    location: 'East US 2'
    skuName: 'Standard_ZRS'
    publicNetworkAccess: 'Disabled'
    allowSharedKeyAccess: false
  }
}

// Data Lake Gen2
module dataLake 'modules/storage/storage-account.bicep' = {
  name: 'data-lake'
  params: {
    storageAccountName: 'mydatalake'
    location: 'East US 2'
    skuName: 'Standard_ZRS'
    isHnsEnabled: true
    networkAclsDefaultAction: 'Deny'
  }
}
```

## 🔄 In Development Modules

### 🤖 Copilot Studio Integration
**Location**: `modules/copilot-studio/` | **Status**: 🔄 IN DEVELOPMENT

Enterprise AI assistants and chatbots:
- **Power Platform Environment** setup and configuration
- **Bot Framework** integration with Azure services
- **Teams & SharePoint** connectors
- **Azure AD B2C** authentication
- **Application Insights** analytics

### 📄 Document Intelligence
**Location**: `modules/document-intelligence/` | **Status**: ✅ COMPLETED

Advanced document processing beyond Form Recognizer:
- **Custom Models** for specific document types
- **Batch Processing** workflows
- **Prebuilt Models** (invoices, receipts, IDs)
- **Integration Patterns** with Logic Apps

### ⚡ AI Workflows
**Location**: `modules/ai-workflows/` | **Status**: ✅ COMPLETED

Orchestration for AI processing pipelines:
- **Logic Apps Standard** enterprise workflow platform
- **Auto-scaling** compute with VNet integration
- **AI Service Connectors** for OpenAI, Document Intelligence, Cognitive Services
- **Event-Driven Architecture** with Event Grid and Service Bus
- **Pre-built Templates** for common AI workflow patterns
- **Enterprise Security** with private endpoints and customer-managed encryption
- **AI Service Connectors** pre-configured
- **Error Handling** and retry policies
- **Monitoring** and analytics

## 🔄 Planned Modules

### 🧠 Advanced AI Services
- **🎥 Azure AI Video Indexer** with content analysis
- **🛡️ Azure AI Content Safety** with moderation policies
- **🎯 Azure AI Personalizer** with recommendation engines
- **🌐 Azure API Management** for AI service gateway

### 🤖 Machine Learning
- **ML Workspace** with private link
- **Compute Instances** with custom images
- **Compute Clusters** with auto-scaling
- **Datastores** with secure connections
- **Model Endpoints** with monitoring

### 🔍 Azure Cognitive Search
- **Search Service** with semantic search
- **Private Endpoints** for secure access
- **Custom Skillsets** with AI enrichment
- **Index Management** automation

### 🔐 Security & Identity
- **Key Vault** with RBAC and access policies
- **Managed Identities** with role assignments
- **Private Endpoints** for all services
- **Network Security Groups** with AI-specific rules

### 📊 Monitoring & Logging
- **Log Analytics** with AI workbooks
- **Application Insights** with custom metrics
- **Diagnostic Settings** for all services
- **Alert Rules** for AI-specific scenarios

## 🛡️ Security Features

### Authentication & Authorization
- ✅ **Managed Identities** for service-to-service authentication
- ✅ **Azure AD Integration** for user authentication
- ✅ **RBAC** for fine-grained access control
- ✅ **No shared keys** by default

### Network Security
- ✅ **Private Endpoints** for all services
- ✅ **Network ACLs** with deny-by-default
- ✅ **VNet Integration** for secure communication
- ✅ **NSG Rules** for traffic filtering

### Data Protection
- ✅ **Encryption at Rest** with customer-managed keys
- ✅ **Encryption in Transit** with TLS 1.2+
- ✅ **Data Residency** controls
- ✅ **Immutable Storage** for compliance

### Compliance
- ✅ **SOC 2 Type II** ready configurations
- ✅ **ISO 27001** compliance features
- ✅ **HIPAA** security controls
- ✅ **GDPR** data protection measures
- ✅ **PCI DSS** security requirements

## 🚀 Quick Start

### Prerequisites
- Azure CLI or Azure PowerShell
- Bicep CLI
- Appropriate Azure permissions

### Deploy Storage Account
```bash
# Clone repository
git clone https://github.com/your-org/azure-ai-bicep-modules.git
cd azure-ai-bicep-modules

# Deploy storage account
cd modules/storage
./deploy.sh --secure
```

### Deploy with PowerShell
```powershell
# Navigate to storage module
cd modules\\storage

# Deploy secure storage
.\\deploy.ps1 -SecureOnly
```

## 📋 Parameter Categories

### 🔴 Security Parameters
Parameters that directly impact security posture:
- `allowSharedKeyAccess` - Disable for enhanced security
- `publicNetworkAccess` - Set to 'Disabled' for private access
- `minimumTlsVersion` - Use 'TLS1_2' or higher
- `encryptionKeySource` - Use 'Microsoft.Keyvault' for CMK

### 🟡 Compliance Parameters
Parameters for regulatory compliance:
- `immutableStorageEnabled` - Required for WORM compliance
- `allowCrossTenantReplication` - Restrict for data residency
- `sasExpirationPeriod` - Shorter periods for better security
- `keyExpirationPeriodInDays` - Regular rotation for compliance

### 🟢 Feature Parameters
Parameters for functionality:
- `isHnsEnabled` - Enable for Data Lake Gen2
- `isSftpEnabled` - Enable for SFTP access
- `largeFileSharesState` - Enable for large file shares
- `routingChoice` - Configure network routing

## 🧪 Testing

Each module includes comprehensive testing:

### Validation Tests
- Template syntax validation
- Parameter validation
- Resource naming validation
- Security configuration validation

### Deployment Tests
- Basic deployment scenarios
- Secure deployment scenarios
- Feature-specific deployments
- Error handling tests

### Security Tests
- Network access verification
- Encryption validation
- Identity configuration checks
- Compliance requirement validation

## 🤝 Contributing

### Development Guidelines
1. **Security First** - All modules must be secure by default
2. **Documentation** - Every parameter must be documented
3. **Testing** - Include test scenarios for all configurations
4. **Consistency** - Follow established patterns and naming

### Adding New Modules
1. Create module directory under `modules/`
2. Include main Bicep file with comprehensive parameters
3. Add parameters file with secure defaults
4. Create test file with multiple scenarios
5. Write deployment scripts (Bash and PowerShell)
6. Document with security implications

### Security Review Checklist
- [ ] No secrets in parameters or outputs
- [ ] Secure defaults for all security parameters
- [ ] Network access controls implemented
- [ ] Encryption enabled by default
- [ ] Managed identity preferred over keys
- [ ] Compliance features documented

## 📖 Documentation

### Module Documentation
Each module includes:
- Comprehensive parameter documentation
- Security best practices
- Usage examples
- Troubleshooting guide
- Compliance mapping

### Security Documentation
- Security configuration guides
- Compliance requirement mapping
- Threat modeling considerations
- Incident response procedures

## 🎯 Roadmap

### Phase 1: Core Infrastructure ✅
- [x] Storage Account module
- [ ] Key Vault module
- [ ] Virtual Network module
- [ ] Log Analytics module

### Phase 2: AI Services 🔄
- [ ] Cognitive Services modules
- [ ] Azure OpenAI module
- [ ] Machine Learning modules
- [ ] Search Service module

### Phase 3: Complete Solutions 📋
- [ ] AI Platform template
- [ ] Landing Zone template
- [ ] Multi-region template
- [ ] Disaster recovery template


### Phase 4: Advanced Features 🚀
- [ ] GitOps integration
- [x] Policy-as-Code: SFI policy definitions and initiatives for all AI resources
- [ ] Automated testing
- [ ] Compliance automation

## 📊 Project Progress

- **Policy-as-Code**: Actively developing and expanding policy definitions and initiatives for all Azure AI resources
- **Coverage**: Cognitive Services, OpenAI, Machine Learning, Key Vault, Storage, Networking, Monitoring, Identity, and more
- **Documentation**: All policy modules and initiatives are documented in `bicep/policy/foundry/README.md` and deployment steps in `DEPLOYMENT_INSTRUCTIONS.md`
- **Goal**: Achieve full SFI compliance and best practices for every AI workload deployed with these modules


## 📞 Support

### Getting Help
1. Check module README files
2. Review troubleshooting documentation
3. Validate parameters against schemas
4. Test in development environment

### Reporting Issues
- Security issues: Follow responsible disclosure
- Bug reports: Include reproduction steps
- Feature requests: Provide use case details
- Documentation: Suggest improvements

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Tags

`azure` `bicep` `infrastructure-as-code` `security` `compliance` `ai-services` `machine-learning` `cognitive-services` `azure-openai` `copilot-studio` `document-intelligence` `ai-workflows` `best-practices`

---


**⚠️ Security Notice**: These modules and policy definitions implement security best practices by default. Always review configurations and policy assignments before production deployment and ensure they meet your organization's specific security and compliance requirements.
