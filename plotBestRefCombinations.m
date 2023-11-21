%% Plot figure 6: Best reference combinations
clc; clear; close;

user = 'User'; %'Author';
dataPath = ['[path_to_main_script]\Results\',user,'\BTandPT\bestRefComb\']; % [Insert path]
load([dataPath,'BTandPTdata.mat']);

% Choose if you want to exclude some candidate subjects in the plot. Figure
% 6 has excluded [1,2,5,16] since the result for these subjects were
% presented in figure 5. Reference subjects are already excluded.
excludeSubjects = [1,2,5,16]; % [];
[candSubs,idx] = setdiff(data.candidateSubjects,excludeSubjects);

% Number of candidate subjects
nCandSubs = length(candSubs);

% Number of reference combinations
nCombs = length(data.referenceCombinations);

% Number of candidate subjects plus mean result
nTicks = length(candSubs) + 1;

%task = 1 (MF), task = 2 (LR)
%method = 1 (SVM), method = 2 (Tree)
% method = 3 (k-NN 1), method = 4 (k-NN 2)
task = 2;
method = 1;
y = 60; %Significance level in 2-classification problems and nTrials = 60 

baselineAcc = zeros(1,nTicks);
labels = cell(1,nTicks);
BT = cell(1,nCombs);
PT = cell(1,nCombs);
for s = 1:nCandSubs
    candSub = candSubs(s);
    baselineAcc(s) = data.baselineData.acc{candSub}{task}(method);
    labels{s} = num2str(candSub);
    for i = 1:nCombs
       BT{i}(s) = data.accBT{i,idx(s)}{task}(method);
       PT{i}(s) = data.accPT{i,idx(s)}{task}(method);
    end
end
%%
baselineAcc(nTicks) = mean(baselineAcc(1:nCandSubs));
labels{nTicks} = 'Mean';
for i = 1:nCombs
    BT{i}(nTicks) = mean(BT{i}(1:nCandSubs));
    PT{i}(nTicks) = mean(PT{i}(1:nCandSubs));
end

x = linspace(1,nTicks,nTicks);
meanAcc= mean(baselineAcc);
stdAcc = std(baselineAcc);
%%
figure
sgtitle('Classification accuracy','FontSize',40)
subplot(1,2,1)
bar(x,[baselineAcc; BT{1}; PT{1}]);
hold on
yline(y,'-k');
yline(meanAcc-stdAcc,'-.k');
yline(meanAcc+stdAcc,'-.k');
set(gca,'FontSize',24)
title(['Reference subject: ',num2str(data.referenceCombinations{1})],'FontSize',38)
xlabel('Candidate subject','FontSize',26)
ylabel('Accuracy (%)','FontSize',26)
xticks(1:length(labels))
xticklabels(labels);
axis([0 nTicks+1 35 100])

subplot(1,2,2)
bar(x,[baselineAcc; BT{2}; PT{2}]);
hold on
yline(y,'-k');
yline(meanAcc-stdAcc,'-.k');
yline(meanAcc+stdAcc,'-.k');
set(gca,'FontSize',24)
legend('(1) Baseline','(2) Before Transportation','(3) Parallel Transport','Significance level','Mean +- std all subjects','','FontSize',18)
title(['Reference subject: ',num2str(data.referenceCombinations{2})],'FontSize',38)
xlabel('Candidate subject','FontSize',26)
ylabel('Accuracy (%)','FontSize',26)
xticks(1:nTicks)
xticklabels(labels);
axis([0 nTicks+1 35 100])