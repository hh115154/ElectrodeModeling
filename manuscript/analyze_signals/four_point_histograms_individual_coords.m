function histStruct = four_point_histograms_individual_coords(subStruct,plotIt,saveIt)

numIndices = size(subStruct.meanMat,3);

for index = 1:numIndices
    % setup temporary structure
    stimChans = subStruct.stimChans(index,:);
    current = subStruct.currentMat(index);
    meanMat = subStruct.meanMat(:,:,index);
    locs = subStruct.locs{index};
    
    numChans = size(meanMat,1);
    channelSelect = logical(zeros(numChans,1));
    channelSelect(subStruct.badTotal{index}) = 1;
    dataScreened = meanMat(:,1);
    dataScreened(channelSelect) = nan;
    
    [rho1] = four_point_histogram_calculation_coords(current,locs,stimChans,dataScreened);
    rho1 = rho1(~isnan(rho1) & ~isinf(rho1));
    
    rhoHist.vals = rho1;
    rhoHist.mean = mean(rho1(:));
    rhoHist.std = std(rho1(:));
    rhoHist.median = median(rho1(:));
    
    histStruct.hist{index} = rhoHist;
    
    bins = [0:0.1:10];
    % plot histogram
    if plotIt
        histogram(rhoHist.vals,bins,'normalization','pdf');
        set(gca,'fontsize',14)
        title(['Subject ' num2str(subStruct.subjectNum(index))])
        xlim([0 10])
        xlabel(['\rho_{apparent}'])
        if saveIt
        end
    end
end

if plotIt
    figure;
    for index = 1:numIndices
        subplot(2,4,index);histogram(histStruct.hist{index}.vals,bins,'normalization','pdf');
        set(gca,'fontsize',16)
        title(['Subject ' num2str(index)])
        xlim([0 10])
    end
    
    xlabel(['\rho_{apparent}'])
    ylabel('probability')
    if saveIt
    end
end

end
