function M = RiemannianMean(tC)

%Written by Or Yair, Mirela Ben-Chen and Ronen Talmon
%Explained in the article "Parallel Transport on the Cone Manifold of SPD
%Matrices for Domain Adaptation"
%https://github.com/oryair/ParallelTransportSPDManifold

Np = size(tC, 3); 
M  = mean(tC, 3);

% h = waitbar(0, 'Riemannian Mean');
for ii = 1:20
%     waitbar(ii / 20);
    A = M^(1/2);      %-- A = C^(1/2)
    B = A^(-1);       %-- B = C^(-1/2)
        
    S = zeros(size(M));
    %The Logarithm map S, which projects an SPD matrix C on the target
    %plane TpM at B, is given by:
    for jj = 1:Np
        C = tC(:,:,jj);
        S = S + A*logm(B*C*B)*A; %logm: matrix logarithm. Si in article
    end
    S = S / Np;
    
    %The Exponential map, which projects a vector S back to the manifold M
    %is given by:
    M = A*expm(B*S*B)*A; %P_i in article
    
    eps = norm(S, 'fro');
    if (eps < 1e-6)
        break;
    end
end
% close(h);

end