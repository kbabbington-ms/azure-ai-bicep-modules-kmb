#!/bin/bash

# Set deployment parameters
RESOURCE_GROUP="rg-ai-enclave-network-dev"
LOCATION="eastus2"
TEMPLATE_FILE="./main.bicep"
PARAMETERS_FILE="./main.parameters.json"

# Check if resource group exists, create if it doesn't
echo "Checking if resource group exists..."
if ! az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo "Creating resource group: $RESOURCE_GROUP"
    az group create --name $RESOURCE_GROUP --location $LOCATION
fi

# Deploy the virtual network module
echo "Deploying Virtual Network module..."
DEPLOYMENT_OUTPUT=$(az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file $TEMPLATE_FILE \
    --parameters @$PARAMETERS_FILE \
    --verbose \
    --output json)

# Check deployment status
DEPLOYMENT_STATE=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.provisioningState')

if [ "$DEPLOYMENT_STATE" = "Succeeded" ]; then
    echo "Virtual Network deployment completed successfully!"
    HUB_VNET_ID=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.hubVNetId.value')
    BASTION_FQDN=$(echo $DEPLOYMENT_OUTPUT | jq -r '.properties.outputs.bastionFqdn.value')
    echo "Hub VNet ID: $HUB_VNET_ID"
    echo "Bastion FQDN: $BASTION_FQDN"
else
    echo "Deployment failed with state: $DEPLOYMENT_STATE"
    exit 1
fi
