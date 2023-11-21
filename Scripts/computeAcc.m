function acc = computeAcc(mX, vClass,method,k,p)

% INPUTS:
% mX: Vectorized covariance matrices
% vClass: Classification labels
% vS: Subject ID for each trial
% method: Classification methods
% k: Number of nearest neighbour in k-NN
% p: Level of statisically significant in problems with two classes

% OUTPUT: acc
% Classification accuracy
% y (Level of statisitically significance with limited data)
% f (0 if statistically significant, 1 otherwise)

% Number of classification methods
nMethods = length(method);

% Number of subjects
preAcc{nMethods,1} = [];
f = zeros(nMethods,1);

% Number of trials
n = length(vClass);
vS = 1:n;

% For each trial
for s = 1:n

    trainSubjects = vS ~= s; % Set training trials as all trials except s
    testSubjects = vS == s;  % Set testing trial to s
    
    trainClasses = vClass(vS ~= s)'; %Y
    testClasses = vClass(vS == s)'; %Ynew
    
    mX1 = mX(:, trainSubjects)'; %X
    mX2 = mX(:, testSubjects)'; %Xnew
    
    % SVM
    Mdl = fitcsvm(mX1, trainClasses);
    preAcc{1}(s) = mean(Mdl.predict(mX2) == testClasses);
    
    % Decision tree
    Mdl = fitctree(mX1,trainClasses);
    preAcc{2}(s) = mean(Mdl.predict(mX2) == testClasses);
        
    % k-Nearest Neighbour    
    for kk = 1:length(k)
        Mdl = fitcknn(mX1,trainClasses,'NumNeighbors',k(kk));
        preAcc{2+kk}(s) = mean(Mdl.predict(mX2) == testClasses);
    end
       
  
end
acc = zeros(nMethods,2); 
format short g;

for ii = 1:nMethods
    acc(ii,1) = round(mean(preAcc{ii}*100),2);
    x = binoinv(0.95,n,p);
    y = x/n;
    acc(ii,2) = round(y*100,2);
    if (acc(ii,1)/100) > y
        acc(ii,3) = 0; %Statistically significant at 95% confidence interval
    else
        acc(ii,3) = 1; %Not statistically significant
    end  
end



end
