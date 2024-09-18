# Quickstart

## Prerequisites

1. Open Codespaces
2. Log in to Azure using the command:
   ```shell
   az login --use-device-code  for codespaces
   ```
3. If you haven't done so already, go to the Azure portal to create a Computer Vision resource. This is necessary to accept the Responsible AI terms for using Computer Vision services and for creating computer vision resources using AzCli in the future. You will only need to do this ONCE per subscription.

## Steps

1. Run `setup.sh` and copy the 4 export commands from the terminal.

```bash
./setup.sh
```

2. Source the new .local file created

```bash
source variables-{suffix}.local
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

