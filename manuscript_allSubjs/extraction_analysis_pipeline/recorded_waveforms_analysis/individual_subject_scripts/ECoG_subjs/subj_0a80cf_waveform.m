%% go through 48 for 0a80cf


stimChansVec = [ 28 27];
currentMatVec = [ 0.002];
% data for further analysis
meanMatAll = zeros(48,2,1,1);
stdMatAll = zeros(48,2,1,1);
numberStimsAll = zeros(1,1,1);
stdEveryPoint = {};
extractCellAll = {};
numChansInt = 48;
counterIndex = 1;
numRows = 1;
numColumns = 1;
sid = '0a80cf';
subjectNum = [];
figTotal =  figure('units','normalized','outerposition',[0 0 1 1]);

for ii = 1:1
    fprintf(['running for subject ' sid '\n']);
    jj = 1;
    fs = 12207;
    stimChans = stimChansVec(ii,:);
    load(fullfile([sid '_StimulationAndCCEPs.mat']))
    ECoGData = permute(ECoGData,[1 3 2]);
    ECoGData = ECoGData(:,[1:48],:);
    [meanMat,stdMat,stdCellEveryPoint,extractCell,numberStims] = voltage_extract_avg(ECoGData,'fs',...
        fs,'preSamps',preSamps,'postSamps',postSamps,'plotIt',0);
    
    [meanMatAll,stdMatAll,numberStimsAll,stdEveryPoint,extractCellAll,figTotal] =  ECoG_subject_processing(ii,jj,...
        meanMat,stdMat,numberStims,stdCellEveryPoint,extractCell,...
        meanMatAll,stdMatAll,numberStimsAll,stdEveryPoint,extractCellAll,...
        stimChans,currentMatVec,numChansInt,sid,plotIt,OUTPUT_DIR,figTotal,numRows,numColumns,counterIndex);
    
    [dataSubset,tSubset] = data_subset(ECoGData,1e3*t,preExtract,postExtract);
    dataSubsetCell{counterIndex} = dataSubset;
    
    sidCell{counterIndex} = sid;
    subjectNum(ii) = 8;
end

[subj_0a80cf_struct] =  convert_mats_to_struct(meanMatAll,stdMatAll,stdEveryPoint,stimChansVec,...
    currentMatVec,numberStimsAll,extractCellAll,sidCell,subjectNum,dataSubsetCell,tSubset);

clearvars meanMatAll stdMatAll numberStimsAll stdEveryPoint stimChans currentMat currentMatVec stimChansVec numberStimsAll extractCellAll sidCell subjectNum sid ii jj counterIndex tSubset dataSubset dataSubsetCell