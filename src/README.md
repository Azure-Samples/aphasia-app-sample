# Aphasia App Sample

This folder contains a sample application that demonstrates how to use Azure Cognitive Services for speech-to-text conversion and image analysis. The application processes audio input to convert speech to text and enhances the text using image analysis results.

## Files

- `src/main.py`: The main script that performs speech-to-text conversion and enhances the recognized text using image analysis results.
- `src/image_analysis.py`: A helper script that performs image analysis using Azure Cognitive Services.
- `src/speech-to-text`: An alternative script that performs only the speech-to-text conversion and enhances the text without image analysis results.

## Prerequisites

1. Open Codespaces
2. Log in to Azure using the command:
   ```shell
   az login --use-device-code
   # for Codespaces
   ```
3. If you haven't done so already, go to the Azure portal to create a Computer Vision resource. This is necessary to accept the Responsible AI terms for using Computer Vision services and for creating computer vision resources using AzCli in the future. You will only need to do this ONCE per subscription.

## Quickstart

1. Run `setup.sh`.

```bash
cd src
./setup.sh
```

2. Source the new .local file created.

```bash
source variables-{suffix}.local
```

3. Run `main.py` to test the speech to text and text hydration with image analysis context using the provided example audio and image as parameters.

```bash
python3 main.py --audio samples/cup.wav --image samples/cup.jpg
```

4. To test out the speech to text and text hydration without the image analysis, you can run the following:

```bash
python3 main.py --audio samples/cup.wav
```

5. Optional: upload your own image and audio file (`.wav`) to test.
>Note: if you have an `.mp3` or other type of audio file, you will need to use the following command to convert it to `.wav`:

```bash
# Example
ffmpeg -i test.mp3 test.wav
```
