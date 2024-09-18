# Use the official Debian base image
FROM mcr.microsoft.com/devcontainers/base:bullseye

# Install necessary packages
RUN apt-get update -y && \
    apt-get install -y libssl-dev libasound2 ffmpeg python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install azure-cognitiveservices-speech \
    azure-cognitiveservices-vision-computervision \
    azure-ai-vision-imageanalysis \
    scipy \
    python-dotenv \
    openai

# Set the default shell to bash
SHELL ["/bin/bash", "-c"]