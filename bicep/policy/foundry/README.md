# SFI-W1-Ini-Foundry Policy Initiative for Azure AI Foundry

## Overview
This repository contains Bicep modules for SFI compliance policy definitions and a policy initiative for Azure AI Foundry workloads. All definitions follow the `SFI-W1-Def-Foundry-*` naming convention and are grouped in the initiative `SFI-W1-Ini-Foundry`.

## Policy Definitions Included
- Require CreatedBy Tag
- Restrict Public Network Access
- Require Diagnostic Logging
- Enforce Managed Identity Usage
- Require Encryption at Rest
- Require Key Vault Private Endpoint
- Allowed AI Service SKUs
- AI Model Version Control
- Data Residency Enforcement
- Private Endpoint Enforcement for AI Services
- Mandatory Diagnostic Logging for AI Services
- Key Vault Usage for AI Secrets
- Resource Tagging for AI Workloads
- Managed Identity Enforcement for AI Services
- Encryption of Data in Transit for AI Services
- Minimum Retention for AI Logs

## Deployment
See `DEPLOYMENT_INSTRUCTIONS.md` for step-by-step deployment guidance using Azure CLI and Bicep.

## Customization
You can update parameters in the Bicep files to match your organization's requirements (e.g., allowed SKUs, regions, tags).

## Support
For issues or questions, please open an issue in this repository.
