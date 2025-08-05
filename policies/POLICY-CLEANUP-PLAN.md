# Azure Policy Folder Cleanup Plan

**Date**: 2024-12-19  
**Purpose**: Clean up policy folder structure to remove outdated files and enforce SFI-W1 standards  

## Executive Summary

The current policy folder structure contains several files and directories that do not follow the established SFI-W1 naming conventions or are redundant/outdated. This cleanup will ensure consistency, maintainability, and alignment with the comprehensive policy framework we've implemented.

## Files and Directories to Remove

### 1. Non-Standard Naming Convention Files
These files don't follow the `SFI-W1-Def-[Service]-[PolicyName].bicep` pattern:

#### Remove Completely:
```
policies/definitions/ai-workflows/require-private-endpoints.bicep
policies/definitions/application-gateway/require-waf-enabled.bicep
policies/definitions/backup-recovery/require-backup-protection.bicep
policies/definitions/copilot-studio/require-private-endpoints.bicep
policies/definitions/firewall/require-premium-sku.bicep
```

**Rationale**: These files use outdated naming conventions and lack the comprehensive structure of our SFI-W1 compliant policies. They appear to be preliminary/draft versions that are superseded by our systematic implementation.

### 2. Incorrect "Foundry" Service Naming
These files incorrectly use "Foundry" as the service name instead of proper Azure service names:

#### Remove from general/ directory:
```
policies/definitions/general/SFI-W1-Def-Foundry-AdvancedMonitoring.bicep
policies/definitions/general/SFI-W1-Def-Foundry-EnforceManagedIdentityUsage.bicep
policies/definitions/general/SFI-W1-Def-Foundry-RequireCreatedByTag.bicep
policies/definitions/general/SFI-W1-Def-Foundry-RequireDiagnosticLogging.bicep
policies/definitions/general/SFI-W1-Def-Foundry-RequireEncryptionAtRest.bicep
policies/definitions/general/SFI-W1-Def-Foundry-RestrictPublicNetworkAccess.bicep
```

#### Remove incorrect service naming:
```
policies/definitions/content-safety/SFI-W1-Def-Foundry-ContentSafety.bicep
policies/definitions/video-indexer/SFI-W1-Def-Foundry-VideoIndexer.bicep
policies/definitions/logic-apps/SFI-W1-Def-Foundry-LogicAppsAIWorkflows.bicep
```

**Rationale**: "Foundry" is not a valid Azure service name. These policies either duplicate functionality covered by our comprehensive service-specific policies or address services outside our core Azure AI focus.

### 3. Outdated Initiative Files
Remove non-standard initiative naming:

```
policies/initiatives/general/azure-ai-master-sfi-compliance.bicep
policies/initiatives/compute/SFI-W1-Initiative-Compute.bicep
```

**Rationale**: These don't follow the `SFI-W1-Ini-[Service].bicep` naming convention and may contain outdated approaches.

### 4. Empty or Single-File Directories
After removing files, these directories may become empty or contain only single outdated policies:

#### Directories to Remove Completely:
```
policies/definitions/ai-workflows/
policies/definitions/application-gateway/
policies/definitions/backup-recovery/
policies/definitions/copilot-studio/
policies/definitions/firewall/
policies/definitions/general/
policies/definitions/content-safety/
policies/definitions/video-indexer/
policies/definitions/logic-apps/
```

#### Initiative directories to remove:
```
policies/initiatives/content-safety/
policies/initiatives/general/
policies/initiatives/compute/
policies/initiatives/logic-apps/
policies/initiatives/video-indexer/
```

**Rationale**: These directories either contain only outdated files or address services outside our core Azure AI services focus (OpenAI, Machine Learning, Cognitive Search, Document Intelligence, Cognitive Services).

## Files and Directories to Keep

### Core Azure AI Services (Fully Implemented)
✅ **Keep - Comprehensive and Standards Compliant:**
```
policies/definitions/azure-openai/          (5 policies + README)
policies/definitions/machine-learning/      (6 policies + README)  
policies/definitions/cognitive-search/      (6 policies + README)
policies/definitions/document-intelligence/ (5 policies + README)
policies/definitions/cognitive-services/    (7 policies + README)

policies/initiatives/azure-openai/          (SFI-W1-Ini-OpenAI.bicep)
policies/initiatives/machine-learning/      (SFI-W1-Ini-ML.bicep)
policies/initiatives/cognitive-search/      (SFI-W1-Ini-Search.bicep)
policies/initiatives/document-intelligence/ (SFI-W1-Ini-DocIntel.bicep)
policies/initiatives/cognitive-services/    (SFI-W1-Ini-CogSvc.bicep)
```

### Supporting Infrastructure (Standards Compliant)
✅ **Keep - Follow SFI-W1 Standards:**
```
policies/definitions/storage/
policies/definitions/key-vault/
policies/definitions/monitoring/
policies/definitions/identity-access/
policies/definitions/virtual-network/
policies/definitions/data-services/
policies/definitions/compute/            (if SFI-W1 compliant)
policies/definitions/container-infrastructure/

policies/initiatives/storage/
policies/initiatives/key-vault/
policies/initiatives/data-services/
policies/initiatives/virtual-network/
policies/initiatives/container-infrastructure/
```

### AI Foundry (Special Consideration)
🔍 **Review - May Keep if Standards Compliant:**
```
policies/definitions/ai-foundry/         (10 policies - need review)
policies/initiatives/ai-foundry/         (need review)
```
**Note**: These appear to follow SFI-W1 naming but use "Foundry" service name. Need to verify if Azure AI Foundry is a legitimate service or if these should be reorganized.

## Cleanup Impact Assessment

### Benefits of Cleanup:
1. **Consistency**: All remaining policies follow SFI-W1 naming conventions
2. **Maintainability**: Reduced complexity with focused service coverage
3. **Quality**: Only comprehensive, well-documented policies remain
4. **Focus**: Emphasis on core Azure AI services with enterprise requirements

### Risk Mitigation:
1. **Backup**: Current folder structure will be documented before cleanup
2. **Validation**: No active dependencies on files to be removed
3. **Scope**: Cleanup focuses on outdated/non-compliant files only

## Implementation Steps

### Phase 1: Backup and Documentation
1. Document current folder structure
2. Verify no active policy assignments reference files to be removed
3. Create backup of current state

### Phase 2: Remove Non-Compliant Files
1. Remove individual files with non-standard naming
2. Remove directories with incorrect "Foundry" service naming
3. Remove outdated initiative files

### Phase 3: Directory Cleanup
1. Remove empty directories
2. Remove directories containing only outdated files
3. Consolidate remaining structure

### Phase 4: Validation
1. Verify all remaining files follow SFI-W1 standards
2. Confirm directory structure is clean and organized
3. Update main README with clean structure

## Post-Cleanup Structure

After cleanup, the policy folder structure will be:

```
policies/
├── definitions/
│   ├── azure-openai/              ✅ Complete (5 policies + README)
│   ├── machine-learning/          ✅ Complete (6 policies + README)
│   ├── cognitive-search/          ✅ Complete (6 policies + README)
│   ├── document-intelligence/     ✅ Complete (5 policies + README)
│   ├── cognitive-services/        ✅ Complete (7 policies + README)
│   ├── storage/                   ✅ Supporting infrastructure
│   ├── key-vault/                 ✅ Supporting infrastructure
│   ├── monitoring/                ✅ Supporting infrastructure
│   ├── identity-access/           ✅ Supporting infrastructure
│   ├── virtual-network/           ✅ Supporting infrastructure
│   ├── data-services/             ✅ Supporting infrastructure
│   └── container-infrastructure/  ✅ Supporting infrastructure
├── initiatives/
│   ├── azure-openai/              ✅ Complete initiative
│   ├── machine-learning/          ✅ Complete initiative
│   ├── cognitive-search/          ✅ Complete initiative
│   ├── document-intelligence/     ✅ Complete initiative
│   ├── cognitive-services/        ✅ Complete initiative
│   └── [supporting service initiatives]
└── [documentation and reports]
```

This cleanup will result in a clean, consistent, and maintainable policy structure focused on our core Azure AI services with comprehensive SFI-W1 compliance.
