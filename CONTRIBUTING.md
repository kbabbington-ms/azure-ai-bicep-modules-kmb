# Contributing to Azure AI Bicep Modules

Thank you for your interest in contributing to this project! This guide will help you get started.

## 🚀 Quick Start

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following our guidelines
4. Test your changes thoroughly
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📋 Development Guidelines

### Module Structure
Each module should follow this structure:
```
modules/module-name/
├── main.bicep                 # Main template
├── main.parameters.json       # Production parameters
├── README.md                  # Complete documentation
├── deploy.sh                  # Bash deployment script
├── deploy.ps1                 # PowerShell deployment script
└── test/                      # Test scenarios (optional)
```

### Bicep Best Practices
- ✅ Use descriptive parameter names with clear descriptions
- ✅ Include security enhancements in parameter descriptions
- ✅ Implement conditional logic for optional features
- ✅ Follow Azure naming conventions
- ✅ Include comprehensive outputs
- ✅ Add proper error handling

### Security Requirements
- 🔒 Enable private endpoints by default where applicable
- 🔒 Implement customer-managed encryption options
- 🔒 Use managed identities for authentication
- 🔒 Include RBAC role assignments
- 🔒 Add diagnostic settings for monitoring
- 🔒 Follow principle of least privilege

### Documentation Standards
- 📖 Include complete README with examples
- 📖 Document all parameters with security implications
- 📖 Provide multiple deployment scenarios
- 📖 Include troubleshooting sections
- 📖 Add architecture diagrams where helpful

## 🧪 Testing

### Before Submitting
- [ ] Run `az bicep build` to check for syntax errors
- [ ] Validate template with `az deployment group validate`
- [ ] Test deployment in development environment
- [ ] Verify all parameters work as expected
- [ ] Check documentation is complete and accurate

### Test Scenarios
Include test scenarios for:
- Basic deployment with minimal parameters
- Enterprise deployment with all security features
- Different SKU/tier configurations
- Integration with other modules

## 📝 Pull Request Process

1. **Create Issue First**: For significant changes, create an issue to discuss the approach
2. **Small Commits**: Make small, focused commits with clear messages
3. **Documentation**: Update documentation for any new features or parameters
4. **Testing**: Include test results in your PR description
5. **Security Review**: Highlight any security-related changes

### PR Title Format
Use conventional commit format:
- `feat: add new AI service module`
- `fix: resolve parameter validation issue`
- `docs: update deployment examples`
- `security: enhance encryption options`

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Security enhancement

## Testing
- [ ] Bicep compilation successful
- [ ] ARM validation passed
- [ ] Deployment tested
- [ ] Documentation updated

## Security Considerations
Describe any security implications

## Checklist
- [ ] Code follows project standards
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## 🔒 Security Guidelines

### Sensitive Information
- ❌ Never commit secrets, API keys, or credentials
- ❌ Avoid hardcoded resource names that might conflict
- ✅ Use parameter files for environment-specific values
- ✅ Use Azure Key Vault references for secrets

### Resource Security
- ✅ Default to most secure configuration
- ✅ Make security features opt-out, not opt-in
- ✅ Include security parameter descriptions
- ✅ Implement network isolation by default

## 📚 Resources

- [Azure Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Security Best Practices](https://docs.microsoft.com/azure/security/)
- [Azure Well-Architected Framework](https://docs.microsoft.com/azure/architecture/framework/)
- [Azure AI Services Documentation](https://docs.microsoft.com/azure/cognitive-services/)

## 💬 Support

- Create an issue for bugs or feature requests
- Join discussions in the Issues section
- Review existing modules for examples
- Follow the project's coding standards

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as this project.

---

Thank you for contributing to Azure AI Bicep Modules! 🚀
