%% Plotting baseline classification accuracy
clc; clear; close;
user = 'User'; %'Author';
dataPath = ['[path_to_main_script]\Results\',user,'\']; % [Insert path]

disp('This script plots the classification accuracy for baseline, BT and PT classification accuracy.');

% True if you want to plot baseline classification accuracy
plotBaseline = true;

% True if data from MainBTandBT.m has been saved for choise = 3 where 17 reference subjects are used for each candidate
plotBTallSubs = true; 

% True if you want to plot classification accuracy for custom choise of
% reference and candidate subjects 
% (Hence, true if choise = 2 in MainBTandPT.m)
plotUserChoise = false; 

if plotUserChoise
    fname = 'UserChoise';
else
    fname = 'BaselineEvaluation'; % Reference and candidate subjects chosen from MainBaseline.m
end
load([dataPath,'BTandPT\',fname,'\BTandPTdata.mat']);

if plotBTallSubs
    dataAll = load([dataPath,'BTandPT\AllSubjects\BTandPTdata.mat']);
end

% Choose which task (Male/Female: 1) or (Left/right: 2) to plot
task = 2;

% Choose which classification method to use (SVM: 1, Decision Tree: 2,
% k-NN; 3)
method = 1;

y = 60; %Significance level in 2-classification problems and nTrials = 60 
nTotSubs = length(data.baselineData.acc); % Total number of subjects


%% Baseline classification accuracy
% Extract the baseline accuracy for chosen task and method
baselineAcc = zeros(1,nTotSubs);
for s = 1:nTotSubs
    baselineAcc(s) = data.baselineData.acc{s}{task}(method);
end
meanAcc= mean(baselineAcc);
stdAcc = std(baselineAcc);
x = linspace(1,nTotSubs,nTotSubs);

% Plot the baseline accuracy for chosen task and method
figure
bar(x,baselineAcc);
hold on
yline(meanAcc-stdAcc,'-.b','LineWidth',2.5)
yline(meanAcc+stdAcc,'-.b','LineWidth',2.5)
yline(y,'k','LineWidth',3)
set(gca,'FontSize',24)
legend('Classification Accuracy','Mean +- std','','Significance level','FontSize',22)
title('Cross validation classification accuracy for each subject','FontSize',38)
xlabel('Subjects','FontSize',26)
ylabel('Accuracy (%)','FontSize',26)
xticks(1:nTotSubs)
xticklabels({'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','FontSize',24})
axis([0 19 20 100])


%%
nCombs = length(data.referenceCombinations); %Number of reference combindations
nCandSubs = length(data.candidateSubjects); % Number of candidate subjects
BT = cell(1,nCandSubs);
PT = cell(1,nCandSubs);
allSubsBT = cell(1,nCandSubs);
allSubsPT =  cell(1,nCandSubs);

% Extract BT and PT classification accuracy for chosen task and method
for s = 1:nCandSubs % For each candidate subject
    for ss = 1:nCombs % For each reference combination
        BT{s}(ss) = data.accBT{ss,s}{task}(method);
        PT{s}(ss) = data.accPT{ss,s}{task}(method);
    end
    
    if plotBTallSubs
        allSubsBT{s} = dataAll.data.accBT{s}{task}(method);
        allSubsPT{s} = dataAll.data.accPT{s}{task}(method);
    end
end

meanBT = zeros(1,nCombs);
meanPT = zeros(1,nCombs);
for i = 1:nCombs
    tmp = zeros(2,nCandSubs);
    for j = 1:nCandSubs
        tmp(1,j) = BT{j}(i);
        tmp(2,j) = PT{j}(i);
    end
    meanBT(i) = mean(tmp(1,:));
    meanPT(i) = mean(tmp(2,:));
end


%% Plotting BT and PT for each candidate subject
% Number of subplots = number of candidate subjects
nY = round(sqrt(nCandSubs));    % Number of subplots in y-axis
nX = nCandSubs - nY;            % Number of subplots in x-axis

tickLabels = cell(nCombs);
for i = 1:nCombs
    tmp = data.referenceCombinations{i};
    tickLabels{i} = num2str(tmp);
end
%%
x = linspace(1,nCombs,nCombs);
figure
sgtitle('Classification accuracy','FontSize',38)
for i = 1:nCandSubs
    candSub = data.candidateSubjects(i);
    subplot(nX,nY,i)
    bar(x,[BT{i}; PT{i}]);
    if plotBTallSubs
        yline(allSubsBT{i},'-b','LineWidth',1.5);
    end
    hold on
    yline(baselineAcc(candSub),'-k','LineWidth',1.5);
    set(gca,'FontSize',20)
    title(['Candidate subject: ',num2str(candSub)],'FontSize',24)
    xlabel('Reference subjects','FontSize',20)
    ylabel('Accuracy (%)','FontSize',20)
    xticks(1:nCombs)
    xticklabels(tickLabels)
    axis([0 1+nCombs 35 85])
end
if plotBTallSubs
    legendText = {'Before transport','Parallel transport','BT all subjects','Cand sub baseline'};
else
    legendText = {'Before transport','Parallel transport','Cand sub baseline'};
end
legend(legendText,'FontSize',20)



%% Evaluate which reference combination that perform the best result
% Two different metrices are used to evaluate which reference combination
% that perform the best result, where high values of both metrices are
% considered a good result

    % Metrix 1: PT - BT (difference between the classification accuracy for
    % PT and BT
    
    % Metrix 2: PT (classification accuracy for PT)
nMetrices = 2; 

stats = zeros(nMetrices,nCombs);
for i = 1:nCombs
    tmp = zeros(nMetrices,nCandSubs);
    for s = 1:nCandSubs
        tmp(1,s) = PT{s}(i) - BT{s}(i);
        tmp(2,s) = PT{s}(i);
    end
    stats(1,i) = mean(tmp(1,:));
    stats(2,i) = mean(tmp(2,:));
end
clear tmp

%%

figure
bar(x,[stats(1,:); stats(2,:)]);
hold on
set(gca,'FontSize',24)
legend('(i) PT-BT','(ii) PT','FontSize',26)
title('Mean accuracy over candidate subjects #(1,2,5,16)','FontSize',38)
xlabel('Reference subjects','FontSize',26)
ylabel('Accuracy (%)','FontSize',26)
xticks(1:nCombs)
xticklabels(tickLabels)
axis([0 1+nCombs 0 80])

%%
sorted = zeros(nMetrices,nCombs);
idx = zeros(nMetrices,nCombs);
for i = 1:nMetrices
    [sorted(i,:),idx(i,:)] = sort(stats(i,:),'descend');
end
%%
bestComb1 = data.referenceCombinations(idx(1,:));
bestComb2 = data.referenceCombinations(idx(2,:));

disp('---------------------------------------------------------------')
disp(['The two best reference combination according to metrix 1:']);
disp(['(',num2str(bestComb1{1}),') and (' ,num2str(bestComb1{2}),')'])
disp(['The two best reference combination according to metrix 2:']);
disp(['(',num2str(bestComb2{1}),') and (' ,num2str(bestComb2{2}),')'])
disp('---------------------------------------------------------------')
disp(['To produce figure 8 in the paper, run "MainBTandPT.m" with the two best'...
' reference combinations on all subjects except for candidates (',num2str(data.candidateSubjects),')'])



%%


