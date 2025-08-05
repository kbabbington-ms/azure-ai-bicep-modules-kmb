# Azure Policy Framework - Organized Structure

## Overview

This directory contains a comprehensive **Azure Policy-as-Code** framework organized by resource types for better maintainability, discoverability, and governance. The structure follows enterprise best practices for policy organization and deployment automation.

## Directory Structure

```
AzPolicy/
├── definitions/        # Individual policy definitions (39 policies across 12 categories)
│   ├── ai-foundry/    # Azure AI Foundry policies (10 policies)
│   ├── cognitive-services/ # Cognitive Services policies
│   ├── compute/       # Compute security policies (NEW SFI-W1)
│   ├── container-infrastructure/ # Container & AKS policies (NEW SFI-W1)
│   ├── content-safety/ # Content Safety policies (1 policy)
│   ├── data-services/ # Database SSL/TLS policies (NEW SFI-W1)
│   ├── general/       # Cross-service general policies
│   ├── key-vault/     # Key Vault policies (9 policies)
│   ├── logic-apps/    # Logic Apps policies (1 policy)
│   ├── storage/       # Storage encryption policies (NEW SFI-W1)
│   ├── video-indexer/ # Video Indexer policies
│   └── virtual-network/ # Network security policies (NEW SFI-W1)
├── initiatives/       # Policy initiative bundles (13 initiatives across 12 categories)
│   ├── ai-foundry/    # AI Foundry initiative groupings
│   ├── cognitive-services/ # Cognitive Services initiatives
│   ├── compute/       # Compute security initiative (NEW SFI-W1)
│   ├── container-infrastructure/ # Container infrastructure initiative (NEW SFI-W1)
│   ├── content-safety/ # Content Safety initiatives
│   ├── data-services/ # Data services security initiative (NEW SFI-W1)
│   ├── general/       # General compliance initiatives
│   ├── key-vault/     # Key Vault initiatives
│   ├── logic-apps/    # Logic Apps initiatives
│   ├── storage/       # Storage security initiative (NEW SFI-W1)
│   ├── video-indexer/ # Video Indexer initiatives
│   └── virtual-network/ # Network security initiative (NEW SFI-W1)
├── docs/              # Documentation and guides
│   ├── ai-foundry/    # AI Foundry policy documentation
│   ├── cognitive-services/ # Cognitive Services docs
│   ├── content-safety/ # Content Safety documentation
│   ├── general/       # General policy documentation
│   ├── key-vault/     # Key Vault policy docs
│   ├── logic-apps/    # Logic Apps documentation
│   └── video-indexer/ # Video Indexer documentation
└── scripts/           # Deployment and automation scripts
    ├── ai-foundry/    # AI Foundry deployment scripts
    ├── cognitive-services/ # Cognitive Services scripts
    ├── content-safety/ # Content Safety scripts
    ├── general/       # General deployment scripts
    ├── key-vault/     # Key Vault scripts
    ├── logic-apps/    # Logic Apps scripts
    └── video-indexer/ # Video Indexer scripts
```

## Resource Categories

### **🔥 NEW SFI-W1 Security Categories**

### **Virtual Network** (`virtual-network/`) **[NEW]**
- Zero-trust network architecture
- Private subnet enforcement
- NSG flow logs monitoring
- Network isolation controls

### **Storage** (`storage/`) **[NEW]**
- Encryption at rest and in transit
- Private endpoint enforcement
- Access control restrictions
- Secure data handling

### **Data Services** (`data-services/`) **[NEW]**
- SSL/TLS encryption enforcement
- Database security controls
- Secure connection requirements
- Data protection standards

### **Compute** (`compute/`) **[NEW]**
- Secure boot and trusted launch
- Hardware-level security
- VM and VMSS security controls
- Trusted computing requirements

### **Container Infrastructure** (`container-infrastructure/`) **[NEW]**
- Private registry enforcement
- Supply chain security
- Container image security
- AKS security controls

### **🔧 Existing Categories**

### **AI Foundry** (`ai-foundry/`)
- Core Azure AI platform policies
- Model governance and version control
- Data residency and sovereignty
- AI-specific security controls

### **Cognitive Services** (`cognitive-services/`)
- SKU and pricing tier controls
- Service-specific configurations
- API access management
- Integration policies

### **Content Safety** (`content-safety/`)
- Content moderation policies
- Safety threshold enforcement
- Compliance and reporting
- Content filtering controls

### **Key Vault** (`key-vault/`)
- Secret management policies
- Access control requirements
- Private endpoint enforcement
- Encryption key governance

### **Logic Apps** (`logic-apps/`)
- AI workflow security policies
- Integration governance
- Data flow controls
- Connector restrictions

### **Video Indexer** (`video-indexer/`)
- Video analysis governance
- Privacy and compliance
- Content processing rules
- Storage and retention policies

### **General** (`general/`)
- Cross-service policies
- Tagging requirements
- Network access controls
- Diagnostic logging standards
- Managed identity enforcement

## Policy Naming Convention

### **Policy Definitions**
- Format: `SFI-W1-Def-[ResourceType]-[PolicyName].bicep`
- Example: `SFI-W1-Def-Foundry-RequireCreatedByTag.bicep`

### **Policy Initiatives**
- Format: `SFI-W1-Ini-[ResourceType].bicep`
- Example: `SFI-W1-Ini-Foundry.bicep`

### **Documentation**
- Format: `README-[Component].md`
- Example: `README-ContentSafety.md`

## Deployment Strategy

### **Resource-Specific Deployment**
Each resource category can be deployed independently:

```bash
# Deploy AI Foundry policies only
./scripts/ai-foundry/deploy.sh

# Deploy Cognitive Services policies only
./scripts/cognitive-services/deploy.sh
```

### **Full Framework Deployment**
Deploy all policies across all resource types:

```bash
# Deploy everything (Bash)
./scripts/general/deploy-all.sh

# Deploy everything (PowerShell)
./scripts/general/Deploy-All.ps1
```

## Migration from Legacy Structure

This organized structure provides comprehensive policy governance for all Azure AI services with proper categorization and enterprise-grade organization.

## Benefits of Structure

1. **🎯 Resource-Focused Organization**: Easy to find policies for specific Azure services
2. **📦 Modular Deployment**: Deploy only the policies you need
3. **📚 Clear Documentation**: Service-specific documentation and guides
4. **🚀 Automated Deployment**: Resource-specific deployment scripts
5. **🔄 Easier Maintenance**: Logical grouping reduces complexity
6. **👥 Team Collaboration**: Teams can own specific resource areas

## Compliance Framework

This structure supports **SFI-W1 (Secure Foundational Infrastructure - Workload 1)** compliance with:

- ✅ **Network Security**: Private endpoint requirements, public access restrictions
- ✅ **Identity & Access**: Managed identity enforcement, RBAC controls
- ✅ **Data Protection**: Encryption at rest and in transit, Key Vault integration
- ✅ **Monitoring & Logging**: Diagnostic logging, audit trail requirements
- ✅ **Governance**: Resource tagging, naming conventions, SKU restrictions
- ✅ **Compliance**: Data residency, retention policies, version control

---

**Status**: 🏗️ **Structure Created** - Ready for file migration and organization
**Last Updated**: August 2, 2025
**Version**: 1.0.0
