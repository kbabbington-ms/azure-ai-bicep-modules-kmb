# Azure AI Bicep Modules - Documentation Standard

## Overview
This document defines the comprehensive documentation standard for all Bicep (.bicep) and parameter (.json) files in the Azure AI Bicep Modules project. This standard ensures consistency, security awareness, and enterprise-grade documentation across all modules.

## Documentation Standard Requirements

### 1. File Header Structure
Every Bicep file must start with a comprehensive header following this format:

```bicep
// ============================================================================
// [Module Name] - Enterprise Security Configuration
// ============================================================================
// Version: [X.Y]
// Last Modified: [YYYY-MM-DD]
// Description: [Comprehensive description of module purpose and capabilities]
// ============================================================================
```

### 2. Metadata Section
Include metadata for proper module identification:

```bicep
metadata name = '[Module Display Name]'
metadata description = '[Detailed description]'
metadata author = 'Azure AI Platform Team'
metadata version = '[X.Y.Z]'
```

### 3. Parameter Documentation Format
Every parameter must include:

1. **Comprehensive description**: Explaining purpose, usage, and impact
2. **Context explanation**: How it fits into the overall architecture
3. **Security enhancement annotation**: When applicable, using 🔒 prefix
4. **Validation decorators**: Appropriate constraints and allowed values
5. **Default values**: Secure defaults when possible

Example format:
```bicep
// [Detailed explanation of parameter purpose and usage context]
// [Additional context about when/why this would be used]
// 🔒 SECURITY ENHANCEMENT: [Security implications and recommendations]
@description('[Concise description for Azure portal]')
@minLength(X) // When applicable
@maxLength(Y) // When applicable
@allowed(['value1', 'value2']) // When applicable
param parameterName string = 'secureDefault'
```

### 4. Required Parameter Categories
All modules must include ALL possible parameters, organized in these sections:

1. **BASIC CONFIGURATION PARAMETERS**
   - Resource names, location, environment, tags
   
2. **SERVICE-SPECIFIC CONFIGURATION**
   - Core service settings, SKUs, features
   
3. **IDENTITY CONFIGURATION**
   - Managed identity settings, authentication
   
4. **ENCRYPTION CONFIGURATION**
   - Customer-managed keys, encryption settings
   
5. **NETWORK CONFIGURATION**
   - VNet integration, public access, firewall rules
   
6. **PRIVATE ENDPOINT CONFIGURATION**
   - Private connectivity settings
   
7. **MONITORING AND DIAGNOSTICS**
   - Logging, metrics, diagnostic settings
   
8. **RBAC CONFIGURATION**
   - Role assignments, access control

### 5. Security Enhancement Requirements
- Mark ALL security-related parameters with 🔒 SECURITY ENHANCEMENT
- Provide secure defaults for all parameters
- Include security context and recommendations
- Document compliance implications (SOC2, HIPAA, GDPR, etc.)

### 6. Section Organization
Use clear section separators:
```bicep
// ============================================================================
// [SECTION NAME]
// ============================================================================
```

### 7. Comments and Inline Documentation
- Explain complex logic and business rules
- Document dependencies and prerequisites
- Include links to Azure documentation when relevant
- Explain security implications of choices

### 8. Variable Documentation
Document complex variables with purpose and derivation:
```bicep
// [Explanation of variable purpose and how it's derived]
var complexVariable = [logic]
```

### 9. Resource Documentation
Each resource should include:
- Purpose explanation
- Dependencies
- Security configurations
- Integration points

### 10. Output Documentation
All outputs must include:
- Clear description of what's returned
- When the output would be used
- Security considerations for exposed values

## JSON Parameter File Standards

### 1. File Header
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "_metadata": {
    "description": "[Module Name] - Production-ready parameters with enterprise security defaults",
    "author": "Azure AI Platform Team",
    "version": "1.0.0",
    "lastModified": "YYYY-MM-DD"
  },
  "parameters": {
    // Parameters with comprehensive documentation
  }
}
```

### 2. Parameter Documentation
Each parameter should include inline comments explaining:
- Purpose and usage
- Security implications
- When to modify from defaults

## Implementation Checklist

For each module, verify:
- [ ] Comprehensive file header with version and description
- [ ] All possible parameters included (not just mandatory ones)
- [ ] Security enhancement annotations for relevant parameters
- [ ] Proper parameter organization in logical sections
- [ ] Secure default values
- [ ] Comprehensive descriptions for all parameters
- [ ] Proper validation decorators
- [ ] Clear section separators
- [ ] Inline documentation for complex logic
- [ ] Output documentation
- [ ] JSON parameter file with proper structure

## Security Documentation Requirements

### Security Classification
Every module must document:
- Data classification level (Public, Internal, Confidential, Restricted)
- Compliance frameworks supported (SOC2, HIPAA, GDPR, etc.)
- Security controls implemented
- Required security configurations

### Security Parameters
All security-related parameters must:
- Use 🔒 SECURITY ENHANCEMENT prefix
- Explain security implications
- Provide secure defaults
- Document compliance impact
- Include threat mitigation details

This standard ensures that all modules provide enterprise-grade documentation, comprehensive parameter coverage, and clear security guidance for production deployments.
