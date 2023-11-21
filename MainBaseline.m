% Written by Johanna Wilroth
% Division of Automatic Control, Department of Electrical Engineering,
% Linköping University, Sweden
% johanna.wilroth@liu.se

% This script compute the classification accuracy for all 18 subjects for
% two different classification problems:
% Attention to Male/Female voice (MF)
% Attention to Left/Right side of the subject (LR)

close all; clear; clc;
%Add path to Riemannian tools
addpath('RiemannianTools');

%Add path to relevant functions
addpath('Scripts');

%Add paths to data folders
addpath('Data\DATA_preproc'); %Proprocessad data
addpath('Data\Labels'); %Labels

%% Things to be changed by user

user = 'User'; %'Author';
savePath = ['[path_to_main_script]\Results\',user,'\']; % [Insert path]

%Run baseline classification for all 18 subjects
subjects = 1:18;
disp(['Chosen subjects: ' num2str(subjects)]);
nSubjects = length(subjects); %Number of subjects

% Choose which channels to use. Input values 1:64
channels = 1:64; 
checkUserInputs(channels,1);

p = 0.5; %Level of chance in 2-classification problems

% Three differenct classification methods: SVM, decision tree and k-nearest neighbor
% Choose how many nearest neighbors to use. Please enter one or more integers > 0
k = [3,4]; %number of nearest neighbors
checkUserInputs(k,2);

% Choose Butterworth filter order. Please enter an even number greater than zero
filterOrder = 6;
checkUserInputs(filterOrder,3);

saveData = true;                    % True to save classification accuracy
run_plot = false;                   % True to visualize through tSNE
run_checkStationality = false;      % True to check stationality for all channels
run_PosDefiniteTest = false;        % True to check that all covariance matrices are pos. definite
run_plotRiemannianMean = false;     % True to plot Riemannian mean (fig 1)
printTable = true;                 % True to print the classification accuracy
checkUserInputs([saveData,run_plot,run_checkStationality,run_PosDefiniteTest,run_plotRiemannianMean,printTable],4);

% Choose which task and method to evaluate with domain adaptation
tasks = {'Male/Female','Left/Right'};           %task = 1 (MF), task = 2 (LR)
task = 2;
methods = {'SVM', 'Decision Tree', 'k-NN'};     %method = 1 (SVM), method = 2 (Tree), method = 3 (k-NN)
method = 1;

%% Start main script

classificationMethod = {'SVM','TREE'};
for kk = 1:length(k)
    classificationMethod{2+kk} = [num2str(k(kk)) '-NN'];
end
nK = length(k); %Number of k-values

disp(['Number of subjects: ' num2str(nSubjects)]);
disp(['Classification methods: ' classificationMethod{1} ', ' classificationMethod{2} ', k-NN']);
disp(['Set of k-values: ' num2str(k)]);
disp(['Butterworth filter order: ' num2str(filterOrder)]);
disp(['Evaluation task: ',tasks{task}]);
disp(['Evaluation method: ',methods{method}]);
disp('----------------------------------------------------------------')

% DTU-data:
% The data is downsampled to 64Hz -> 3200samples in each trial
% 64 EEG channels
% 2 mastoid electrodes (which are removed in GetData.m)
% Add the two audio files -> 3200x66 for each trial

% Which labels to be used
% MF: Male/female attention
% LR: Left/Right attention

% Get data:
% Events: EEG data
% vClassMF: male/female labels, one cell for each subject
% vClassLR: left/right labels, one cell for each subject

[Events, vClassMF, vClassLR] = getData(subjects,channels,filterOrder,run_checkStationality);
nTrials = length(Events{1}); %Number of trials

%%
vS = zeros(1,nSubjects*nTrials); %vector of subject events
vecClassMF = zeros(1,nSubjects*nTrials); %vector of male/female labels
vecClassLR = zeros(1,nSubjects*nTrials); %vector of left/right labels
CovsVec = cell(1,nSubjects*nTrials); %vector of covariance matrices
Covs = cell(1,nSubjects); %cells of covariance matrices

% Baseline accuracy for each subject
acc = cell(nSubjects,1);

% Compute and stack the covariance matrices and labels
idx = 1;
for s = 1:nSubjects
    vS(1,idx:idx+nTrials-1) = s*ones(1,nTrials);
    vecClassMF(1,idx:idx+nTrials-1) = vClassMF{s};
    vecClassLR(1,idx:idx+nTrials-1) = vClassLR{s};
    Covs{s} = CalcCovs(Events{s});
    CovsVec(1,idx:idx+nTrials-1) = Covs{s};
    idx = idx + nTrials;
end

%Test if all the covariance matrices are positive definite
if run_PosDefiniteTest
    testPosDefinite(Covs,subjects)
end

%% Before transportation
% Step 6 in Algorithm 2: "Project the covariance matrices to the Euclidean tangent space"
mX     = CovsToVecs(cat(3, CovsVec{:}));

% Compute classification accuracy for each subject
for s = 1:nSubjects
    %Extract trials for subject s
    startTrial = (s-1)*nTrials+1;
    endTrial = startTrial + (nTrials-1);
    
    CovsTest = CovsVec(startTrial:endTrial);
    vClassMFtest = vecClassMF(startTrial:endTrial);
    vClassLRtest = vecClassLR(startTrial:endTrial);
    
    %Step 6 in our algorithm: "Project the covariance matrices to the Euclidean tangent space"
    mXTest = CovsToVecs(cat(3,CovsTest{:}));
    
    % Compute classification accuracy for subject s
    acc{s}{1} = computeAcc(mXTest, vClassMFtest, classificationMethod,k,p);
    acc{s}{2} = computeAcc(mXTest, vClassLRtest, classificationMethod,k,p);
    
    % Print classification accuracy for subject s
    if printTable
        disp('--------------------------------')
        disp(['Baseline subject: ', num2str(subjects(s))])
        array2table([acc{s}{1} acc{s}{2}],'VariableNames',{'Accuracy (MF) [%]','y (MF)','f (MF)','Accuracy (LR) [%]','y (LR)','f (LR)'},'RowNames',classificationMethod);
    end
end

%% Extract candidate and reference subjects for chosen task and method

baselineAcc = zeros(1,nSubjects);
for s = 1:nSubjects
    baselineAcc(s) = acc{s}{task}(method);
end

% Reference subjects are defined as the three subjects with largest classification accuracy
[sortedValues, sortedIndices] = sort(baselineAcc, 'descend');
refSubs = sortedIndices(1:3);

% Candidate subjects are defined as the three subjects a classification
% accuracy lower or equal to round(mean-std)
meanAcc= mean(baselineAcc);
stdAcc = std(baselineAcc);
candSubs = find(baselineAcc <= round((meanAcc-stdAcc)));
%%
if saveData
    if exist(savePath, 'dir') == 0
        mkdir(savePath); % If it doesn't exist, create the folder
    end
    taskName = tasks{task};
    methodName = methods{method};
    fname = [savePath,'\baselineData.mat'];
    save(fname,'acc','refSubs','candSubs','taskName','methodName')
end

disp('-----------------------------------------------')
disp(['Task: ',tasks{task}])
disp(['Classification method: ',methods{method}]);
disp(['Reference subjects: ',num2str(refSubs)])
disp(['Candidate subjects: ',num2str(candSubs)])
disp('-----------------------------------------------')


function Covs = CalcCovs(Events)
    for ii = 1 : length(Events)
        mX       = Events{ii}';
        Covs{ii} = cov(mX');
    end
end   
