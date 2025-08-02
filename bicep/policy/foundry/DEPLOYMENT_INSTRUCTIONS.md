
# Deployment Instructions for SFI-W1-Ini-Foundry Policy Initiative and Definitions

## Prerequisites
- Azure CLI installed and logged in
- Sufficient permissions to create policy definitions and initiatives at the subscription scope
- Bicep CLI installed (if deploying via Bicep)

## Steps

1. **Deploy Policy Definitions**
   Deploy each policy definition file to your subscription:
   ```pwsh
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-RequireCreatedByTag.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-RestrictPublicNetworkAccess.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-RequireDiagnosticLogging.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-EnforceManagedIdentityUsage.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-RequireEncryptionAtRest.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-RequireKeyVaultPrivateEndpoint.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-AllowedAISku.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-ModelVersionControl.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-DataResidency.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-PrivateEndpointAI.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-DiagnosticLoggingAI.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-KeyVaultAISecrets.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-TaggingAI.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-ManagedIdentityAI.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-EncryptionTransitAI.bicep
   az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-LogRetentionAI.bicep
   ```
   Replace `<location>` with your Azure region (e.g., `eastus`).

2. **Deploy Policy Initiative**
   Deploy the initiative file:
   ```pwsh
   az deployment sub create --location <location> --template-file SFI-W1-Ini-Foundry.bicep
   ```

3. **Assign Initiative to a Scope**
   After deployment, assign the initiative to a subscription or resource group as needed:
   ```pwsh
   az policy set-definition list --name SFI-W1-Ini-Foundry
   az policy assignment create --name SFI-W1-Ini-Foundry --policy-set-definition SFI-W1-Ini-Foundry --scope /subscriptions/<subscriptionId>
   ```
   Replace `<subscriptionId>` with your Azure subscription ID.

## Notes
- Ensure all policy definition names and references match the new naming convention (`SFI-W1-Def-Foundry-*`).
- You may need to update parameters if your environment requires customization.
- For troubleshooting, use `az policy definition list` and `az policy set-definition list` to verify deployments.
