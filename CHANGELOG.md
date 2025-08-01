# Changelog

All notable changes to the Azure AI Services Bicep Modules project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Machine Learning workspace module
- Azure Cognitive Search module
- Key Vault module with RBAC
- Virtual Network and Private Endpoint modules
- Complete AI platform templates

## [1.1.0] - 2025-01-31

### Added - Cognitive Services Module
- **Comprehensive Cognitive Services Bicep Module** with 60+ parameters
- **All Azure AI Services Support** including:
  - Azure OpenAI Service (GPT, ChatGPT, DALL-E)
  - Speech Services (Speech-to-Text, Text-to-Speech, Translation)
  - Computer Vision (Image analysis, OCR, spatial analysis)
  - Face API (Detection, recognition, verification)
  - Text Analytics (Sentiment analysis, key phrase extraction)
  - Form Recognizer/Document Intelligence
  - Custom Vision Training and Prediction
  - Language Understanding (LUIS)
  - Multi-service Cognitive Services accounts
- **Enterprise Security Features**:
  - Private endpoints for secure connectivity
  - Customer-managed encryption with Key Vault
  - Network ACLs with IP and VNet restrictions
  - Azure AD authentication with disabled local auth
  - RBAC integration with built-in roles
  - Outbound network access restrictions with FQDN allowlists
- **Advanced Configuration Options**:
  - Multi-region deployment support
  - User-owned storage for data residency
  - Custom subdomain configuration
  - Managed identity integration (System and User-assigned)
  - Dynamic throttling and capacity management
- **Comprehensive Monitoring**:
  - Diagnostic logging to Log Analytics
  - Azure Monitor alerts with email notifications
  - Audit trail for compliance requirements
  - Performance and usage metrics
- **Deployment Automation**:
  - Cross-platform deployment scripts (Bash/PowerShell)
  - 10 comprehensive test scenarios
  - Parameter validation and what-if support
  - Error handling and rollback capabilities
- **Documentation & Testing**:
  - Detailed README with security best practices
  - Complete parameter documentation
  - Real-world usage examples
  - Test scenarios for all service types

## [1.0.0] - 2025-01-31

### Added - Storage Account Module
- **Comprehensive Storage Account Bicep Module** with 100+ parameters
- **Security-First Configuration** with secure defaults
- **All Storage Account Features** including:
  - Data Lake Storage Gen2 support
  - SFTP protocol support
  - NFSv3 protocol support
  - Immutable storage with WORM policies
  - Customer-managed encryption keys
  - Infrastructure encryption (double encryption)
  - Network access controls with IP and VNet restrictions
  - Private endpoint ready configuration
  - Managed identity integration
  - Azure Files identity-based authentication
  - SAS policy management
  - Key rotation policies
  - Custom domain support
  - Routing preferences
  - Extended location (Edge Zone) support

### Security Features
- **HTTPS-only traffic** enforcement by default
- **TLS 1.2+ minimum** version requirement
- **Shared key access disabled** by default (Azure AD preferred)
- **Public blob access disabled** by default
- **Network deny-by-default** configuration
- **Cross-tenant replication disabled** by default
- **Infrastructure encryption enabled** by default
- **Account-level encryption keys** for broader scope
- **SAS token expiration policies** with blocking enforcement
- **Immutable storage support** for compliance requirements

### Documentation
- **Comprehensive README** with security guidance
- **Parameter documentation** with security implications
- **Usage examples** for different scenarios
- **Security best practices** documentation
- **Compliance mapping** for SOC 2, ISO 27001, HIPAA, GDPR
- **Troubleshooting guide** for common issues

### Testing & Deployment
- **Test scenarios** covering all configurations
- **Bash deployment script** for Linux/macOS
- **PowerShell deployment script** for Windows
- **Parameter file templates** with secure defaults
- **Validation scripts** for template verification

### Compliance Support
- **SOC 2 Type II** ready configurations
- **ISO 27001** compliance features
- **HIPAA** security controls
- **GDPR** data protection measures
- **PCI DSS** security requirements
- **SOX** immutability controls

### Developer Experience
- **IntelliSense support** with comprehensive parameter descriptions
- **Error handling** with clear validation messages
- **Deployment automation** with script templates
- **Configuration examples** for common scenarios
- **Troubleshooting documentation** for deployment issues

### File Structure
```
modules/storage/
├── storage-account.bicep           # Main module (600+ lines)
├── storage-account.parameters.json # Parameter template
├── test-storage-account.bicep      # Test scenarios
├── deploy.sh                       # Bash deployment script
├── deploy.ps1                      # PowerShell deployment script
├── config.env                      # Configuration templates
└── README.md                       # Comprehensive documentation
```

### Module Outputs
- Storage account resource ID and metadata
- Primary and secondary endpoints
- Managed identity principal IDs
- Network ACL configuration
- Encryption configuration
- Provisioning status

### Supported SKUs
- Standard_LRS (Locally redundant storage)
- Standard_GRS (Geo-redundant storage)
- Standard_RAGRS (Read-access geo-redundant storage)
- Standard_ZRS (Zone-redundant storage)
- Premium_LRS (Premium locally redundant storage)
- Premium_ZRS (Premium zone-redundant storage)
- Standard_GZRS (Geo-zone-redundant storage)
- Standard_RAGZRS (Read-access geo-zone-redundant storage)

### Supported Storage Types
- StorageV2 (General-purpose v2 - recommended)
- Storage (General-purpose v1 - legacy)
- BlobStorage (Blob-only storage)
- FileStorage (Premium file shares)
- BlockBlobStorage (Premium block blobs)

### Network Security Features
- IP address allowlists with CIDR support
- Virtual network service endpoints
- Private endpoint ready configuration
- Network security group integration
- Azure service bypass rules
- Resource access rules for cross-tenant scenarios

### Encryption Features
- Platform-managed keys (default)
- Customer-managed keys with Key Vault integration
- Infrastructure encryption (double encryption)
- Service-level and account-level encryption scopes
- Federated identity support for cross-tenant CMK
- Automatic key rotation support

### Advanced Features
- Azure Data Lake Storage Gen2 (Hierarchical Namespace)
- SFTP protocol with local user management
- NFSv3 protocol for Linux workloads
- Large file shares up to 100 TiB
- Immutable storage with time-based and legal hold policies
- Custom domain mapping with CNAME support
- Routing preferences (Microsoft vs Internet routing)
- Extended locations for edge scenarios

### Monitoring & Diagnostics
- Diagnostic settings ready configuration
- Log Analytics integration preparation
- Security monitoring configuration
- Performance metrics collection
- Audit logging preparation

## [0.1.0] - 2025-01-31

### Added - Project Foundation
- Project structure and organization
- Repository README with roadmap
- Security guidelines and best practices
- Contributing guidelines
- License and documentation standards

### Infrastructure
- Modular Bicep architecture
- Security-first design principles
- Comprehensive testing approach
- Multi-platform deployment scripts
- Documentation standards

---

## Security Notices

### Current Security Features
- All modules implement security best practices by default
- Secure defaults for all security-related parameters
- Comprehensive documentation of security implications
- Compliance-ready configurations included

### Security Validation
- Template validation for security configurations
- Parameter validation for secure defaults
- Network access testing
- Encryption verification
- Identity configuration validation

### Compliance Status
- **SOC 2 Type II**: Ready with proper configuration
- **ISO 27001**: Compliance features implemented
- **HIPAA**: Security controls available
- **GDPR**: Data protection measures included
- **PCI DSS**: Security requirements supported

---

## Migration Notes

### From Azure ARM Templates
- Convert ARM parameters to Bicep format
- Update resource API versions to latest
- Implement new security features
- Review and update network configurations

### From Basic Storage Deployments
- Enable security features gradually
- Test network access changes
- Implement managed identity authentication
- Configure encryption settings

---

## Breaking Changes

None in this initial release.

---

## Support Matrix

### Azure Regions
- All public Azure regions
- Azure Government regions
- Azure China regions
- Edge locations with extended location support

### API Versions
- Storage Accounts: 2023-05-01 (latest)
- Managed Identity: Latest stable
- Key Vault: Latest stable
- Network: Latest stable

### Tools Compatibility
- Azure CLI 2.0+
- Azure PowerShell 5.0+
- Bicep CLI 0.15+
- Visual Studio Code with Bicep extension

---

## Known Issues

None at this time.

---

## Contributors

Initial development by Azure AI Services team following Microsoft and security best practices.

---

## Acknowledgments

- Microsoft Azure documentation team
- Azure Security Center recommendations
- Azure Well-Architected Framework guidance
- Community feedback and contributions
