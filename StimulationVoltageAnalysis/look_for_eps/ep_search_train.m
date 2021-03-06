
%% initialize output and meta dir
% clear workspace, get rid of extraneous information
%close all; clear all; clc
%% David.J.Caldwell 10.10.2018
saveIt = 0;

subj_info % get information for all of the subjects

SUBJECT_DIR = getenv('SUBJECT_DIR');

blocksInt = [7,8];
subjsNumericVec = [1];

reref = 1;
preTime = 1000;
postTime = 2000;
trainDuration = [0 200]; % this is how long the stimulation train was
xlims = [-50 500]; % these are the x limits to visualize in plots
minDuration = 0.5; % minimum duration of artifact in ms

type = 'dictionary';
useFixedEnd = 0;
%fixedDistance = 2;
fixedDistance = 4; % in ms
plotIt = 0;

%pre = 0.4096; % in ms
%post = 0.4096; % in ms

pre = 0.8; % started with 1
post = 3; % started with 0.2
% 2.8, 1, 0.5 was 3/19/2018

% these are the metrics used if the dictionary method is selected. The
% options are 'eucl', 'cosine', 'corr', for either euclidean distance,
% cosine similarity, or correlation for clustering and template matching.

distanceMetricDbscan = 'eucl';
distanceMetricSigMatch = 'eucl';
amntPreAverage = 3;
normalize = 'preAverage';
%normalize = 'firstSamp';

recoverExp = 0;
bracketRange = [-10:10];


%%
for subjNum = subjsNumericVec
    sid = infoStructSubj(subjNum).sid;
    % structureData = uiimport('-file');
    for block = blocksInt
        load(fullfile(SUBJECT_DIR,sid,infoStructSubj(subjNum).extraString,[infoStructSubj(subjNum).fileName num2str(block) '.mat']));
        
        % get patient/block specific data
        numChans = infoStructSubj(subjNum).numChans;
        stimChans = infoStructSubj(subjNum).stimChans{block};
        badChans = infoStructSubj(subjNum).badChans{block};
        badsTotal = [stimChans badChans];
        chanIntList = infoStructSubj(subjNum).chanIntList{block};
        rerefChans = infoStructSubj(subjNum).rerefChans;
        
        chanIntList = [104:108];
        
        if size(ECO1.data,1) == size(ECO3.data,1)
            data = 4.*[ECO1.data ECO2.data ECO3.data]; % add in factor of 4 10.10.2018
        else
            data = 4.*[ECO1.data(1:end-1,:) ECO2.data(1:end-1,:) ECO3.data]; % add in factor of 4 10.10.2018
        end
        fsData = ECO1.info.SamplingRateHz;
        
        preSamps = round(preTime/1000 * fsData); % pre time in sec
        postSamps = round(postTime/1000 * fsData); % post time in sec,
        
        %%
        % get sampling rates
        fsStim = Stim.info.SamplingRateHz;
        fsSing = Sing.info.SamplingRateHz;
        
        % stim data
        stim = Stim.data;
        
        % current data
        sing = Sing.data;
        
        
        %% stimulation voltage monitor
        plotIt = 0;
        savePlot = 0;
        [stim1Epoched,tEpoch,fs,labels,uniqueLabels] = voltage_monitor(Stim,Sing,plotIt,savePlot,'','','');
        
        %% extract average signals either as separated single trials or a big block
        [sts,bursts] = get_epoch_indices(sing,fsData,fsSing);
        
        timeThresh = 100; % ms
        diffSts = diff(sts);
        [~,I] = find(diffSts>timeThresh*fsData/1e3);
        
        sts = sts([1,I+1]);
        labels = labels([1,I+1]);
        %%
        dataEpoched = squeeze(getEpochSignal(data,sts-preSamps,sts+postSamps+1));
        % set the time vector to be set by the pre and post samps
        tEpoch = (-preSamps:postSamps)/fsData;
        
        %%
        
%         [processedSig,templateDictCell,templateTrial,startInds,endInds] = analyFunc.template_subtract(dataEpoched,'type',type,...
%             'fs',fsData,'plotIt',plotIt,'pre',pre,'post',post,'stimChans',stimChans,...
%             'useFixedEnd',useFixedEnd,'fixedDistance',fixedDistance,...,
%             'distanceMetricDbscan',distanceMetricDbscan,'distanceMetricSigMatch',distanceMetricSigMatch,...
%             'recoverExp',recoverExp,'normalize',normalize,'amntPreAverage',amntPreAverage,...
%             'minDuration',minDuration,'bracketRange',bracketRange);
%         
        %
        processedSig = dataEpoched;
        % deal with rereferencing
        
        if reref
            rerefChansData = processedSig(:,rerefChans);
            rerefChansData = mean(rerefChansData,2);
            data = processedSig - repmat(rerefChansData,1,numChans);
        end
        %
        % visualization
        % of note - more visualizations are created here, including what the
        % templates look like on each channel, and what the discovered templates are
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
        for uniq = uniqueLabels
            boolLabels = labels==uniq;
            %             vizFunc.multiple_visualizations(processedSig(:,:,boolLabels),dataEpoched(:,:,boolLabels),'fs',fsData,'type',type,'tEpoch',...
            %                 tEpoch,'xlims',xlims,'trainDuration',trainDuration,'stimChans',stimChans,...,
            %                 'chanIntList',chanIntList,'templateTrial',templateTrial,'templateDictCell',templateDictCell,'modePlot','confInt')
            %             %
            average = 1;
            %chanIntList = 3;
            trainDuration = [];
            modePlot = 'avg';
            xlims = [-50 400];
            ylims = [-800 800];
%             for chanInt = chanIntList
%                 figure
%                 meanInt = mean(squeeze(processedSig(:,chanInt,:)),2);
%                 plot(1e3*tEpoch,1e6*meanInt,'linewidth',4)
%                 xlim(xlims)
%                 ylim(ylims)
%                 ylabel(['Voltage \muV'])
%                 xlabel(['Time (ms)'])
%                 title(['Channel ' num2str(chanInt)])
%             end
%             
            vizFunc.small_multiples_time_series(processedSig(:,:,boolLabels),tEpoch,'type1',stimChans,'type2',0,'xlims',xlims,'ylims',ylims,'modePlot',modePlot,'highlightRange',trainDuration)
            
            
            signal = nanmean(processedSig(:,97:112,:),3);
            %%
            figure
            CT = vizFunc.cbrewer('qual','Accent',8);
            CT = flipud(CT);
            for idx=1:16
                %smplot(p(1),p(2),idx,'axis','on')
                plt_sub = vizFunc.smplot(1,16,idx,'axis','on');
                
                plot(1e3*tEpoch,1e6*signal(:,idx),'Color',CT(1,:),'LineWidth',2)
                title([num2str(idx)],'Color',CT(1,:))
                  axis off
            axis tight
            %xlim([-10 200])
            xlim(xlims)
            ylim(ylims)
            vizFunc.vline(0)
                
            end
            
            
          
            obj = vizFunc.scalebar;
            obj.XLen = 200;              %X-Length, 10.
            obj.XUnit = 'ms';            %X-Unit, 'm'.
            obj.YLen = 300;
            obj.YUnit = '\muV';
            
            obj.Position = [20,-130];
            obj.hTextX_Pos = [5,-50]; %move only the LABEL position
            obj.hTextY_Pos =  [-45,-40];
            obj.hLineY(2).LineWidth = 5;
            obj.hLineY(1).LineWidth = 5;
            obj.hLineX(2).LineWidth = 5;
            obj.hLineX(1).LineWidth = 5;
            obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
            
            
            
            
        end
        
        
        
        %% plot epoched signals
        %  plot_EPs_fromEpochedData(dataEpoched,t,uniqueLabels,labels,infoStructSubj(subjNum).stimChans{block})
        
        %%
        if saveIt
            if reref
                save([sid '_EP_' regexprep(num2str(stimChans),'  ','_','emptymatch'),'_reref'],'stim1Epoched','dataEpoched','t','uniqueLabels','labels')
            else
                save([sid '_EP_' regexprep(num2str(stimChans),'  ','_','emptymatch')],'stim1Epoched','dataEpoched','t','uniqueLabels','labels')
            end
        end
    end
end
