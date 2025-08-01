# 🔒 Azure AI Foundry - Enterprise Security Parameter Guide

## 📋 Overview

This document provides detailed guidance on the security-enhanced parameters in the Azure AI Foundry Bicep template, highlighting optional security enhancements for enterprise deployments.

## 🔐 Security Enhancement Categories

### 🏛️ **FOUNDATIONAL SECURITY**
Essential security controls that should be enabled in all enterprise deployments.

### 🛡️ **ENHANCED SECURITY**
Advanced security features for high-security environments and compliance requirements.

### ⚠️ **OPERATIONAL SECURITY**
Security considerations for day-to-day operations and maintenance.

---

## 📊 Parameter Security Matrix

| Parameter Category | Security Level | Enterprise Recommendation |
|-------------------|----------------|---------------------------|
| **HBI Workspace** | 🏛️ Foundational | ✅ Always Enable |
| **Public Network Access** | 🏛️ Foundational | ❌ Always Disable |
| **Customer-Managed Encryption** | 🛡️ Enhanced | ✅ Always Enable |
| **Private Endpoints** | 🏛️ Foundational | ✅ Always Enable |
| **Managed Network** | 🛡️ Enhanced | ✅ Enable for Zero-Trust |
| **Diagnostic Logging** | ⚠️ Operational | ✅ Always Enable |

---

## 🔒 Critical Security Parameters

### **High Business Impact (HBI) Workspace**
```bicep
param hbiWorkspace bool = true  // 🔒 ALWAYS ENABLE for enterprise
```
**Security Impact**: Enables enhanced data protection, additional encryption, and stricter access controls.
**Enterprise Requirement**: Essential for sensitive data and compliance requirements (HIPAA, GDPR, SOC2).

### **Public Network Access Control**
```bicep
param publicNetworkAccess string = 'Disabled'  // 🔒 ALWAYS DISABLE for enterprise
param allowPublicAccessWhenBehindVnet bool = false  // 🔒 ALWAYS DISABLE
```
**Security Impact**: Eliminates internet exposure and enforces private connectivity.
**Enterprise Requirement**: Required for zero-trust network architecture.

### **Customer-Managed Encryption**
```bicep
param enableCustomerManagedEncryption bool = true  // 🔒 ALWAYS ENABLE
param encryptionKeyIdentifier string = 'https://kv.vault.azure.net/keys/key/version'
```
**Security Impact**: Provides customer control over encryption keys and enhanced compliance.
**Enterprise Requirement**: Required for data sovereignty and advanced compliance frameworks.

---

## 🌐 Network Security Configuration

### **Private Endpoints**
```bicep
param enablePrivateEndpoints bool = true  // 🔒 ALWAYS ENABLE
param privateDnsZoneIds object = {
  api: '/subscriptions/.../privateDnsZones/privatelink.api.azureml.ms'
  notebooks: '/subscriptions/.../privateDnsZones/privatelink.notebooks.azure.net'
  inference: '/subscriptions/.../privateDnsZones/privatelink.inference.ml.azure.com'
}
```
**Security Impact**: Eliminates internet exposure and provides private connectivity.
**Enterprise Requirement**: Essential for network isolation and data protection.

### **Managed Network with Zero-Trust**
```bicep
param enableManagedNetwork bool = true  // 🔒 ENABLE for zero-trust
param managedNetworkIsolationMode string = 'AllowOnlyApprovedOutbound'  // 🔒 MOST SECURE
```
**Security Impact**: Controls outbound traffic and prevents data exfiltration.
**Enterprise Requirement**: Required for zero-trust network architecture.

---

## 👥 RBAC Security Guidelines

### **Role-Based Access Control**
```bicep
param enableRbacAssignments bool = true  // 🔒 ALWAYS ENABLE
```

### **Security Best Practices for RBAC**:

#### **Workspace Administrators**
- 🔒 **Security Enhancement**: Limit to essential personnel
- 🔒 **Use Azure AD PIM**: Implement time-bound access
- 🔒 **Monitor Access**: Enable activity logging and alerting

#### **AI Developers**
- 🔒 **Principle of Least Privilege**: Grant only necessary AI development permissions
- 🔒 **Data Classification**: Restrict access based on data sensitivity
- 🔒 **Regular Review**: Conduct quarterly access reviews

#### **Data Scientists**
- 🔒 **Need-to-Know Basis**: Grant access based on project requirements
- 🔒 **Data Governance**: Ensure compliance with data handling policies
- 🔒 **Audit Trail**: Monitor data access and usage patterns

---

## 📊 Monitoring and Compliance

### **Comprehensive Diagnostic Logging**
```bicep
param enableDiagnostics bool = true  // 🔒 ALWAYS ENABLE
param diagnosticLogsRetentionInDays int = 90  // 🔒 SET BASED ON COMPLIANCE
```

### **Security Monitoring Categories**:
- ✅ **AI Model Access**: `ModelsReadEvent`, `ModelsActionEvent`
- ✅ **Compute Security**: `AmlComputeClusterEvent`, `AmlComputeJobEvent`
- ✅ **Deployment Security**: `DeploymentEventACI`, `DeploymentEventAKS`
- ✅ **Inference Security**: `InferencingOperationAKS`, `InferencingOperationACI`

---

## 🔧 Advanced Security Features

### **Feature Store Security**
```bicep
param enableFeatureStore bool = false  // Enable with private endpoints
```
**Security Enhancement**: Use with private endpoints and strict access controls for feature data protection.

### **Serverless Compute Security**
```bicep
param serverlessComputeNoPublicIP bool = true  // 🔒 ALWAYS ENABLE
param serverlessComputeCustomSubnet string = '/subscriptions/.../subnets/private-subnet'
```
**Security Enhancement**: Ensures compute nodes are not directly accessible from the internet.

### **AI Service Connections**
```bicep
param workspaceConnections array = []  // Use managed identity authentication
param sharedPrivateLinkResources array = []  // Enable private connectivity
```
**Security Enhancement**: Use managed identity authentication and private connectivity for all AI service integrations.

---

## 📋 Security Deployment Checklist

### **Pre-Deployment Security Validation**
- [ ] ✅ HBI workspace enabled
- [ ] ❌ Public network access disabled
- [ ] 🔑 Customer-managed encryption configured
- [ ] 🌐 Private endpoints configured with DNS zones
- [ ] 🛡️ Managed network with approved outbound rules only
- [ ] 👥 RBAC roles defined with least privilege principles
- [ ] 📊 Diagnostic logging enabled with appropriate retention
- [ ] 🔧 Advanced security features configured as needed

### **Post-Deployment Security Verification**
- [ ] 🔍 Verify no public internet access
- [ ] 🔑 Confirm encryption with customer keys
- [ ] 🌐 Test private endpoint connectivity
- [ ] 📊 Validate diagnostic log collection
- [ ] 👥 Verify RBAC assignments and access controls
- [ ] 🚨 Configure security alerts and monitoring

---

## 🎯 Security Recommendations by Environment

### **Development Environment**
- ✅ Enable HBI workspace
- ✅ Disable public access
- ⚠️ Consider simplified networking for development velocity
- ✅ Enable full diagnostic logging

### **Testing Environment**
- ✅ Enable all security features
- ✅ Mirror production security configuration
- ✅ Use customer-managed encryption
- ✅ Enable private endpoints

### **Production Environment**
- ✅ Enable ALL security enhancements
- ✅ Use HSM-backed encryption keys
- ✅ Implement zero-trust networking
- ✅ Configure comprehensive monitoring
- ✅ Use Azure AD PIM for administrative access
- ✅ Implement automated security scanning

---

## 🔍 Security Monitoring and Alerting

### **Critical Security Alerts**
1. **Unauthorized Access Attempts**
2. **Encryption Key Access Anomalies**
3. **Network Security Rule Violations**
4. **Unusual AI Model Access Patterns**
5. **Compute Resource Anomalies**

### **Compliance Reporting**
- **GDPR**: Data processing and retention controls
- **HIPAA**: Healthcare data protection measures
- **SOC2**: Security controls and monitoring
- **ISO27001**: Information security management

---

This comprehensive security guide ensures your Azure AI Foundry deployment meets enterprise security requirements and compliance standards.
