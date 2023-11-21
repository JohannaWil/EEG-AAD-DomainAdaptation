function dist = RiemannianDist(mP1, mP2, p)

%Written by Or Yair, Mirela Ben-Chen and Ronen Talmon
%Explained in the article "Parallel Transport on the Cone Manifold of SPD
%Matrices for Domain Adaptation"
%https://github.com/oryair/ParallelTransportSPDManifold


   if nargin < 3
       p = 2;
   end
    
    vLam = eig(mP2, mP1); %Vector of eigenvalues
    
    if p == 1 %-- just for speed
        dist = sum(abs(log(vLam)));
    else
        dist = sum(abs(log(vLam)).^p ).^(1/p); %blir en skal�r
    end
    
end