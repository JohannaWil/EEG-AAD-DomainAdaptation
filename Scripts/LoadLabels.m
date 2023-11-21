function LoadLabels(directory,saveLabels)

nSubjects = 18;
nTrials = 70;

labelsMF = zeros(nSubjects,nTrials); %Male (1) / Female (2) labels
labelsLR = zeros(nSubjects,nTrials); %Left (1) / Right (2) labels
labelsRoom = zeros(nSubjects,nTrials); %Aucustic room type: Anechoic (1), Midely reverberant (2), Highly reverberant (3)
nSpeakers = zeros(nSubjects,nTrials); %Number of speakers

for i = 1:nSubjects
    
    if exist([directory 'S' num2str(i)  '.mat'], 'file') == 2 
    fileName = ['S', num2str(i), '.mat']; 
    load(fileName);
    
    labelsMF(i,:) = expinfo.attend_mf';
    labelsLR(i,:) = expinfo.attend_lr';
    labelsRoom(i,:) = expinfo.acoustic_condition';
    nSpeakers(i,:) = expinfo.n_speakers';
    else
        warning('File does not exist for this subject');
    end
end

%% Save labels
save(fullfile(saveLabels,'labelsMF.mat'),'labelsMF');
save(fullfile(saveLabels,'labelsLR.mat'),'labelsLR');
save(fullfile(saveLabels,'labelsRoom.mat'),'labelsRoom');
save(fullfile(saveLabels,'nSpeakers.mat'),'nSpeakers');

end
