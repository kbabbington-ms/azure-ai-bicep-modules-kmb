# Contributing to Azure AI Bicep Modules

Thank you for your interest in contributing to the Azure AI Bicep Modules project! This document provides guidelines and information for contributors.

## 🎯 Project Vision

This project provides enterprise-grade Bicep modules for Azure AI services, focusing on:
- **Security-first design** with zero-trust architecture
- **Production-ready configurations** for enterprise environments
- **Comprehensive documentation** with real-world examples
- **Standardized patterns** across all AI services

## 🚀 Getting Started

### Prerequisites
- Azure CLI 2.50+ with Bicep extension
- Git for version control
- Code editor (VS Code recommended with Bicep extension)
- Azure subscription for testing

### Development Setup
1. Fork the repository
2. Clone your fork locally
3. Create a feature branch
4. Make your changes
5. Test thoroughly
6. Submit a pull request

## 📋 Contribution Guidelines

### Module Development Standards

#### 1. **Security Requirements**
- ✅ **Private endpoints by default** for production scenarios
- ✅ **Disabled public access** unless explicitly required
- ✅ **Managed identity authentication** where possible
- ✅ **Customer-managed encryption** support
- ✅ **RBAC integration** with appropriate role assignments
- ✅ **Network isolation** patterns

#### 2. **Code Quality Standards**
- ✅ **Zero lint errors** - All Bicep code must pass validation
- ✅ **Comprehensive parameters** with proper descriptions and constraints
- ✅ **Conditional deployment** patterns for optional features
- ✅ **Consistent naming** following Azure naming conventions
- ✅ **Resource tagging** with standardized tag schema
- ✅ **Output completeness** providing all necessary integration points

#### 3. **Documentation Requirements**
- ✅ **Complete README.md** with usage examples
- ✅ **Parameter documentation** with security implications
- ✅ **Deployment examples** for different scenarios
- ✅ **Security best practices** section
- ✅ **Troubleshooting guide** for common issues
- ✅ **Integration examples** with other modules

#### 4. **Testing Standards**
- ✅ **Template validation** using `az bicep build`
- ✅ **What-if deployment** testing
- ✅ **Parameter file validation** for different environments
- ✅ **Security configuration** verification
- ✅ **Integration testing** with dependent services

### File Structure Standards

Each module must include:
```
modules/[service-name]/
├── main.bicep                 # Main template
├── main.parameters.json       # Production parameters
├── README.md                 # Complete documentation
├── deploy.sh                 # Bash deployment script
├── deploy.ps1                # PowerShell deployment script
└── tests/                    # Test scenarios (optional)
    ├── basic.parameters.json
    ├── enterprise.parameters.json
    └── dev.parameters.json
```

## 🔒 Security Guidelines

### Secure by Default
All modules must implement security best practices:

1. **Network Security**
   - Private endpoints enabled by default
   - Public access disabled unless explicitly required
   - Network ACLs with deny-by-default policies
   - VNet integration where applicable

2. **Identity and Access Management**
   - Managed identity as primary authentication method
   - RBAC roles with principle of least privilege
   - Azure AD integration over API keys
   - Service principal support for automation

3. **Data Protection**
   - Customer-managed encryption options
   - Data residency considerations
   - Audit logging enabled
   - Compliance framework alignment

4. **Monitoring and Governance**
   - Diagnostic settings configured
   - Security alerting patterns
   - Log Analytics integration
   - Cost management tags

## 📝 Pull Request Process

### Before Submitting
1. **Test thoroughly** - Validate your changes work in real Azure environment
2. **Update documentation** - Ensure README and examples are current
3. **Check security** - Verify security best practices are followed
4. **Validate templates** - Ensure zero lint errors and proper validation

### PR Requirements
- **Clear description** of changes and motivation
- **Test results** showing successful deployment
- **Documentation updates** for any new parameters or features
- **Security review** confirmation for any security-related changes
- **Breaking change notice** if applicable

### Review Process
1. **Automated checks** - Template validation and lint checking
2. **Security review** - Security team review for security-related changes
3. **Technical review** - Code quality and architecture review
4. **Documentation review** - Ensure documentation completeness
5. **Integration testing** - Verify compatibility with existing modules

## 🐛 Bug Reports

When reporting bugs, please include:
- **Azure region** where issue occurred
- **Template version** or commit hash
- **Parameter configuration** (sanitized of secrets)
- **Error messages** or unexpected behavior description
- **Steps to reproduce** the issue
- **Expected vs actual** behavior

## 💡 Feature Requests

For new features or modules:
- **Business justification** for the feature
- **Security requirements** and considerations
- **Integration points** with existing modules
- **Proposed API** or parameter structure
- **Documentation outline** for the feature

## 🔧 Module Development Workflow

### 1. Planning Phase
- Review Azure service documentation
- Identify security requirements
- Plan parameter structure
- Design integration patterns

### 2. Development Phase
- Create main.bicep template
- Implement security features
- Add comprehensive parameters
- Create deployment scripts

### 3. Testing Phase
- Validate template syntax
- Test deployment scenarios
- Verify security configurations
- Test integration patterns

### 4. Documentation Phase
- Write comprehensive README
- Create usage examples
- Document security practices
- Add troubleshooting guide

### 5. Review Phase
- Self-review against standards
- Security configuration review
- Peer code review
- Final validation testing

## 📊 Quality Gates

Before merging, all contributions must pass:

### Automated Checks
- ✅ Bicep template validation
- ✅ Lint error checking
- ✅ Parameter validation
- ✅ Documentation completeness check

### Manual Review
- ✅ Security architecture review
- ✅ Code quality assessment
- ✅ Documentation accuracy verification
- ✅ Integration compatibility check

### Testing Requirements
- ✅ Successful deployment in test environment
- ✅ Security configuration verification
- ✅ Parameter validation across scenarios
- ✅ What-if deployment analysis

## 🎖️ Recognition

Contributors who make significant contributions will be:
- **Credited** in the project README
- **Highlighted** in release notes
- **Invited** to join the maintainer team (for exceptional contributors)

## 📞 Getting Help

- **General questions**: Create a discussion in the repository
- **Bug reports**: Create an issue with the bug template
- **Feature requests**: Create an issue with the feature template
- **Security concerns**: Email the security team directly
- **Code questions**: Tag reviewers in your pull request

## 📚 Additional Resources

- [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Well-Architected Framework](https://docs.microsoft.com/en-us/azure/architecture/framework/)
- [Azure Security Best Practices](https://docs.microsoft.com/en-us/azure/security/)
- [Azure Naming Conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)

---

**Thank you for contributing to making Azure AI services more secure and accessible for everyone!** 🚀
