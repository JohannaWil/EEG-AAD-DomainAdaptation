%% Plotting baseline classification accuracy (figure 4)
clc; clear; close;
user = 'User'; %'Author';
dataPath = ['[path_to_main_script]\Results\',user,'\']; % [Insert path]

%task = 1 (MF), task = 2 (LR)
%method = 1 (SVM), method = 2 (Tree), method = 3 (k-NN)
task = 2;
method = 1;

y = 60; % Significance level in 2-classification problems and nTrials = 60 

load([dataPath,'baselineData.mat']);
nSubjects = length(acc);
baselineAcc = zeros(1,nSubjects);
%%
for s = 1:nSubjects
    baselineAcc(s) = acc{s}{task}(method);
end
meanAcc= mean(baselineAcc);
stdAcc = std(baselineAcc);

x = linspace(1,nSubjects,nSubjects);
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
xticks(1:nSubjects)
xticklabels({'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','FontSize',24})
axis([0 19 20 100])


