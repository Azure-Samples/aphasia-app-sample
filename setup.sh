#!/bin/bash

# Set variables
RES_REGION=${RES_REGION:-}
RES_GROUP=${RES_GROUP:-}
CV_ACCOUNT_NAME=${CV_ACCOUNT_NAME:-}
SS_ACCOUNT_NAME=${SS_ACCOUNT_NAME:-}
OPENAI_ACCOUNT_NAME=${OPENAI_ACCOUNT_NAME:-}
OPENAI_DEPLOYMENT_NAME=${OPENAI_DEPLOYMENT_NAME:-}
OPENAI_MODEL_NAME=${OPENAI_MODEL_NAME:-}
OPENAI_MODEL_VERSION=${OPENAI_MODEL_VERSION:-}

# Check if variables are set
if [ -z "$RES_REGION" ]; then
  echo "Error: RES_REGION is not set."
  exit 1
fi

if [ -z "$RES_GROUP" ]; then
  echo "Error: RES_GROUP is not set."
  exit 1
fi

if [ -z "$CV_ACCOUNT_NAME" ]; then
  echo "Error: CV_ACCOUNT_NAME is not set."
  exit 1
fi

if [ -z "$SS_ACCOUNT_NAME" ]; then
  echo "Error: SS_ACCOUNT_NAME is not set."
  exit 1
fi

if [ -z "$OPENAI_ACCOUNT_NAME" ]; then
  echo "Error: OPENAI_ACCOUNT_NAME is not set."
  exit 1
fi

if [ -z "$OPENAI_DEPLOYMENT_NAME" ]; then
  echo "Error: OPENAI_DEPLOYMENT_NAME is not set."
  exit 1
fi

if [ -z "$OPENAI_MODEL_NAME" ]; then
  echo "Error: OPENAI_MODEL_NAME is not set."
  exit 1
fi

if [ -z "$OPENAI_MODEL_VERSION" ]; then
  echo "Error: OPENAI_VERSION is not set."
  exit 1
fi

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

# Install necessary packages
sudo apt-get update -y
sudo apt-get install -y libssl-dev libasound2
pip install azure-cognitiveservices-speech
pip install azure-cognitiveservices-vision-computervision
pip install scipy
pip install python-dotenv
sudo apt install -y ffmpeg
pip install openai

# Get cognitive account endpoint
export ACCOUNT_ENDPOINT=$(az cognitiveservices account show \
  --name $CV_ACCOUNT_NAME \
  --resource-group $RES_GROUP \
  --query "properties.endpoint")

# Get key for computer vision resource
export CV_ACCOUNT_KEY=$(az cognitiveservices account keys list \
    --resource-group $RES_GROUP \
    --name $CV_ACCOUNT_NAME \
    --query key1 \
    --output tsv)

# Get the key for speech services resource
export SS_ACCOUNT_KEY=$(az cognitiveservices account keys list \
  --name $SS_ACCOUNT_NAME \
  --resource-group $RES_GROUP \
  --query key1 \
  --output tsv)

# Get the keys and endpoint for OpenAI resource
export OPENAI_ACCOUNT_KEY=$(az cognitiveservices account keys list \
    --resource-group $RES_GROUP \
    --name $OPENAI_ACCOUNT_NAME \
    --query key1 \
    --output tsv)

echo "export ACCOUNT_ENDPOINT=$ACCOUNT_ENDPOINT"
echo "export CV_ACCOUNT_KEY=$CV_ACCOUNT_KEY"
echo "export SS_ACCOUNT_KEY=$SS_ACCOUNT_KEY"
echo "export OPENAI_ACCOUNT_KEY=$OPENAI_ACCOUNT_KEY"