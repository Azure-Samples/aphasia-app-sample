import os
import azure.cognitiveservices.speech as speechsdk
from image_analysis import analyze_image  # Import the function from image-analysis.py
# Azure Cognitive Services Speech configuration

audio_file = "J.wav"
image_path = "kitchen-night.jpg"
image_analysis_result = analyze_image(image_path)


speech_key = os.getenv('SS_ACCOUNT_KEY')
service_region = os.getenv('RES_REGION')
openai_key = os.getenv('OPENAI_ACCOUNT_KEY')
openai_endpoint = os.getenv('ACCOUNT_ENDPOINT')
openai_model = os.getenv('OPENAI_MODEL')
openai_version = os.getenv('OPENAI_VERSION')
openai_deployment = os.getenv('OPENAI_DEPLOYMENT_NAME')

from openai import AzureOpenAI
    
client = AzureOpenAI(
    api_key=openai_key,  
    api_version=openai_version,
    azure_endpoint=openai_endpoint
    )

# Initialize the speech recognizer
speech_config = speechsdk.SpeechConfig(subscription=speech_key, region=service_region)
audio_config = speechsdk.audio.AudioConfig(filename=audio_file)
speech_recognizer = speechsdk.SpeechRecognizer(speech_config=speech_config, audio_config=audio_config)

def check_incoherence_with_openai(text):
    print(f"Checking incoherence: {text}")
    response = client.chat.completions.create(model=openai_deployment, messages=[{'role': 'system', 'content': f'Is the following text incoherent? {text}? Answer with "yes" or "no".'}])
    response_text = response.choices[0].message.content.strip().lower().rstrip('.')
    true_or_false = response_text == 'yes'
    print(f"Incoherent: {true_or_false}")
    return true_or_false

def hydrate_text(text):
    print(f"Hydrating: {text}")
     # Create the prompt with the image analysis result
    prompt = f"This following context is the computer vision result from the environment:\n{image_analysis_result}\n\nComplete and hydrate the following text: {text}"    # Get the response from the OpenAI model
    response = client.chat.completions.create(
        model=openai_deployment,
        messages=[{'role': 'system', 'content': prompt}]
    )
    return response.choices[0].message.content

def process_recognized_text(text):
    if check_incoherence_with_openai(text):
        print(f"Incoherent detected: {text}")
        text = hydrate_text(text)
        print(f"Hydrated text: {text}")
def speech_to_text():
    def recognized_cb(evt):
        if evt.result.reason == speechsdk.ResultReason.RecognizedSpeech:
            process_recognized_text(evt.result.text)
        elif evt.result.reason == speechsdk.ResultReason.NoMatch:
            print("No speech could be recognized")
        elif evt.result.reason == speechsdk.ResultReason.Canceled:
            cancellation_details = evt.result.cancellation_details
            print(f"Speech Recognition canceled: {cancellation_details.reason}")
            if cancellation_details.reason == speechsdk.CancellationReason.Error:
                print(f"Error details: {cancellation_details.error_details}")

    speech_recognizer.recognized.connect(recognized_cb)
    speech_recognizer.start_continuous_recognition()
    
    print("Ctrl + C to stop the recognition...")
    try:
        while True:
            pass
    except KeyboardInterrupt:
        speech_recognizer.stop_continuous_recognition()
        print("Recognition stopped.")

speech_to_text()
