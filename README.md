# Quickstart

## Prerequisites

1. Ensure you have Azure CommandLine and Python3 installed.
2. Log in to Azure using the command:
   ```shell
   az login
   ```
3. If you haven't done so already, go to the Azure portal to create a Computer Vision resource. This is necessary to accept the Responsible AI terms for using Computer Vision services and for creating computer vision resources using AzCli in the future. You will only need to do this ONCE per subscription.

## Steps

1. Set your desired region and resource group name, OpenAI model deployment name, as well as account names for:
   - Computer Vision
   - Speech Services
   - OpenAI

You can leave OPENAI_MODEL_NAME, OPENAI_MODEL_VERSION, and OPENAI_VERSION as is.

```bash
source variables.sh
```
2. Run `setup.sh` and copy the 4 export commands from the terminal.

```bash
./setup.sh
```
3. Upload an image and audio file (`.wav`), and update main.py to reference those. 
>Note: if you have an `.mp3` file, you can use the following command to convert it to `.wav`:

```bash
# Example
ffmpeg -i J.mp3 J.wav
```

4. Run `main.py` to test the speech to text and text hydration with image analysis context
```bash
python3 main.py
```

