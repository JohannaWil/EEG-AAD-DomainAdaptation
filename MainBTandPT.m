% Written by Johanna Wilroth
% Division of Automatic Control, Department of Electrical Engineering,
% Linköping University, Sweden
% johanna.wilroth@liu.se

% *********************************************************************************

% This script can be excecuted in four different combinations of reference
% and candidate subjects:
    % choise 1: Use the result of reference and candidate subjects from "MainBaseline.m"
    % choise 2: Custum your own reference and candidate subjects
    % choise 3: For each candidate subject from "MainBaseline.m", use all other 17
                % subjects as reference subjects
                      
    % choise 4: To run this choise:
                % (1) Run this script (MainBTandPT.m) for any of choises 1-3 
                % (2) Computed the best reference combinations in evaluateBTandPT.m. 
                % (3) Run this script again with choise 4 to compute the BT and PT 
                %     classification accuracy for these two best reference 
                %     combinations and all other subjects. The result is the data shown in Figure 6
                % (4) Plot Figure 6 in plotBestRefCombinations.m
     
%%
close all; clear; clc;
%Add path to Riemannian tools
addpath('RiemannianTools');

%Add path to relevant functions
addpath('Scripts');

%Add paths to data folders
addpath('Data\DATA_preproc'); %Proprocessad data
addpath('Data\Labels'); %Labels
addpath('Results');


%% Things to be changed by user

user = 'User'; %'Author';
savePath = ['[path_to_main_script]\Results\',user,'\']; %[Insert path]

% Choose which channels to use. Input values 1:64
channels = 1:64; 
checkUserInputs(channels,1);

% Three differenct classification methods: SVM, decision tree and k-nearest neighbor
% Choose how many nearest neighbors to use. Please enter one or more integers > 0
k = [3,4]; %number of nearest neighbors
checkUserInputs(k,2);

% Choose Butterworth filter order. Please enter an even number greater than zero
filterOrder = 6;
checkUserInputs(filterOrder,3);

saveData = true;                   % True to save classification accuracy
run_plot = false;                   % True to visualize through tSNE
run_checkStationality = false;      % True to check stationality for all channels
run_PosDefiniteTest = false;        % True to check that all covariance matrices are pos. definite
run_plotRiemannianMean = false;     % True to plot Riemannian mean (fig 9)
printTable = true;                 % True to print the classification accuracy
checkUserInputs([saveData,run_plot,run_checkStationality,run_PosDefiniteTest,run_plotRiemannianMean,printTable],4);

disp(['Set of k-values: ' num2str(k)]);
disp(['Butterworth filter order: ' num2str(filterOrder)]);
disp('----------------------------------------------------------------')

%% Start main script
disp('Starting main script...');
disp('----------------------------------------------------------------')
disp('This script can be excecuted in four different combinations of reference and candidate subjects:');
disp('Choise 1: Use the result of reference and candidate subjects from "MainBaseline.m"');
disp('Choise 2: Custom your own reference and candidate subjects');
disp('Choise 3: For each candidate subject from "MainBaseline.m", use all other 17 subjects as reference subjects');
disp('Choise 4: Use the two best reference combination on all subjects');
choise = input('Enter your choise of subject combinations (1, 2, 3 or 4): ');
checkUserInputs(choise,5)

allSubs = 1:18;
baselineData = load([savePath,'\baselineData.mat']);
switch choise
    case 1
        subjectChoise = 'BaselineEvaluation';
        refSubs = baselineData.refSubs;
        candSubs = baselineData.candSubs;
    case 2
        refSubs = [8,9,15];  % Insert one or more integers between 1-18
        candSubs = [1,2,5,16]; % Insert one or more integers between 1-18  
        checkUserInputs({refSubs,candSubs},6)
        subjectChoise = 'UserChoise';
    case 3
        load('baselineData.mat')
        candSubs = [1,2,5,16];
        refSubs = cell(1,length(candSubs));
        for j = 1:length(candSubs)
           refSubs{j} = setdiff(allSubs,candSubs(j));
        end
        subjectChoise = 'AllSubjects';
     case 4
        refSubs = {15, [9 15]};  % Insert the best reference combinations
        tmp = unique(cell2mat({15, [9 15]}));
        candSubs = setdiff(allSubs,tmp); % Choose all other subjects as candidates
        checkUserInputs({refSubs{:},candSubs},6)
        subjectChoise = 'bestRefComb';
end

if choise == 4
    refCombs = refSubs;
else
    refCombs = generateAllCombinations(refSubs,choise);
end
nCombs = length(refCombs); % Number of combinations

if choise == 1 || choise == 2
    disp('Unique combinations of reference subjects: ')
    for i = 1:nCombs
        disp(['Combination #',num2str(i),': (',num2str(refCombs{i}),')'])
    end
end

% Number of candidate subjects
nCandSubs = length(candSubs); 

%Level of chance in 2-classification problems
p = 0.5; 

% Classification methods
classificationMethod = {'SVM','TREE'};
for kk = 1:length(k)
    classificationMethod{2+kk} = [num2str(k(kk)) '-NN'];
end
nK = length(k); %Number of k-values

%Accuracy for Before Transportation (BT) and Parallel Transport (PT)
accBT{nCombs,nCandSubs} = []; 
accPT{nCombs,nCandSubs} = []; 

disp('----------------------------------------------------------------')
for i = 1:nCombs % For each reference combination
    if choise == 1 || choise == 2 || choise == 4
        refSub = refCombs{i};
        nRefSubjects = length(refSub);
        if nRefSubjects == 1
            disp(['Combination ',num2str(i),' of ',num2str(nCombs),', with reference subject: ',num2str(refSub)]);
        else
            disp(['Combination ',num2str(i),' of ',num2str(nCombs),', with reference subjects: ',num2str(refSub)]);
        end
        % Extract data for reference subjects for choises 1 and 2
        [EventsRefs, vClassMFRefs, vClassLRRefs] = getData(refSub,channels,filterOrder,run_checkStationality);
    end
    
    for ii = 1:nCandSubs % For each candidate subject
        candSub = candSubs(ii);
        
        if choise == 3
            refSub = refSubs{ii};
            disp(['Reference subjects: ',num2str(refSub)]);
            % Extract data for reference subjects
            [EventsRefs, vClassMFRefs, vClassLRRefs] = getData(refSub,channels,filterOrder,run_checkStationality);
        end
        
        disp(['Candidate  subject: ' num2str(candSub)]);
         % Total number of subjects
        subjects = [refSub candSub];
        nSubjects = length(subjects);
        
        % Extract data for candidate subjects
        [EventsCand, vClassMFCand, vClassLRCand] = getData(candSub,channels,filterOrder,run_checkStationality);
        
        % Concatenate data from reference and candidate subjects
        Events = {EventsRefs{:}, EventsCand{:}};
        vClassMF = {vClassMFRefs{:}, vClassMFCand{:}};
        vClassLR = {vClassLRRefs{:}, vClassLRCand{:}};
        nTrials = length(Events{1}); %Number of trials
        clear EventsCand vClassMFCand vClassLRCand
        %%
        vS = []; %vector of subject events
        vecClassMF = []; %vector of male/female labels
        vecClassLR = []; %vector of left/right labels
        CovsVec = []; %vector of covariance matrices
        Covs{nSubjects,1} = []; %cells of covariance matrices
        
       % Compute and stack the covariance matrices
        for s = 1:nSubjects
            vS = [vS s*ones(1,nTrials)];
            vecClassMF = [vecClassMF vClassMF{s}];
            vecClassLR = [vecClassLR vClassLR{s}];
            Covs{s} = CalcCovs(Events{s});
            CovsVec = [CovsVec Covs{s}];
        end
        
        % Check if all the covariance matrices are positive definite
        if run_PosDefiniteTest
            testPosDefinite(Covs,subjects)
        end
        
        %% Before transportation
        %Step 6 in the algorithm: "Project the covariance matrices to the
        %Euclidean tangent space"
        mX = CovsToVecs(cat(3, CovsVec{:}));
        accBT{i,ii}{1} = computeAcc2(nTrials*length(candSub), mX, vecClassMF, classificationMethod,k,p);
        accBT{i,ii}{2} = computeAcc2(nTrials*length(candSub), mX, vecClassLR, classificationMethod,k,p);
        if printTable
            disp(['Before transport (BT): LOO-CV classification accuracy for candidate ',num2str(candSub)]);
            array2table([accBT{i,ii}{1} accBT{i,ii}{2}],'VariableNames',{'Accuracy (MF) [%]','y (MF)','f (MF)','Accuracy (LR) [%]','y (LR)','f (LR)'},'RowNames',classificationMethod)
            disp('------------------------------------------------------------------------------------------------')
        end
       
        
        %% Visualize through tSNE
        if run_plot
            mTSNE = tsne(mX')';
            
            %Plot Male/Female classification
            figure
            PlotData(mTSNE, vecClassMF, vS, nSubjects,subjects,1);
            sgtitle('Before Transportation (BT): Male/Female classification','FontSize',26)
            subplot(1,2,1); title('Class labels','FontSize',20)
            subplot(1,2,2); title('Subjects','FontSize',20)
            
            %Plot Left/Right classification
            figure
            PlotData(mTSNE, vecClassLR, vS, nSubjects,subjects,2);
            sgtitle('Before Transportation (BT): Left/Right classification','FontSize',26)
            subplot(1,2,1); title('Class labels','FontSize',20)
            subplot(1,2,2); title('Subjects','FontSize',20)         
        end
        
        %% Applying Parallel Transport
        
        %Algorithm 1: steps 1-3. Gives the covariance matrices after the
        %transportation
        [CovsPT M D] = applyPT(Covs);
        
        %Algorithm 1: step 4 + creates vectors with gain sqrt(2) applied to all
        %non-diagonal elements (p. 6)
        mXPT = CovsToVecs(CovsPT);
        
        %Plot the Riemannian mean
        if run_plotRiemannianMean
            plotRiemannianMean(CovsVec,M,D,vS,subjects,CovsPT)
        end
        

        %% Classification accuracy
       
        accPT{i,ii}{1} = computeAcc2(nTrials*length(candSub), mXPT, vecClassMF,classificationMethod,k,p);
        accPT{i,ii}{2} = computeAcc2(nTrials*length(candSub), mXPT, vecClassLR,classificationMethod,k,p);
        if printTable
            disp(['Parallel transport (PT): LOO-CV classification accuracy for candidate ',num2str(candSub)])
            array2table([accPT{i,ii}{1} accPT{i,ii}{2}],'VariableNames',{'Accuracy (MF) [%]','y (MF)','f (MF)','Accuracy (LR) [%]','y (LR)','f (LR)'},'RowNames',classificationMethod)
            disp('------------------------------------------------------------------------------------------------')
        end
        
        
    %% Visualize through tSNE
        if run_plot
            mTSNE = tsne(mXPT')';
            
            %Plot Male/Female classification
            figure
            PlotData(mTSNE, vecClassMF, vS, nSubjects,subjects,1);
            sgtitle('Parallel Transport (PT): Male/Female classification','FontSize',26)
            subplot(1,2,1); title('Class labels','FontSize',20)
            subplot(1,2,2); title('Subjects','FontSize',20)
            
            %Plot Left/Right classification
            figure
            PlotData(mTSNE, vecClassLR, vS, nSubjects,subjects,2);
            sgtitle('Parallel Transport (PT): Left/Right classification','FontSize',26)
            subplot(1,2,1); title('Class labels','FontSize',20)
            subplot(1,2,2); title('Subjects','FontSize',20)         
        end
     
       
    end
end


savePathNew = [savePath,'BTandPT\',subjectChoise];
if exist(savePathNew, 'dir') == 0
    % If it doesn't exist, create the folder
    mkdir(savePathNew);
end

data.baselineData = baselineData;
data.accBT = accBT;
data.accPT = accPT;
data.referenceSubjects = refSubs;
data.candidateSubjects = candSubs;
data.referenceCombinations = refCombs;
data.cfg.subjectChoise = subjectChoise;
data.cfg.ButterworthFilterOrder = filterOrder;
data.cfg.fs = 64;
data.cfg.nChannels = length(channels);
data.cfg.kNN = k;

if saveData
    fname = [savePathNew,'\BTandPTdata.mat'];
    save(fname,'data')
end

%% Functions

function Covs = CalcCovs(Events)
    for ii = 1 : length(Events)
        mX       = Events{ii}';
        Covs{ii} = cov(mX');
    end
end

function PlotData(mX, vClass, vS, N,subjects,labels)
    vMarker = 'brgykmcw';
    vColorS = 'brgykmcw';
    vColorC = 'gykmcw';
    vUniqueS  = unique(vS);
    
    subplot(1,2,2);
    for cc = 1 : 2
        vIdxC = vClass == cc;
        for ss = 1 : N
            marker = vMarker(ss);
            vIdxS  = vS == vUniqueS(ss);
            color  = vColorS(ss);
            vIdx   = vIdxS & vIdxC;
            scatter(mX(1,vIdx), mX(2,vIdx), 50, color, marker, 'Fill', 'MarkerEdgeColor', 'k'); hold on;
            xlabel('[arb. unit]','FontSize',28)
            ylabel('[arb. unit]','FontSize',28)
        end
    end
    
    text{N,1} = [];
    for s = 1:N
        text{s} = ['Subject - ' num2str(subjects(s))];
    end
    text = char(text);  
    h = legend(text, ...
                'FontSize', 24, 'Location', 'Best'); set(h, 'Color', 'None');
    axis tight;
    
    subplot(1,2,1);
    for ss = 1 : N
        marker = vMarker(ss);
        vIdxS  = vS == vUniqueS(ss);
        for cc = 1 : 2
            color  = vColorC(cc);
            vIdxC = vClass == cc;
            vIdx  = vIdxS & vIdxC;
            scatter(mX(1,vIdx), mX(2,vIdx), 50, color, marker, 'Fill', 'MarkerEdgeColor', 'k'); hold on;
            xlabel('[arb. unit]','FontSize',28)
            ylabel('[arb. unit]','FontSize',28)
        end
    end
    
    if labels == 1
        text = {'Attended Male','Attended Female'};
    elseif labels == 2
        text = {'Attended Left','Attended Right'};
    end
    h = legend(text, 'FontSize', 24, 'Location', 'Best'); set(h, 'Color', 'None');
    axis tight;
end

function allCombinations = generateAllCombinations(inputVector,choise)
    % Pre-allocate memory for the result cell array
    if choise == 1 || choise == 2
        allCombinations = cell(sum(2.^(1:length(inputVector)))/2,1);
   
    % Counter for the current position in allCombinations
        currentIdx = 1;

    % Generate unique combinations for each size
        for k = 1:length(inputVector)
            combinations = nchoosek(inputVector, k);
        
            % Determine the number of combinations for the current size
            numCombinations = size(combinations, 1);
        
            % Copy the combinations to allCombinations
            allCombinations(currentIdx : currentIdx + numCombinations - 1) = num2cell(combinations, 2);
        
            % Update the current index
            currentIdx = currentIdx + numCombinations;
        end
    else
        allCombinations = num2cell(1:18,2);
    end

end



