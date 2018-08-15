%% initialize workspace
%clear all; close all;clc
load('all12.mat')

% define matrices to iterate over
dataTotal_8x8 = 4.*[m0b5a2e m702d24 m7dbdec m9ab7ab mc91479 md5cd55 mecb43e];
dataTotal_8x4 = 4.*[m2012(1,:)' m2804(1,:)' m2318(1,:)' m2219(1,:)' m2120(1,:)'];
sidVec = {'0b5a2e','702d24','7dbdec','9ab7ab','c91479','d5cd55','ecb43e','m2012','m2804','m2318','m2219','m2120'};
%sidVec = {'0b5a2e','702d24','7dbdec','9ab7ab','c91479','d5cd55','ecb43e'};

currentMat = [0.00175 0.00075 0.0035 0.00075 0.003 0.0025 0.00175 0.0005 0.0005 0.0005 0.0005 0.0005] ;

% GLOBAL FIT
stimChansVec = {22 30; 13 14; 11 12; 59 60; 55 56; 54 62; 56 64; 12 20; 4 28; 18 23; 19 22; 21 20};

% LOCAL FIT
%stimChansVec = {1:40; 1:33; 1:32; 40:64; [1,33:64]; 39:64; 25:64};

jp_vec = [3 2 2 8 7 7 7 3 4 3 3 3];
kp_vec = [6 5 3 3 7 6 8 4 4 7 6 5];
jm_vec = [4 2 2 8 7 8 8 2 1 3 3 3];
km_vec = [6 6 4 4 8 6 8 4 4 2 3 4];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define colors for lines

color1 = [27,201,127]/256;
color2 = [190,174,212]/256;
color3 = [ 253,192,134]/256;

% perform optimization for the 1 layer case

a=0.00115;
R=0.00115;
d=0.0035;
sigma = 0.05; % this defines for huber loss the transition from squared
% to linear loss behavior

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% optimization for 1 layer
rhoA_vec=[2:0.01:6];
%offset_vec=[-3e-3:1e-5:3e-3];
%offset_vec = [0,1];
offset_vec = [0];
cost_vec_1layer = zeros(length(sidVec),length(rhoA_vec),length(offset_vec));

subject_min_rhoA_vec = zeros(length(sidVec),1);
subject_min_offset1l_vec = zeros(length(sidVec),1);
%%

% loop through subjects
for i = 1:length(sidVec)
    %for i = 1
    
    % select particular values for constants
    i0 = currentMat(i);
    sid = sidVec(i);
    stimChans = stimChansVec{i};
    jp = jp_vec(i);
    kp = kp_vec(i);
    jm = jm_vec(i);
    km = km_vec(i);
    
    % perform 1d optimization
    j = 1;
    for rhoA = rhoA_vec
        % extract measured data and calculate theoretical ones
        k = 1;
        for offset = offset_vec
            if i <= 7 % 8x8 cases
                dataMeas = dataTotal_8x8(:,i);
                [l1] = computePotentials_8x8_l1(jp,kp,jm,km,rhoA,i0,stimChans,offset);
                % c91479 was flipped l1 l3
                if strcmp(sid,'c91479')
                    l1 = -l1;
                end
                
            else % 8x4 case
                dataMeas = dataTotal_8x4(:,i-7);
                [l1] = computePotentials_8x4_l1(jp,kp,jm,km,rhoA,i0,stimChans,offset);
            end
            
            % use a huber loss functiin
            %[h_loss,huber_all] = huber_loss_electrodeModel(dataMeas,l1,sigma);
            
            % use sum sqaured
            h_loss = nansum((dataMeas' - l1).^2);
            
            cost_vec_1layer(i,j,k) = h_loss;
            fprintf(['complete for subject ' num2str(i) ' rhoA = ' num2str(rhoA) ' offset = ' num2str(offset) ' \n ']);
            k = k + 1;
        end
        j = j + 1;
    end
    
end

%[~,index_min] = min(cost_vec_1layer,[],2);
%subject_min_rho = rhoA_vec(index_min);
%%
for i = 1:length(sidVec)
    %for i = 1
    cost_vec_subj = squeeze(cost_vec_1layer(i,:,:));
    
    [value, index] = min(cost_vec_subj(:));
    %[ind1,ind2] = ind2sub(size(cost_vec_subj),index);
    [ind1] = ind2sub(size(cost_vec_subj),index);
    
    subject_min_rhoA_vec(i) = rhoA_vec(ind1);
    %subject_min_offset1l_vec(i) = offset_vec(ind2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 3 layer
% optimization for 3 layer
rho1_vec = [0.55];
rho2_vec= [1.5:0.05:7.5];
rho3_vec = [1.5:0.05:7.5];
height_vec = [0:0.0001:0.002];
%offset_vec=[-3e-3:1e-5:3e-3];
offset_vec = 0;
sigma = 0.05; % sigma for huber loss
cost_vec_3layer = zeros(length(sidVec),length(height_vec),length(rho1_vec),length(rho2_vec),length(rho3_vec),length(offset_vec));

%subject_min_rho1_vec = zeros(length(sidVec),1);
%subject_min_rho2_vec = zeros(length(sidVec),1);
%subject_min_rho3_vec = zeros(length(sidVec),1);
%subject_min_offset3l_vec = zeros(length(sidVec),1);

for i = 1:length(sidVec)
    
    % select particular values for constants
    i0 = currentMat(i);
    sid = sidVec(i);
    stimChans = stimChansVec{i};
    jp = jp_vec(i);
    kp = kp_vec(i);
    jm = jm_vec(i);
    km = km_vec(i);
    
    h = 1;
    for h1 = height_vec
        % perform 3d optimization
        j = 1;
        for rho1 = rho1_vec
            k = 1;
            for rho2 = rho2_vec
                l = 1;
                for rho3 = rho3_vec
                    m = 1;
                    for offset = offset_vec
                        [alpha,beta,eh1,eh2,ed,step,scale] = defineConstants(i0,a,R,rho1,rho2,rho3,d,h1);
                        
                        if i <= 7 % 8x8 cases
                            dataMeas = dataTotal_8x8(:,i);
                            [l3] = computePotentials_8x8_l3(jp,kp,jm,km,alpha,beta,eh1,eh2,step,ed,scale,a,stimChans,offset);
                            % c91479 was flipped l1 l3
                            if strcmp(sid,'c91479')
                                l3 = -l3;
                            end
                            
                        else % 8x4 case
                            dataMeas = dataTotal_8x4(:,i-7);
                            [l3] = computePotentials_8x4_l3(jp,kp,jm,km,alpha,beta,eh1,eh2,step,ed,scale,a,stimChans,offset);
                        end
                        
                        % use huber loss
                        % [h_loss,huber_all] = huber_loss_electrodeModel(dataMeas,l3,sigma);
                        
                        % use mean square loss
                        h_loss = nansum((dataMeas' - l3).^2);
                        
                        cost_vec_3layer(i,h,j,k,l,m) = h_loss;
                        m = m + 1;
                        fprintf(['complete for subject ' num2str(i) ' height = ' num2str(h1) ' rho1 = ' num2str(rho1) ' rho2 = ' num2str(rho2) ' rho3 = ' num2str(rho3) ' offset = ' num2str(offset) ' \n' ]);
                    end
                    l = l + 1;
                end
                k = k + 1;
            end
            j = j + 1;
        end
        h = h + 1;
    end
end
%%
for i = 1:length(sidVec)
    for ii = 1:length(height_vec)
        cost_vec_subj = squeeze(cost_vec_3layer(i,ii,:,:,:,:));
        
        [value, index] = min(cost_vec_subj(:));
        [ind1,ind2] = ind2sub(size(cost_vec_subj),index);
        
        
        % subject_min_rho1_vec(i) = rho1_vec(ind1);
        subject_min_rho2_vec(i,ii) = rho2_vec(ind1);
        subject_min_rho3_vec(i,ii) = rho3_vec(ind2);
        %  subject_min_offset3l_vec(i) = offset_vec(ind4);
    end
end

%%
% for i = 1:length(sidVec)
%     cost_vec_subj = squeeze(cost_vec_3layer(i,:,:,:,:,:));
%
%     [value, index] = min(cost_vec_subj(:));
%     [ind1,ind2,ind3] = ind2sub(size(cost_vec_subj),index);
%
%     subject_min_height_vec(i) = height_vec(ind1);
%
%     % subject_min_rho1_vec(i) = rho1_vec(ind1);
%     subject_min_rho2_vec(i) = rho2_vec(ind2);
%     subject_min_rho3_vec(i) = rho3_vec(ind3);
%     %  subject_min_offset3l_vec(i) = offset_vec(ind4);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% overall resistivity plot with subplots
% 8.13.2018
saveFigBool = true;

figure;

for i = 1:7
    subplot(2,4,i)
    
    plot(1e3*height_vec,subject_min_rho2_vec(i,:),'o-','linewidth',2)
    hold on;plot(1e3*height_vec,subject_min_rho3_vec(i,:),'o-','color','r','linewidth',2)
    
    if i ==7
        h1 = hline(subject_min_rhoA_vec(i),'k','one layer point electrode');
        
    else
        h1 = hline(subject_min_rhoA_vec(i),'k');
        
    end
    h1.LineWidth = 2;
    ylim([1 8])
    title(['Subject ' num2str(i) ])
    set(gca,'fontsize',16)
    
end

xlabel('csf thickness (mm)')
ylabel('resistivity (ohm-m)')
legend({'gray matter','white matter'})

subtitle('Resistivity of cortical layers as a function of presumed CSF thickness')

%%
if saveFigBool
    SaveFig(OUTPUT_DIR, sprintf(['total_bestFitResistivity_v2'], num2str(i)), 'png', '-r300');
end

%% overall conductivity plot with subplots
% 8.13.2018
saveFigBool = true;

figure;

for i = 1:7
    subplot(2,4,i)
    
    plot(1e3*height_vec,1./subject_min_rho2_vec(i,:),'o-','linewidth',2)
    hold on;plot(1e3*height_vec,1./subject_min_rho3_vec(i,:),'o-','color','r','linewidth',2)
    
    if i ==7
        h1 = hline(1./subject_min_rhoA_vec(i),'k','one layer point electrode');
        
    else
        h1 = hline(1./subject_min_rhoA_vec(i),'k');
        
    end
    h1.LineWidth = 2;
    ylim([0 1])
    title(['Subject ' num2str(i) ])
    set(gca,'fontsize',16)
    
end

xlabel('csf thickness (mm)')
ylabel('conductivity (S/m)')
legend({'gray matter','white matter'})

subtitle('Conductivity of cortical layers as a function of presumed CSF thickness')

subject_min_sigA_vec = 1./subject_min_rhoA_vec;
subject_min_sig2_vec = 1./subject_min_rho2_vec;
subject_min_sig3_vec = 1./subject_min_rho3_vec;


%%
if saveFigBool
    SaveFig(OUTPUT_DIR, sprintf(['total_bestFitConductivity_v2'], num2str(i)), 'png', '-r300');
end

%% individual subject plots
saveFigBool = true;

for i = 1:length(sidVec)
    
    figure;
    set(gcf, 'position', [1.0003e+03 779.6667 732 558.6667]);
    
    plot(1e3*height_vec,subject_min_rho2_vec(i,:),'o-','linewidth',2)
    hold on;plot(1e3*height_vec,subject_min_rho3_vec(i,:),'o-','color','r','linewidth',2)
    h1 = hline(subject_min_rhoA_vec(i),'k','one layer point electrode');
    h1.LineWidth = 2;
    xlabel('csf thickness (mm)')
    ylabel('resistivity (ohm-m)')
    legend({'gray matter','white matter'})
    set(gca,'fontsize',14)
    title(['Subject ' num2str(i) ' Resistivity of cortical layers as a function of CSF thickness'])
    
    
    OUTPUT_DIR = pwd;
    if saveFigBool
        SaveFig(OUTPUT_DIR, sprintf(['subject_%s_bestFitRestivity_v2'], num2str(i)), 'png', '-r300');
    end
    
    
    
    figure;
    set(gcf, 'position', [1.0003e+03 779.6667 732 558.6667]);
    plot(1e3*height_vec,1./subject_min_rho2_vec(i,:),'o-','linewidth',2)
    hold on;plot(1e3*height_vec,1./subject_min_rho3_vec(i,:),'o-','color','r','linewidth',2)
    h1 = hline(1./subject_min_rhoA_vec(i),'k','one layer point electrode');
    h1.LineWidth = 2;
    xlabel('csf thickness (mm)')
    ylabel('conductivity (S/m)')
    legend({'gray matter','white matter'})
    set(gca,'fontsize',14)
    title(['Subject ' num2str(i) ' Conductivity of cortical layers as a function of CSF thickness'])
    
    OUTPUT_DIR = pwd;
    if saveFigBool
        SaveFig(OUTPUT_DIR, sprintf(['subject_%s_bestFitConductivity_v2'], num2str(i)), 'png', '-r300');
    end
    
    
    
end

return

%% plotting
% plot

saveFigBool = false;
% setup global figure
figTotal = figure('units','normalized','outerposition',[0 0 1 1]);
figResid = figure('units','normalized','outerposition',[0 0 1 1]);
figLinear = figure('units','normalized','outerposition',[0 0 1 1]);
%
l1_vec = zeros(size(dataTotal_8x8));
l3_vec = zeros(size(dataTotal_8x8));

for i = 1:length(sidVec)
    
    fig_ind(i) = figure('units','normalized','outerposition',[0 0 1 1]);
    % select particular values for constants
    i0 = currentMat(i);
    sid = sidVec(i);
    stimChans = stimChansVec{i};
    jp = jp_vec(i);
    kp = kp_vec(i);
    jm = jm_vec(i);
    km = km_vec(i);
    rho1 = subject_min_rho1_vec(i);
    rho2 = subject_min_rho2_vec(i);
    rho3 = subject_min_rho3_vec(i);
    offset_1l = subject_min_offset1l_vec(i);
    offset_3l = subject_min_offset3l_vec(i);
    rhoA = subject_min_rhoA_vec(i);
    h1 = subject_min_h1_vec(i);
    % perform 1d optimization
    [alpha,beta,eh1,eh2,ed,step,scale] = defineConstants(i0,a,R,rho1,rho2,rho3,d,h1);
    
    % extract measured data and calculate theoretical ones
    if i <= 7 % 8x8 cases
        dataMeas = dataTotal_8x8(:,i);
        [l3] = computePotentials_8x8_l3(jp,kp,jm,km,alpha,beta,eh1,eh2,step,ed,scale,a,stimChans,offset_3l);
        [l1] = computePotentials_8x8_l1(jp,kp,jm,km,rhoA,i0,stimChans,offset_1l);
        % c91479 was flipped l1 l3
        if strcmp(sid,'c91479')
            l3 = -l3;
            l1 = -l1;
        end
    else % 8x4 case
        dataMeas = dataTotal_8x4(:,i-7);
        [l3] = computePotentials_8x4_l3(jp,kp,jm,km,alpha,beta,eh1,eh2,step,ed,scale,a,stimChans,offset_3l);
        [l1] = computePotentials_8x4_l1(jp,kp,jm,km,rhoA,i0,stimChans,offset_1l);
        
    end
    
    l3 = l3';
    l1 = l1';
    l1_vec(:,i) = l1;
    l3_vec(:,i) = l3;
    %residuals-factor
    resid_l3{i} = l3-dataMeas;
    resid_l1{i} = l1-dataMeas;
    R_factor1(i) = nansum(abs(resid_l1{i}))/nansum(abs(dataMeas(~isnan(l1))));
    R_factor3(i) = nansum(abs(resid_l3{i}))/nansum(abs(dataMeas(~isnan(l1))));
    
    % linear fits
    [yfit3,P3] = linearModelFit(dataMeas,l3);
    [yfit1,P1] = linearModelFit(dataMeas,l1);
    
    yfit3_cell{i} = yfit3;
    yfit1_cell{i} = yfit1;
    P3_cell{i} = P3;
    P1_cell{i} = P1;
    
    
    % plot individual subjects for line plots
    figure(fig_ind(i));
    plot(dataMeas,'color',color1,'linewidth',2);hold on;
    plot(l1,'color',color2,'linewidth',2);hold on;
    plot(l3,'color',color3,'linewidth',2);hold on;
    xlabel('Electrode Number')
    ylabel('Voltage (V)')
    legend('measured','single layer','3 layer');
    %  legend('measured','single layer');
    
    dim = [0.2 0.2 0.5 0.5];
    annotation(fig_ind(i), 'textbox', dim, 'String', {['rhoA = ' num2str(subject_min_rhoA_vec(i))],['offset 1 layer = ' num2str(subject_min_offset1l_vec(i))]...
        ['rho1 = ' num2str(subject_min_rho1_vec(i))],['rho2 = ' num2str(subject_min_rho2_vec(i))],...
        ['rho3 = ' num2str(subject_min_rho3_vec(i))], ['offset 3 layer = ' num2str(subject_min_offset3l_vec(i))],...
        ['h1 = ' num2str(subject_min_h1_vec(i))]},...
        'vert', 'bottom', 'FitBoxToText','on','EdgeColor','none');
    %     annotation(fig_ind(i), 'textbox', dim, 'String', {['rhoA = ' num2str(subject_min_rhoA_vec(i))],['offset 1 layer = ' num2str(subject_min_offset1l_vec(i))]...
    %         },...
    %         'vert', 'bottom', 'FitBoxToText','on','EdgeColor','none');
    drawnow;
    title(sid)
    OUTPUT_DIR = pwd;
    if saveFigBool
        SaveFig(OUTPUT_DIR, sprintf(['fit_ind_opt_subject_farAway_3l_1l%s'], char(sid)), 'png', '-r300');
    end
    
    % global figure of residuals
    figure(figResid);
    subplot_resid(i) = subplot(2,4,i);
    vectorPlot = [1:64];
    vectorPlot(isnan(resid_l1{i})) = nan;
    plot(vectorPlot,resid_l1{i},'o','color',color1,'markerfacecolor',color1); hold on;
    plot(vectorPlot,resid_l3{i},'o','color',color2,'markerfacecolor',color2);
    hline(0)
    title(sid)
    
    
    % global figure of linear fits
    figure(figLinear);
    subplot_linear(i) = subplot(2,4,i);
    plot(dataMeas(~isnan(l1)),l1(~isnan(l1)),'o','color',color1,'markerfacecolor',color1);
    hold on;
    plot(l1(~isnan(l1)),yfit1,'color',color1,'linewidth',2);
    
    plot(dataMeas(~isnan(l3)),l3(~isnan(l3)),'o','color',color2,'markerfacecolor',color2);
    plot(l3(~isnan(l3)),yfit3,'color',color2,'linewidth',2);
    
    title(sid)
    
    % global figure of linear line plots
    figure(figTotal)
    subplot_total(i) = subplot(2,4,i);
    plot(dataMeas,'color',color1,'linewidth',2);
    hold on;
    plot(l1,'color',color2,'linewidth',2);hold on;
    plot(l3,'color',color3,'linewidth',2);hold on;
    title(sid)
end
%
figure(figTotal)

xlabel('Electrode Number')
ylabel('Voltage (V)')
legend('measured','single layer','three layer');
% legend('measured','single layer');

%
arrayfun(@(x) pbaspect(x, [1 1 1]), subplot_total);
drawnow;
pos = arrayfun(@plotboxpos, subplot_total, 'uni', 0);
dim = cellfun(@(x) x.*[1 1 0.5 0.5], pos, 'uni',0);
for i = 1:length(sidVec)
    annotation(figTotal, 'textbox', dim{i}, 'String', {['rhoA = ' num2str(subject_min_rhoA_vec(i))],['offset 1 layer = ' num2str(subject_min_offset1l_vec(i))]...
        ['rho1 = ' num2str(subject_min_rho1_vec(i))],['rho2 = ' num2str(subject_min_rho2_vec(i))],...
        ['rho3 = ' num2str(subject_min_rho3_vec(i))], ['offset 3 layer = ' num2str(subject_min_offset3l_vec(i))],...
        ['h1 = ' num2str(subject_min_h1_vec(i))]},...
        'vert', 'bottom', 'FitBoxToText','on','EdgeColor','none');
    
    %     annotation(figTotal, 'textbox', dim{i}, 'String', {['rhoA = ' num2str(subject_min_rhoA_vec(i))],['offset 1 layer = ' num2str(subject_min_offset1l_vec(i))]...
    %         },...
    %         'vert', 'bottom', 'FitBoxToText','on','EdgeColor','none');
end
OUTPUT_DIR = pwd;
if saveFigBool
    SaveFig(OUTPUT_DIR, ['fit_total_opt_farAway_3l_1l'], 'png', '-r300');
end


figure(figResid);
xlabel('Electrode Number')
ylabel('Residual')
legend('single layer','three layer');
% legend('single layer');

%
arrayfun(@(x) pbaspect(x, [1 1 1]), subplot_resid);
drawnow;
pos = arrayfun(@plotboxpos, subplot_total, 'uni', 0);
dim = cellfun(@(x) x.*[1 1 0.5 0.5], pos, 'uni',0);
for i = 1:length(sidVec)
    annotation(figResid, 'textbox', dim{i}, 'String', {['R factor 1 layer = ' num2str(R_factor1(i))],['R factor 3 layer = ' num2str(R_factor3(i))]},...
        'vert', 'bottom', 'FitBoxToText','on','EdgeColor','none');
    %
    %     annotation(figResid, 'textbox', dim{i}, 'String', {['R factor 1 layer = ' num2str(R_factor1(i))]},...
    %         'vert', 'bottom', 'FitBoxToText','on','EdgeColor','none');
end
OUTPUT_DIR = pwd;
if saveFigBool
    SaveFig(OUTPUT_DIR, ['fit_resid_farAway_3l_l1'], 'png', '-r300');
end

figure(figLinear)
xlabel('Theoretical Prediction')
ylabel('Data')
legend('single layer','single layer fit line','three layer','three layer fit line');
%
arrayfun(@(x) pbaspect(x, [1 1 1]), subplot_total);
drawnow;
pos = arrayfun(@plotboxpos, subplot_linear, 'uni', 0);
dim = cellfun(@(x) x.*[1 1 0.5 0.5], pos, 'uni',0);
for i = 1:length(sidVec)
    annotation(figLinear, 'textbox', dim{i}, 'String', {['slope 1 layer = ' num2str(P1_cell{i}(1))],['intercept 1 layer = ' num2str(P1_cell{i}(2))],...
        ['slope 3 layer = ' num2str(P3_cell{i}(1))],['intercept 3 layer = ' num2str(P3_cell{i}(2))]},...
        'vert', 'bottom', 'FitBoxToText','on','EdgeColor','none');
    
    %     annotation(figLinear, 'textbox', dim{i}, 'String', {['slope 1 layer = ' num2str(P1_cell{i}(1))],['intercept 1 layer = ' num2str(P1_cell{i}(2))],...
    %         },...
    %         'vert', 'bottom', 'FitBoxToText','on','EdgeColor','none');
end
OUTPUT_DIR = pwd;
if saveFigBool
    SaveFig(OUTPUT_DIR, ['fit_linear_farAway_3l_l1'], 'png', '-r300');
end

%% plot contours of interest
%%
figure('units','normalized','outerposition',[0 0 1 1]);
%colormap('grayb')
for i = 1:length(sidVec)
    subplot_resid(i) = subplot(2,4,i);
    sid = sidVec{i};
    
    cost_vec_subj = squeeze(cost_vec_1layer(i,:,:));
    
    
    imagesc(rhoA_vec,offset_vec,log(cost_vec_subj))
    set(gca,'Ydir','normal')
    xlabel('rhoA vec')
    ylabel('offset vector')
    title([sid ' Log plot'])
    colorbar()
end
set(gca,'fontsize',14)
OUTPUT_DIR = pwd;
%
if saveFigBool
    SaveFig(OUTPUT_DIR, ['contour_log_3l_1l'], 'png', '-r300');
end

%%
% 3D slice
%%
%subject of interest - 0b5a2e
subject = 1;
param_slice_interest = 2;
cost_vec_subj = squeeze(cost_vec_3layer(subject,:,:,:,:));

figure
[gridded_x,gridded_y] = meshgrid(rho1_vec,rho2_vec);
surf(gridded_x,gridded_y ,squeeze(cost_vec_subj(:,:, param_slice_interest,1))')
xlabel('rho1')
ylabel('rho2')


param_slice_interest = 4;
figure
[gridded_x,gridded_y] = meshgrid(rho2_vec,rho3_vec);
surf(gridded_x,gridded_y ,squeeze(cost_vec_subj( param_slice_interest,:,:,1))')
xlabel('rho2')
ylabel('rho3')

%subject of interest - d5cd55
subject = 1;
param_slice_interest = 5;
cost_vec_subj = squeeze(cost_vec_3layer(subject,:,:,:));

figure
[gridded_x,gridded_y] = meshgrid(rho1_vec,rho2_vec);
surf(gridded_x,gridded_y ,squeeze(cost_vec_subj(:,:, param_slice_interest,1))')
xlabel('rho1')
ylabel('rho2')


param_slice_interest = 1;
figure
[gridded_x,gridded_y] = meshgrid(rho2_vec,rho3_vec);
surf(gridded_x,gridded_y ,squeeze(cost_vec_subj( param_slice_interest,:,:,1))')
xlabel('rho2')
ylabel('rho3')
%% prepare data for larry

save('3_layer_1_layer_fit_vals.mat','l1_vec','l3_vec','dataTotal_8x8','sidVec')

%% save all the data
close all;
save('fineResolution_optimized.mat','-v7.3')
