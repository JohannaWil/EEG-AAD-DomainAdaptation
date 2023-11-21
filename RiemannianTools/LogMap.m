function S = LogMap(B, P)

%Written by Or Yair, Mirela Ben-Chen and Ronen Talmon
%Explained in the article "Parallel Transport on the Cone Manifold of SPD
%Matrices for Domain Adaptation"
%https://github.com/oryair/ParallelTransportSPDManifold

    BP = B^(1/2);
    BN = B^(-1/2);
    S  = BP * logm(BN * P * BN) * BP;
end