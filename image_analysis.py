import os
from azure.ai.vision.imageanalysis import ImageAnalysisClient
from azure.ai.vision.imageanalysis.models import VisualFeatures
from azure.core.credentials import AzureKeyCredential

def analyze_image(image_path):
    # Set the values of your computer vision endpoint and computer vision key as environment variables:
    try:
        region = os.environ["RES_REGION"]
        key = os.environ["CV_ACCOUNT_KEY"]
    except KeyError:
        raise EnvironmentError("Missing environment variable 'RES_REGION' or 'CV_ACCOUNT_KEY'. Set them before running this.")

    # Create an Image Analysis client
    client = ImageAnalysisClient(
        endpoint="https://" + region + ".api.cognitive.microsoft.com/",
        credential=AzureKeyCredential(key)
    )

    # Set the confidence threshold
    confidence_threshold = 0.6

    # Load image to analyze into a 'bytes' object
    with open(image_path, "rb") as f:
        image_data = f.read()

    # Analyze the image
    result = client.analyze(
        image_data=image_data,
        visual_features=[
            VisualFeatures.TAGS,
            VisualFeatures.OBJECTS,
            VisualFeatures.CAPTION,
            VisualFeatures.DENSE_CAPTIONS,
            VisualFeatures.READ,
            VisualFeatures.PEOPLE,
        ],
        gender_neutral_caption=True,  # Optional (default is False)
        language="en",  # Optional. Relevant only if TAGS is specified above. See https://aka.ms/cv-languages for supported languages.
        model_version="latest",  # Optional. Analysis model version to use. Defaults to "latest".
    )

    # Save analysis results to a variable
    result_text = f"Image analysis results for {os.path.basename(image_path)} with confidence >= {confidence_threshold:.2f}:\n"

    if result.caption is not None and result.caption.confidence >= confidence_threshold:
        result_text += " Caption:\n"
        result_text += f"   '{result.caption.text}', Confidence {result.caption.confidence:.4f}\n"

    if result.dense_captions is not None:
        result_text += " Dense Captions:\n"
        for caption in result.dense_captions.list:
            if caption.confidence >= confidence_threshold:
                result_text += f"   '{caption.text}', {caption.bounding_box}, Confidence: {caption.confidence:.4f}\n"

    if result.read is not None:
        result_text += " Read:\n"
        if result.read.blocks:
            for block in result.read.blocks:
                for line in block.lines:
                    result_text += f"   Line: '{line.text}', Bounding box {line.bounding_polygon}\n"
                    for word in line.words:
                        if word.confidence >= confidence_threshold:
                            result_text += f"     Word: '{word.text}', Bounding polygon {word.bounding_polygon}, Confidence {word.confidence:.4f}\n"
        else:
            result_text += "   No text detected.\n"

    if result.tags is not None:
        result_text += " Tags:\n"
        for tag in result.tags.list:
            if tag.confidence >= confidence_threshold:
                result_text += f"   '{tag.name}', Confidence {tag.confidence:.4f}\n"

    if result.objects is not None:
        result_text += " Objects:\n"
        for obj in result.objects.list:
            if obj.tags[0].confidence >= confidence_threshold:
                result_text += f"   '{obj.tags[0].name}', {obj.bounding_box}, Confidence: {obj.tags[0].confidence:.4f}\n"

    if result.people is not None:
        result_text += " People:\n"
        for person in result.people.list:
            if person.confidence >= confidence_threshold:
                result_text += f"   {person.bounding_box}, Confidence {person.confidence:.4f}\n"

    return result_text

# Example usage
# image_path = "kitchen-night.jpg"
# analysis_result = analyze_image(image_path)
# print(analysis_result)