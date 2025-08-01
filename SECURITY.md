# Security Policy

## Supported Versions

We provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| Previous| :white_check_mark: |
| Older   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly:

### For Security Issues:
1. **DO NOT** create a public GitHub issue
2. **Email** the security team directly (if available)
3. **Include** detailed information about the vulnerability
4. **Provide** steps to reproduce if possible

### What to Include:
- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Suggested remediation (if known)
- Any relevant Azure resource configurations

### Response Timeline:
- **Initial Response**: Within 48 hours
- **Vulnerability Assessment**: Within 1 week
- **Remediation Plan**: Within 2 weeks
- **Security Update Release**: Based on severity

## Security Best Practices

When using these Bicep modules:

### 1. **Network Security**
- Always use private endpoints in production
- Implement network access controls
- Review and restrict IP allowlists
- Enable VNet integration where applicable

### 2. **Identity and Access Management**
- Use Azure AD authentication over API keys
- Implement principle of least privilege
- Regularly review RBAC assignments
- Use managed identities for service authentication

### 3. **Data Protection**
- Enable customer-managed encryption for sensitive data
- Implement proper key management practices
- Consider data residency requirements
- Enable audit logging and monitoring

### 4. **Configuration Security**
- Review all parameters before deployment
- Use secure parameter handling for secrets
- Implement proper secret management
- Regularly update to latest module versions

### 5. **Monitoring and Compliance**
- Enable comprehensive logging
- Set up security alerting
- Perform regular security assessments
- Maintain compliance documentation

## Security Features

All modules in this repository implement:

- **Zero-trust architecture** by default
- **Private networking** configurations
- **Managed identity** authentication
- **Comprehensive audit logging**
- **Customer-managed encryption** options
- **RBAC integration** with appropriate roles
- **Network access controls** and IP restrictions

## Vulnerability Disclosure

We follow responsible disclosure practices:

1. **Assessment** of reported vulnerabilities
2. **Coordination** with Azure security teams if needed
3. **Development** of patches and mitigations
4. **Testing** of security fixes
5. **Release** of security updates
6. **Public disclosure** after remediation

## Security Updates

Security updates will be released as:
- **Patch releases** for minor security fixes
- **Minor releases** for significant security enhancements
- **Major releases** for breaking security changes

## Contact

For security-related questions or concerns:
- Review this security policy
- Check existing GitHub discussions
- Contact repository maintainers
- Follow responsible disclosure practices

---

**Remember**: Always review and test security configurations in your specific environment before production deployment.
