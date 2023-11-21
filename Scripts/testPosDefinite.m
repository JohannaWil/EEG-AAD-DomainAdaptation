function testPosDefinite(Covs,subject)

N_subjects = length(Covs);
N_trials = size(Covs{1},2);
eig_Covs{N_subjects,1} = [];
flag{N_subjects,1} = [];

for s = 1:N_subjects
   for i = 1:N_trials
      eig_Covs{s}{i} = eig(Covs{s}{i});
      for j = 1:rank(Covs{s}{i})
          if eig_Covs{s}{i}(j) < 0
              flag{s}(j) = 1;
          else
              flag{s}(j) = 0;
          end
      end 
   end
end

for s = 1:N_subjects
    if all(flag{s} == 0)
        disp(['Subject ' num2str(subject(s)) ': All covariance matrices are positive definite'])
    else
        disp(['Subject ' num2str(subject(s)) ': Covariance matrices are NOT positive definite'])
    end
end