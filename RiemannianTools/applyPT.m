function [CovsPT M D] = applyPT(allCovs)

Nsubjects = size(allCovs,1);
Nchannels = size(allCovs{1}{1},1);
Ntrials = size(allCovs{1},2);


% Algorithm 1: steps 1-3 Parallel Transport

%Step 1: For each subject s, compute the Riemannian mean M of the
%covariance matrices
M{Nsubjects,1} = [];
for s = 1:Nsubjects
    M{s} = RiemannianMean(cat(3, allCovs{s}{:}));
end

%Step 2: Compute the Riemannian mean D of all M
preD = zeros(Nchannels,Nchannels,Nsubjects);
for s = 1:Nsubjects
    preD(:,:,s) = cat(3,M{s});
end
D    = RiemannianMean(preD);

preCovsPT{1,Nsubjects*Ntrials} = [];

%For all subjects s and all covaiance matrices ii, apply Parallel Transport (equation 7)
for s = 1:Nsubjects
    E = (D * M{s}^(-1))^(1/2); %SOM DET VAR INNAN!
    for ii = 1 : Ntrials
        preCovsPT{(s-1)*Ntrials+ii} = E * allCovs{s}{ii} * E';
    end
end

%Reshape
CovsPT = cat(3,preCovsPT{:});


end


