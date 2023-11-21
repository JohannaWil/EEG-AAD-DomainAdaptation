function plotRiemannianMean(CovsVec,M,D,vS,subjects,CovsPT)

%Plot figure 9 in the article "Domain Adaptation for Attention Steering" by
%Johanna Wilroth et. al.

%Input:
    %CovsVec: Vector of covariance matrices. Each covariance matrix
    %represent one trial
    %M: Vector of the Riemannian means Ms for each subject s. The
    %Riemannian means are represented as covariance matrices
    %D: The Riemannian mean D of all Ms. It is represented as a covariance
    %matrix
    %vS: Vector which tells which subject each trial belongs to. Used for
    %labeling
    %Subjects: The subjects used in the script. Can be changed in the
    %beginning of the main script.
    %CovsPT: The covariance matrices after Parallel Transport

N = length(subjects);
n = size(CovsVec,2);
vS1 = vS; %Subject labeling before transportation
vS2 = vS; %Subject labeling after Parallel Transport

%Add the Riemannian means Ms for each subject s (before transportation)
for s = 1:N
    CovsVec{n+s} = M{s};
    vS1(n+s) = N+1;
end

%Add the Riemannian mean D
CovsVec{n+N+1} = D; %Before transportation
CovsPT(:,:,n+1) = D; %After Parallel Transport

%Update labeling vectors
vS1(n+N+1) = N+2; %Before transportation
vS2(n+1) = N+1; %After Parallel Transport

%Reshape
mX1 = CovsToVecs(cat(3, CovsVec{:})); %Before transportation
mX2 = CovsToVecs(CovsPT); %After Parallel Transport

ndatapoints = size(mX1,1); %Number of datapoints before transportation
nCovs_mX1 = size(mX1,2); %Number of covariance matrices before transportation
nCovs_mX2 = size(mX2,2); %Number of covariance matrices after Parallel Transport
totCovs = nCovs_mX1 + nCovs_mX2; %Total number of covariance matrices

mX = zeros(ndatapoints,totCovs);
mX(:,1:nCovs_mX1) = mX1;
mX(:,nCovs_mX1+1:end) = mX2;

%Compute t-SNE
mTSNE = tsne(mX');
mTSNE(totCovs,:) = mTSNE(nCovs_mX1,:);

%Create labels
text{N,1} = [];
for s = 1:N
    text{s} = ['Subject - ' num2str(subjects(s))];
end
text1 = text; %Before transportation
text2 = text; %After Parallel Transport
text1{N+1} = 'Ms';
text1{N+2} = 'D';
text2{N+1} = 'D';
text1 = char(text1);
text2 = char(text2);


markSize1 = 16*ones(nCovs_mX1,1);
markSize1(n+1:nCovs_mX1,1) = 30;

markSize2 = 16*ones(1,size(vS2,2));
markSize2(1,n+1:nCovs_mX2) = 30;


%Plot
figure
subplot(1,2,1)
gscatter(mTSNE(1:n,1),mTSNE(1:n,2),vS1(1:n),'cgm','.',markSize1(1:n))
hold on
gscatter(mTSNE(n+1:nCovs_mX1,1),mTSNE(n+1:nCovs_mX1,2),vS1(n+1:end),'bk','.',34)
hold off
title('Before transportation', 'FontSize', 24); xlabel('[arb. unit]', 'FontSize', 24')
    ylabel('[arb. unit]', 'FontSize', 22')
legend(text1, 'FontSize', 22, 'Location', 'Best');
subplot(1,2,2)
gscatter(mTSNE(nCovs_mX1+1:end-1,1),mTSNE(nCovs_mX1+1:end-1,2),vS2(1:n),'cgm','.',markSize2(1:n))
hold on
gscatter(mTSNE(end,1),mTSNE(end,2),vS2(end),'k','.',34)
hold off
title('After transportation', 'FontSize', 24'); xlabel('[arb. unit]', 'FontSize', 24)
    ylabel('[arb. unit]', 'FontSize', 22)
legend(text2, 'FontSize', 22, 'Location', 'Best');
%%
% figure
% subplot(1,2,1)
% gscatter(mTSNE(1:nCovs_mX1,1),mTSNE(1:nCovs_mX1,2),vS1,'cgmbr','.',markSize1)
% hold on
% gscatter(mTSNE(1:nCovs_mX1,1),mTSNE(1:nCovs_mX1,2),vS1,'cgmbr','.',markSize1)
% hold off
% title('Before transportation', 'FontSize', 24); xlabel('[arb. unit]', 'FontSize', 20')
%     ylabel('[arb. unit]', 'FontSize', 20')
% legend(text1, 'FontSize', 20, 'Location', 'Best');
% subplot(1,2,2)
% gscatter(mTSNE(nCovs_mX1+1:end,1),mTSNE(nCovs_mX1+1:end,2),vS2,'cgmr','.',markSize2)
% title('After transportation', 'FontSize', 24'); xlabel('[arb. unit]', 'FontSize', 20)
%     ylabel('[arb. unit]', 'FontSize', 20)
% legend(text2, 'FontSize', 20, 'Location', 'Best');
% %% BEFORE
% figure
% subplot(1,2,1)
% gscatter(mTSNE(1:nCovs_mX1,1),mTSNE(1:nCovs_mX1,2),vS1,'grkb')
% title('Before transportation', 'FontSize', 16); xlabel('[arb. unit]', 'FontSize', 16')
%     ylabel('[arb. unit]', 'FontSize', 16')
% legend(text1, 'FontSize', 12, 'Location', 'Best');
% subplot(1,2,2)
% gscatter(mTSNE(nCovs_mX1+1:end,1),mTSNE(nCovs_mX1+1:end,2),vS2,'grb')
% title('After transportation', 'FontSize', 16'); xlabel('[arb. unit]', 'FontSize', 16)
%     ylabel('[arb. unit]', 'FontSize', 16)
% legend(text2, 'FontSize', 12, 'Location', 'Best');

end