# Data Science for Hackathon project

This document contains the data science scoping and experiments that were conducted as part of the Hackathon 2024 project: __Speech Disorder "Translator" app - Context/video aware AI-powered app for people with aphasia__. 

## Automated Speech Recognition for Pathological Speech 

Automated Speech Recognition (ASR) systems can provide several benefits for people with speech disorders such as for characterization, recognition, and analysis of pathological speech (see [url](https://deepblue.lib.umich.edu/bitstream/handle/2027.42/194632/mkperez_1.pdf?sequence=1&isAllowed=y)). For this reason there are several works that have trained custom ASR models for pathological speech and also validated general purpose ASR models by Cloud providers like Microsoft anf Google (such as [paper1](https://aclanthology.org/2023.clinicalnlp-1.24.pdf), [paper2](https://www.mdpi.com/2076-3417/11/19/8872)). The reported numbers vary per dataset, preprocessing method and Aphasia severity category, but it is common to find Word Error Rate [WER](https://en.wikipedia.org/wiki/Word_error_rate) metrics of more than 50% for patients with very severe Aphasia. 

In our project, we wanted to use an ASR system that acts as a first step for the Speech Disorder "Translation" process. In order to evaluate performance of both off-the-selve solutions from [Azure AI Speech](https://azure.microsoft.com/en-us/products/ai-services/ai-speech) and also fine-tuned models, we employed certain samples provided from the [Aphasia TalkBank](https://aphasia.talkbank.org/). This dataset contains video interviews of people with Aphasia and also manually extracted transcripts according to a [protocol](https://talkbank.org/manuals/Clin-CLAN.pdf) that does not only includes the words that can be clearly understood but also additional information like abandoned word attempts where the speaker appears to change work choices. Our project can benefit from from including this additional information (abandoned word attempts) in the speech transript, as it may provide useful information for the following "translator" step. 

## Data Preparation 

For our benchmarking and finetuning experiments, we have used two datasets from the Aphasia TalkBank, the ACWT and CMU datasets that contain recordings and transcriptions from 12 and 3 participants repsectively. The total speech duration from the aphasia participants in ACWT is 01:31:29s and for CMU it is 41:38s. In order to preprocess the data in a form that can be used as input for the [Azure Custom Speech Studio](https://speech.microsoft.com/portal), we have taken the following steps:
- We extracted the audio from the available video interviews.
- We employed this [notebook](https://github.com/monirome/AphasiaBank/blob/main/clean_transcriptions.ipynb) to extract structured information and cleanup the transcripts. During this process one can observe that some structured information is removed from the transcript, whereas some other structured information is retained. One can change the preprocessing step based on which parts of the transcripts would help in the app "Translation" process. For example abandoned word attempts could potentially help. 
- We employed this python [script](https://github.com/monirome/AphasiaBank/blob/main/audio_chunks.py) to extract the audio chunks where only the participant was speaking thus removing the audio parts from the interviewer. This script was slightly extended to also produce a .txt file that contains the clean transcript associated with this speech chunk. 
- We complied two .zip files, one containing all the audio/transcript chunks from participants in the CMU group and another for all the audio/transcript chunks from participants in the ACWT group.    

## Benchmarking and Fine-tuning results

In our benchmarks we have used the following datasets:
- Out of the box __base model (20240614)__
- Out of the box __whisper large v2__
- Fine-tuned __base model__ on CMU data. For fine-tuning we have employed 'Custom Speech' from Azure Speech studio. 
- Fine-tuned __base model__ on ACWT data. For fine-tuning we have employed 'Custom Speech' from Azure Speech studio. 
- Fine-tuned __whisper large v2__ on CMU data. For fine-tuning we have employed 'Custom Speech' from Azure Speech studio. 
- Fine-tuned __whisper large v2__ on ACWT data. For fine-tuning we have employed 'Custom Speech' from Azure Speech studio. 

The results of the above models where 
CMU dataset:
- __base model (20240614)__: TER 80.15%
- __whisper large v2__: TER 79.15%
- Fine-tuned __whisper large v2__ on ACWT data: TER 40.42%
- Fine-tuned __base model__ on ACWT data: TER 77.26%

ACWT dataset:
- __base model (20240614)__: TER 80.04%
- __whisper large v2__: TER 81.20%
- Fine-tuned __whisper large v2__ on CMU data: TER 58.47%
- Fine-tuned __base model__ on CMU data: TER 70.95%


