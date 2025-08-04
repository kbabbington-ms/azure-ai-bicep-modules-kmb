# Azure AI Bicep Modules - Testing Framework

This directory contains comprehensive testing tools and validation scripts for the Azure AI Bicep modules framework.

## 🧪 Testing Suite Overview

### Core Validation Tools

#### 1. Template Validation (`validate-templates.sh` / `validate-templates.ps1`)
- **Purpose**: Comprehensive validation of Bicep templates, policies, and configurations
- **Features**:
  - Bicep syntax validation
  - Parameter file validation
  - Security pattern analysis
  - Compliance checking
  - Documentation validation
  - Performance pattern validation
  - Policy template validation

#### 2. Security Testing (`test-security.sh` / `test-security.ps1`)
- **Purpose**: Specialized security and compliance testing
- **Features**:
  - Azure Security Benchmark validation
  - CIS Controls compliance checking
  - NIST Framework alignment
  - Custom security policy validation

#### 3. Performance Testing (`test-performance.sh` / `test-performance.ps1`)
- **Purpose**: Performance and optimization validation
- **Features**:
  - Resource optimization analysis
  - Monitoring configuration validation
  - Scaling pattern verification
  - Cost optimization checks

## 🚀 Quick Start

### Prerequisites
- Azure CLI installed and configured
- Bicep CLI extension installed
- PowerShell 5.1+ or Bash 4.0+
- jq (for JSON processing)

### Basic Usage

#### Linux/macOS
```bash
# Run comprehensive validation
./scripts/validation/validate-templates.sh

# Run with help
./scripts/validation/validate-templates.sh --help

# Run security-focused tests
./scripts/validation/test-security.sh

# Run performance tests
./scripts/validation/test-performance.sh
```

#### Windows (PowerShell)
```powershell
# Run comprehensive validation
.\scripts\validation\validate-templates.ps1

# Run with help
.\scripts\validation\validate-templates.ps1 -Help

# Run with detailed output
.\scripts\validation\validate-templates.ps1 -Detailed

# Specify custom log path
.\scripts\validation\validate-templates.ps1 -LogPath "C:\logs\validation.log"
```

## 📋 Validation Categories

### 1. 🔍 Bicep Syntax Validation
- Template compilation testing
- Syntax error detection
- ARM template generation validation
- Cross-platform compatibility checks

### 2. 📋 Parameter Validation
- JSON syntax validation
- Required parameter presence
- Parameter type validation
- Environment-specific parameter checking

### 3. 🛡️ Security Pattern Validation
- Private endpoint configurations
- Managed identity usage
- Diagnostic settings validation
- Encryption pattern verification
- Network access restrictions

### 4. 📚 Documentation Validation
- README file presence and quality
- Module documentation completeness
- Environment documentation
- API documentation validation

### 5. 📁 Structure Validation
- Folder organization compliance
- Naming convention adherence
- Required directory presence
- File organization standards

### 6. ⚡ Performance Pattern Validation
- Resource optimization patterns
- Monitoring and alerting configurations
- Caching implementation
- Autoscaling configurations

### 7. 📋 Policy Validation
- Azure Policy template syntax
- Policy rule validation
- Initiative template validation
- Compliance pattern checking

## 📊 Quality Scoring

The validation framework provides a comprehensive quality score based on:

### Scoring Criteria
- **10/10**: Perfect - All tests pass, no warnings
- **9/10**: Excellent - All tests pass with minor recommendations
- **8/10**: Good - Minor issues, mostly warnings
- **7/10**: Acceptable - Some failures, needs improvement
- **6/10 and below**: Needs significant work

### Score Components
- **Syntax Validation** (20%)
- **Security Compliance** (25%)
- **Documentation Quality** (15%)
- **Structure Compliance** (15%)
- **Performance Optimization** (15%)
- **Policy Compliance** (10%)

## 🔧 Configuration

### Environment Variables
```bash
# Set custom validation timeout
export VALIDATION_TIMEOUT=300

# Set detailed logging
export VALIDATION_DETAILED=true

# Set custom temp directory
export VALIDATION_TEMP_DIR="/tmp/validation"
```

### Custom Validation Rules
Create custom validation rules by extending the validation scripts:

```bash
# Custom validation function
validate_custom_patterns() {
    # Your custom validation logic here
    test_start "Custom validation"
    # Implementation
}
```

## 📝 Validation Reports

### Report Structure
```
📊 Validation Summary
================================================================
🧪 Total Tests: 45
✅ Passed: 42
❌ Failed: 1
⚠️  Warnings: 2

📈 Success Rate: 93%
📝 Log File: /logs/validation-20250802-143052.log
⏱️ Completed: 2025-08-02 14:30:52

🎯 Repository Quality Score: 9/10
```

### Log Files
- Detailed execution logs
- Error messages and stack traces
- Recommendations for improvement
- Performance metrics

## 🚀 CI/CD Integration

### GitHub Actions
The validation scripts integrate seamlessly with the CI/CD workflows:

```yaml
- name: Validate Templates
  run: |
    chmod +x ./scripts/validation/validate-templates.sh
    ./scripts/validation/validate-templates.sh
```

### Azure DevOps
```yaml
- task: Bash@3
  displayName: 'Validate Bicep Templates'
  inputs:
    targetType: 'filePath'
    filePath: './scripts/validation/validate-templates.sh'
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Azure CLI Not Found
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

#### 2. Bicep CLI Missing
```bash
# Install Bicep CLI
az bicep install
```

#### 3. Permission Issues
```bash
# Make scripts executable
chmod +x ./scripts/validation/*.sh
```

#### 4. PowerShell Execution Policy
```powershell
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Debug Mode
Run validation with debug information:

```bash
# Enable debug mode
export DEBUG=true
./scripts/validation/validate-templates.sh

# PowerShell debug mode
$DebugPreference = "Continue"
.\scripts\validation\validate-templates.ps1 -Detailed
```

## 📚 Best Practices

### 1. Regular Validation
- Run validation before commits
- Include validation in CI/CD pipelines
- Schedule regular automated validation

### 2. Incremental Testing
- Test individual modules during development
- Validate parameters for each environment
- Test security configurations thoroughly

### 3. Documentation Maintenance
- Keep README files updated
- Document validation exceptions
- Maintain change logs

### 4. Performance Monitoring
- Monitor validation execution time
- Track quality score trends
- Set up alerts for validation failures

## 🤝 Contributing

To contribute to the testing framework:

1. Follow the existing script structure
2. Add comprehensive error handling
3. Include detailed logging
4. Update documentation
5. Test on multiple platforms

### Adding New Validations
```bash
# Template for new validation function
validate_new_feature() {
    log "🔍 Validating new feature..."
    separator
    
    test_start "New feature validation"
    
    # Your validation logic here
    if [[ condition ]]; then
        success "New feature validation passed"
    else
        error "New feature validation failed"
    fi
}
```

## 📧 Support

For issues with the validation framework:
- Check the troubleshooting section
- Review log files for detailed error information
- Submit issues through the project repository
- Contact the DevOps team for assistance

---

*This testing framework ensures enterprise-grade quality and compliance for Azure AI infrastructure deployments.*
