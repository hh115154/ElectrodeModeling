function [stim1Epoched,t,fsStim,labels,pulseWidths,uniqueLabels,uniquePulseWidths,uniquePulseWidthLabels] = voltage_monitor_different_width(Stim,Sing,plotIt,savePlot,titleToUse,OUTPUT_DIR,saveName)

%VOLTAGE_MONITOR Summary of this function goes here
%   Detailed explanation goes here

% build a burst table with the timing of stimuli
bursts = [];

% first channel of current
Sing1 = Sing.data(:,1);
fsSing = Sing.info.SamplingRateHz;
fsStim = Stim.info.SamplingRateHz;

samplesOfPulse = round(2*fsStim/1e3);

Sing1Mask = Sing1~=0;
dmode = diff([0 Sing1Mask' 0 ]);

dmode(end-1) = dmode(end);

bursts(2,:) = find(dmode==1);
bursts(3,:) = find(dmode==-1);

singEpoched = squeeze(getEpochSignal(Sing1,(bursts(2,:)-1),(bursts(3,:))+1));
t = (0:size(singEpoched,1)-1)/fsSing;
t = t*1e3;


%% Plot stims with info from above, and find the delay!

stim1stChan = Stim.data(:,1);
stim1Epoched = squeeze(getEpochSignal(stim1stChan,(bursts(2,:)-1),(bursts(3,:))+120));

% put around 0
t = (0:size(stim1Epoched,1)-1)/fsStim;
t = t*1e3;

% delay looks to be 7 samples

%% DJC - 10-28-2016 - normalize to baseline

if iscell(singEpoched)
    labels = cellfun(@max,singEpoched);
elseif isnumeric(singEpoched)
    labels = max(singEpoched);
end

uniqueLabels = unique(labels);

pulseWidths = 1e6*(bursts(3,:)-bursts(2,:))/fsStim;
uniquePulseWidths = unique(pulseWidths);
%
% get the delay in stim times - looks to be 7 samples or so
delay = round(0.2867*fsStim/1e3);

%delay = 0; %%%% setting delay = 0 to show better plots

pulseWidthLabels = [labels;pulseWidths];
uniquePulseWidthLabels = unique(pulseWidthLabels','rows')';

% plot the appropriately delayed signal
if plotIt
    stimTimesBegin = bursts(2,:)-1+delay;
    stimTimesEnd = bursts(3,:)-1+delay+120;
    stim1Epoched = squeeze(getEpochSignal(stim1stChan,stimTimesBegin,stimTimesEnd));
    
    for i = uniquePulseWidthLabels
        
        if iscell(stim1Epoched)
            stim1EpochedInt = stim1Epoched{:,labels==i(1) & pulseWidths == i(2)};
        elseif isnumeric(stim1Epoched)
            stim1EpochedInt = stim1Epoched(:,labels==i(1) & pulseWidths == i(2));       
        end
        t = (0:size(stim1EpochedInt,1)-1)/fsStim;
        t = t*1e3;
        figure
        plot(t,mean(stim1EpochedInt,2),'linewidth',2)
        xlabel('Time (ms)');
        ylabel('Voltage (V)');
        title(titleToUse)
        set(gca,'fontsize',14)
        xlim([0 4])
        if savePlot
            SaveFig(OUTPUT_DIR,[saveName]);
        end
    end
end


% % redefine delay for
end
