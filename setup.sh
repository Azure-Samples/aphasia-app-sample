#!/bin/bash

set -e
set -o pipefail

# Enable debugging
set -x

# Generate a suffix based on the current date and time (mmddyyyyhhmm)
SUFFIX=$(date +"%m%d%Y%H%M")
echo "Generated SUFFIX: $SUFFIX"

RES_REGION=${RES_REGION:-"westus"}
RES_GROUP=${RES_GROUP:-"rg-hack-$SUFFIX"}
CV_ACCOUNT_NAME=${CV_ACCOUNT_NAME:-"cv-account-$SUFFIX"}
SS_ACCOUNT_NAME=${SS_ACCOUNT_NAME:-"ss-account-$SUFFIX"}
OPENAI_ACCOUNT_NAME=${OPENAI_ACCOUNT_NAME:-"oai-account-$SUFFIX"}
OPENAI_DEPLOYMENT_NAME=${OPENAI_DEPLOYMENT_NAME:-"oai-deployment-$SUFFIX"}
OPENAI_MODEL_NAME=${OPENAI_MODEL_NAME:-"gpt-4"}
OPENAI_MODEL_VERSION=${OPENAI_MODEL_VERSION:-"turbo-2024-04-09"}

# Create the resource group
az group create \
    --name $RES_GROUP \
    --location $RES_REGION

# Create Computer Vision resource
az cognitiveservices account create \
    --resource-group $RES_GROUP \
    --name $CV_ACCOUNT_NAME \
    --location $RES_REGION \
    --kind ComputerVision \
    --sku S1 \
    --yes

# Create Speech Services resource
az cognitiveservices account create \
  --name $SS_ACCOUNT_NAME \
  --resource-group $RES_GROUP \
  --kind SpeechServices \
  --sku S0 \
  --location $RES_REGION \
  --yes

# Create OpenAI resource
az cognitiveservices account create \
    --name $OPENAI_ACCOUNT_NAME \
    --resource-group $RES_GROUP \
    --kind OpenAI \
    --sku S0 \
    --location $RES_REGION \
    --yes
 
# Deploy the model for chatcompletion
az cognitiveservices account deployment create \
    --resource-group $RES_GROUP \
    --name $OPENAI_ACCOUNT_NAME \
    --deployment-name $OPENAI_DEPLOYMENT_NAME \
    --model-name $OPENAI_MODEL_NAME \
    --model-version $OPENAI_MODEL_VERSION \
    --model-format OpenAI

# Get cognitive account endpoint
ACCOUNT_ENDPOINT=$(az cognitiveservices account show \
  --name $CV_ACCOUNT_NAME \
  --resource-group $RES_GROUP \
  --query "properties.endpoint")

# Get key for computer vision resource
CV_ACCOUNT_KEY=$(az cognitiveservices account keys list \
    --resource-group $RES_GROUP \
    --name $CV_ACCOUNT_NAME \
    --query key1 \
    --output tsv)

# Get the key for speech services resource
SS_ACCOUNT_KEY=$(az cognitiveservices account keys list \
  --name $SS_ACCOUNT_NAME \
  --resource-group $RES_GROUP \
  --query key1 \
  --output tsv)

# Get the keys and endpoint for OpenAI resource
OPENAI_ACCOUNT_KEY=$(az cognitiveservices account keys list \
    --resource-group $RES_GROUP \
    --name $OPENAI_ACCOUNT_NAME \
    --query key1 \
    --output tsv)



echo "export SS_ACCOUNT_KEY=$SS_ACCOUNT_KEY" >> variables-$SUFFIX.local
echo "export RES_REGION=$RES_REGION" >> variables-$SUFFIX.local
echo "export OPENAI_ACCOUNT_KEY=$OPENAI_ACCOUNT_KEY" >> variables-$SUFFIX.local
echo "export ACCOUNT_ENDPOINT=$ACCOUNT_ENDPOINT" >> variables-$SUFFIX.local
echo "export OPENAI_VERSION=2023-03-15-preview" >> variables-$SUFFIX.local

echo "export CV_ACCOUNT_KEY=$CV_ACCOUNT_KEY" >> variables-$SUFFIX.local
echo "export OPENAI_DEPLOYMENT_NAME=$OPENAI_DEPLOYMENT_NAME" >> variables-$SUFFIX.local

echo "Variables for this session have been saved to variables-$SUFFIX.local"
echo "source variables-$SUFFIX.local"

echo "To remove the resources, run:"
echo "az group delete --name $RES_GROUP --yes"