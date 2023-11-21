function EEG = preproc(eeg,filterOrder,fs)

%Number of trials
nTrials = length(eeg);

%Initialization
EEG{1,nTrials} = [];

%Bandpass filter with filterOrder order Butterworth between 1 and 30Hz
%Create filter
[b,a] = butter(filterOrder/2,[1 30]/(fs/2),'bandpass');

%Apply filter
for i = 1:nTrials
    EEG{i} = filter(b,a,eeg{i});
end

end