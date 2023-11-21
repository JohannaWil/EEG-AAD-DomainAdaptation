function [Events, vClassMF, vClassLR] = getData(subjects,channels,filterOrder,run_checkStationality)

% INPUTS:
% Subject IDs
% Channels
% Butterworth filter order
% Check stationality for all channels (boolean)

% OUTPUTS:
% Events: 3200 x (#EEGchannels + #audioFiles) where 3200 is the number of samples
% vClassMF: Male/Female class labels
% vClassLR: Left/Right class labels

%Load labels
load('labelsLR.mat'); %Attended: left (1) or right (2)
load('labelsMF.mat'); %Attended: male (1) or female (2)
% load('labelsRoom.mat'); %Acoustic condition (not used)
load('nSpeakers.mat'); %Number of speakers for each trial

Events{length(subjects),1} = [];
vClassMF{length(subjects),1} = [];
vClassLR{length(subjects),1} = [];

for s = 1:length(subjects)
    
    %Load data
    fileName = ['S', num2str(subjects(s)), '_data_preproc.mat'];
    load(fileName);
    
    %Extract data
    EEG = data.eeg;
    fs = data.fsample.eeg; %Sampling frequency 
    
    %64 channels for each subject
    if run_checkStationality
        checkStationarity(EEG);
    end
    
    %Preprocessing with a Butterworth filter between [1-30]Hz
    EEG = preproc(EEG,filterOrder,fs);
    
    totalTrials = length(labelsLR); %Number of total trials
    
    jj = 0;
    kk = 1;
    for ii = 1:totalTrials
        if nSpeakers(subjects(s),ii) == 2 %Only interested in trials with 2 speakers
            jj = jj + 1;
            Events{s}{kk} = EEG{jj}(:,channels); 
            
            if labelsMF(subjects(s),ii) == 1 %Attended Male voice (1)
                vClassMF{s,1}(kk) = 1;                  
            elseif labelsMF(subjects(s),ii) == 2 %Attended Female voice (2)
                vClassMF{s,1}(kk) = 2;     
            end
            
            if labelsLR(subjects(s),ii) == 1 %Attended Left side (1)
                vClassLR{s,1}(kk) = 1; 
            elseif labelsLR(subjects(s),ii) == 2 %Attended Right side (2)
                vClassLR{s,1}(kk) = 2;
            end
            kk = kk + 1;
        end  
    end
end
end
