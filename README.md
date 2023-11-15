# EEGbasedLoAwithDomainAdaptation

MATLAB code and tutorial to run the results presented in "Improving EEG-Based Decoding of the Locus of Auditory Attention through Domain Adaptation" by Johanna Wilroth, Bo Bernhardsson, Frida Heskebeck, Martin A. Skoglund, Carolina Bergeling and Emina Alickovic. Journal of Neural Engineering, 2023 (in proceedings).

# Abstract
Objective: This paper presents a novel domain adaptation framework to enhance the accuracy of EEG-based auditory attention classification, specifically for classifying the direction (left or right) of attended speech. The framework aims to improve the performances for subjects with initially low classification accuracy, overcoming challenges posed by instrumental and human factors. Limited dataset size, variations in EEG data quality due to factors such as noise, electrode misplacement or subjects, and the need for generalization across different trials, conditions and subjects necessitate the use of domain adaptation methods. By leveraging domain adaptation methods, the framework can learn from one EEG dataset and adapt to another, potentially resulting in more reliable and robust classification models.
Approach: This paper focuses on investigating a domain adaptation method, based on parallel transport, for addressing the auditory attention classification problem. The EEG data utilized in this study originates from an experiment where subjects were instructed to selectively attend to one of the two spatially separated voices presented simultaneously.
Main results: Significant improvement in classification accuracy was observed when poor data from one subject was transported to the domain of good data from different subjects, as compared to the baseline. The mean classification accuracy for subjects
with poor data increased from 45.84% to 67.92%. Specifically, the highest achieved classification accuracy from one subject reached 83.33%, a substantial increase from the baseline accuracy of 43.33%.
Significance: The findings of our study demonstrate the improved classification performances achieved through the implementation of domain adaptation methods. This brings us a step closer to leveraging EEG in neuro-steered hearing devices.

# Data
Data can be downloaded from https://zenodo.org/record/1199011#.XnRypqhKjDf.

You will need to download:

    EEG: Data before preprocessing (you only need to download EEG if you do not have the scrips: labelsLR.mat, labelsMF.mat, labelsRoom.mat, nSpeakers.mat from the "Labels" folder).
  
    DATA_preproc: Data after preprocessing (download the script preproc_data.m to understand all the preprocessing steps).

The data is downsampled to 64Hz.

If you want to use another dataset, the script getData.m needs to get modified for laoding and extracting the data. The output needs to be in the format:

    Events: nSubjects x 1 cells -> 1 x nTrials cells -> 3200 x (#EEGchannels + #audioFiles) where 3200 is the number of samples.
    vClassMF (Male/Female class labels): nSubjects x 1 cells -> 1 x nTrials vector.
    vClassLR (Left/Right class labels): nSubjects x 1 cells -> 1 x nTrials vector.
    
where:

    nSubjects: number of subjects.
    nTrials: number of trials.
    #EEGchannels: number of EEG channels.
    #audioFiles: number of audio files.
    3200: number of samples (in this case since the data is 50s long and sampled at a frequency of 64Hz).

    Cite: Fuglsang, S. A., Wong, D. D. E. och Hjortkjær, J. (2018) ”EEG and audio dataset for auditory attention decoding”. Zenodo. doi: 10.5281/zenodo.1199011. 
