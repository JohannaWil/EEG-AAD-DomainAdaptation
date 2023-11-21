function checkStationarity(EEG)

for i = 1:64
    figure
    subplot(4,1,1)
    plot(EEG{1}(:,i));
    title(['Channel ' num2str(i)])
    
    subplot(4,1,2)
    normplot(EEG{1}(:,i));
    
    subplot(4,1,3)
    autocorr(EEG{1}(:,i))
    
    subplot(4,1,4)
    parcorr(EEG{1}(:,i))
    
end
    

end