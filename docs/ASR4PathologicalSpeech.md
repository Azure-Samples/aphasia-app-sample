# Data Science for Speech Disorder "Translator" app 

This document contains the data science scoping and experiments that were conducted as part of the Hackathon 2024 project: __Speech Disorder "Translator" app - Context/video aware AI-powered app for people with aphasia__. 

## Automated Speech Recognition for Pathological Speech 

Automated Speech Recognition (ASR) systems can provide several benefits for people with speech disorders such as for the characterization, recognition, and analysis of pathological speech (see [[1]](https://deepblue.lib.umich.edu/bitstream/handle/2027.42/194632/mkperez_1.pdf?sequence=1&isAllowed=y)). For this reason there are several works that have developed custom ASR models or validated general purpose ASR models by cloud providers like Microsoft and Google for pathological speech (see for example [[2]](https://aclanthology.org/2023.clinicalnlp-1.24.pdf), [[3]](https://www.mdpi.com/2076-3417/11/19/8872)). Word Error Rate [WER](https://en.wikipedia.org/wiki/Word_error_rate) (or Token Error Rate (TER)) is a commonly used metrics to report the accuracy of ASR systems. WER for aphasia patients is usually quite high and can be even more than 50% for patients with very severe aphasia. 

Word Error Rate (and Token Error Rate) is decomposed in three types of errors:
- Insertion errors, when the predicted transcript contains additional tokens not present in the annotated transcript
- Deletion errors, when the predicted transcript does not contain tokens present in the annotated transcript
- Substitution erros, when the predicted transcript contains misinterpreted words that are different from the annotated transcript

In our project, we wanted to use an ASR system that acts as a first step in the Speech Disorder "Translation" process. In order to evaluate performance of both off-the-shelve solutions from [Azure AI Speech](https://azure.microsoft.com/en-us/products/ai-services/ai-speech) and also fine-tuned models, we employed publicly available speech and transcript annotations provided from the [Aphasia TalkBank](https://aphasia.talkbank.org/). This dataset contains video interviews of people with Aphasia and also manually extracted transcripts according to a [protocol](https://talkbank.org/manuals/Clin-CLAN.pdf) that does not only include the words that can be clearly understood but also additional information like abandoned word attempts where the speaker appears to change word choices. Our project can benefit from including this additional information (abandoned word attempts) in the ASR output, as they may provide useful information for the following "translation" step. 

## Data Preparation 

For our model evaluation and fine-tuning experiments, we have used two datasets from the Aphasia TalkBank, the ACWT and CMU datasets that contain recordings and transcriptions from 12 and 3 participants respectively. The total speech duration in ACWT is 01:31:29s and for CMU it is 41:38s. In order to preprocess the data in a form that can be used as input for the [Azure Custom Speech Studio](https://speech.microsoft.com/portal), we have taken the following steps:
- We extracted the audio from the available video interviews.
- We employed this [notebook](https://github.com/monirome/AphasiaBank/blob/main/clean_transcriptions.ipynb) to extract structured information from each interview, like aphasia severity, etc. and cleanup the transcripts.  
- We employed this python [script](https://github.com/monirome/AphasiaBank/blob/main/audio_chunks.py) to extract the audio chunks where only the participant was speaking thus removing the audio parts from the interviewer. This script was slightly extended to also produce a .txt file that contains the cleaned-up transcript associated with this speech chunk. 
- We created two .zip files, one containing all the audio/transcript chunks from participants in the CMU group and another for all the audio/transcript chunks from participants in the ACWT group.    

You can see below some examples of the original transcription text along with the cleaned-up version after preprocessing:

__Original__: yes ‡ &+j &=traces:two it's two thousand &=traces:zero &=traces:zero &=points:table two days +...

__Cleaned-up version__: yes F F it's two thousand F F F two days

We can observe that the __F__ symbol is used to represent points during the speech where the person struggled to find the correct words. In future work a more elaborate set of symbols may be considered focusing on the information that is useful to build a "Translator" app.  

## Benchmarking off-the-shelve and fine-tuned models

In our benchmarks we have used the following models. Model fine-tuning was done using the 'Custom Speech' functionality from Azure Speech studio:
- Off-of-the-shelve __base model (20240614)__
- Off-of-the-shelve __whisper large v2__
- Fine-tuned __base model__ on CMU data.  
- Fine-tuned __base model__ on ACWT data.  
- Fine-tuned __whisper large v2__ on CMU data.  
- Fine-tuned __whisper large v2__ on ACWT data.  

In the following table we report the metrics for these models on the CMU and ACWT datasets. We should note that when reporting metrics on the CMU data, fine-tuning was performed with ACWT. Similarly, when reporting metrics on the ACWT data, the fine-tuning was performed with CMU. 
|Dataset|Metric|base model (20240614)|whisper large v2|Fine-tuned whisper large v2|Fine-tuned base model|
|---|---|---|---|---|---|
|CMU|Token Error Rate (TER)|80.15%|79.15%|__40.42%__|77.26%|
|CMU|Insertion (TER)|__3.81%__|4.37%|10.44%|10.44%|
|CMU|Substitution (TER)|47.51%|47.70%|__17.93%__|46.71%|
|CMU|Deletion (TER)|24.14%|22.50%|__12.05%__|19.69%|
|ACWT|Token Error Rate (TER)|80.04%|81.20%|__58.47%__|70.95%|
|ACWT|Insertion (TER)|__3.72%__|6.24%|7.30%|7.30%|
|ACWT|Substitution (TER)|45.88%|48.11%|__17.82%__|45.27%|
|ACWT|Deletion (TER)|26.93%|22.99%|29.55%|__15.29%__|

We can make the following observations based on the evaluation results:
- Off-the-shelve models have a high TER, that can be partly attributed to the use of special tokens to indicate that a person is struggling to speak at specific points in time.
- With fine-tuning the whisper-large-v2 models achieves best metric results in TER and also in most metric subcategories. 
- We have observed, as reported in the literature [[4]](https://arxiv.org/pdf/2402.08021v2) that off-the-shelve whisper-large-v2 model, suffers from hallucinations, specifically when the speaker makes long pauses
- Fine-tuning the whisper v2 model, using a special token to indicate a speaker's struggles to speak can reduce the number of hallucinations. 

## Next steps

- Models can be fine-tuned with additional data that is available in the aphasia TalkBank dataset 
- In the current analysis, we have employed a simple scheme to assign tokens to parts of speech where the speaker is struggling to find the correct words. We can potentially expand that, focusing on the type of information that can be useful for a translator app
- Fine-tuned ASR transcripts, can be augmented with additional context, like video or the previous text/question to improve performance 
