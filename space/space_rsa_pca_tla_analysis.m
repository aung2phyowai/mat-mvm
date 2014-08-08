%% load

analysisDate = '01-Aug-2014';

data_str = 'word';
% data_str = 'img';
% data_str = 'img_word';

% word
% thisROI = {'center109'}; % spacing, latency, spacing x latency
% thisROI = {'LPI2','LPS','LT','RPI2','RPS','RT'}; % spacing, latency, spacing x latency
% thisROI = {'LPS','RPS'}; % *spacing, mem x latency
% thisROI = {'LT','RT'}; % nothing
% thisROI = {'LPI2','RPI2'}; % nothing
% thisROI = {'LAS2','FS','RAS2'}; % spacing, latency, spacing x latency
% thisROI = {'LFP','FC','RFP'}; % spacing, latency

% img
% thisROI = {'center109'}; % spacing, latency, spacing x latency
% thisROI = {'LPI2','LPS','LT','RPI2','RPS','RT'}; % spacing, latency, spacing x latency
% thisROI = {'LPS','RPS'}; % spacing, mem, latency, spac x lat
thisROI = {'LT','RT'}; % spac, lat, spac x lat, 3-way
% thisROI = {'LPI2','RPI2'}; % lat
% thisROI = {'LAS2','FS','RAS2'}; % spac, lat, spac x lat
% thisROI = {'LFP','FC','RFP'}; % spac, lat, mem x lat

if iscell(thisROI)
  roi_str = sprintf(repmat('%s',1,length(thisROI)),thisROI{:});
elseif ischar(thisROI)
  roi_str = thisROI;
end

% lpfilt = true;
lpfilt = false;
if lpfilt
  lpfreq = 40;
  %lpfilttype = 'but';
  lpfilt_str = sprintf('lpfilt%d',lpfreq);
else
  lpfilt_str = 'lpfiltNo';
end

latencies = [0.0 0.2; 0.2 0.4; 0.4 0.6; 0.6 0.8; 0.8 1.0; ...
  0.1 0.3; 0.3 0.5; 0.5 0.7; 0.7 0.9; ...
  0 0.3; 0.3 0.6; 0.6 0.9; ...
  0 0.5; 0.5 1.0; ...
  0.3 0.8; ...
  0 0.6; 0.1 0.7; 0.2 0.8; 0.3 0.9; 0.4 1.0; ...
  0 0.8; 0.1 0.9; 0.2 1.0;
  0 1.0];

origDataType = 'tla';

% avgovertime = 'yes';
avgovertime = 'no';

sim_method = 'cosine';
% sim_method = 'correlation';
% sim_method = 'spearman';

% accurateClassifSelect = true;
accurateClassifSelect = false;
if accurateClassifSelect
  classif_str = 'classif';
else
  classif_str = 'noClassif';
end

% eig_criterion = 'CV85';
eig_criterion = 'kaiser';
% eig_criterion = 'analytic';

subDir = '';
dataDir = fullfile('SPACE','EEG','Sessions','ftpp',subDir);
% Possible locations of the data files (dataroot)
serverDir = fullfile(filesep,'Volumes','curranlab','Data');
serverLocalDir = fullfile(filesep,'Volumes','RAID','curranlab','Data');
dreamDir = fullfile(filesep,'data','projects','curranlab');
localDir = fullfile(getenv('HOME'),'data');
% pick the right dataroot
if exist('serverDir','var') && exist(serverDir,'dir')
  dataroot = serverDir;
  %runLocally = 1;
elseif exist('serverLocalDir','var') && exist(serverLocalDir,'dir')
  dataroot = serverLocalDir;
  %runLocally = 1;
elseif exist('dreamDir','var') && exist(dreamDir,'dir')
  dataroot = dreamDir;
  %runLocally = 0;
elseif exist('localDir','var') && exist(localDir,'dir')
  dataroot = localDir;
  %runLocally = 1;
else
  error('Data directory not found.');
end

% procDir = fullfile(dataroot,dataDir,'ft_data/cued_recall_stim_expo_stim_multistudy_image_multistudy_word_art_ftManual_ftICA/tla');
procDir = fullfile(dataroot,dataDir,'ft_data/cued_recall_stim_expo_stim_multistudy_image_multistudy_word_art_nsClassic_ftAuto/tla');

if ~isempty(data_str)
  rsaFile = fullfile(procDir,sprintf('RSA_PCA_%s_%s_%s_%s_%s_%s_%dlat_%sAvgT_%s_%s_cluster.mat',origDataType,data_str,sim_method,classif_str,eig_criterion,roi_str,size(latencies,1),avgovertime,lpfilt_str,analysisDate));
else
  rsaFile = fullfile(procDir,sprintf('RSA_PCA_%s_%s_%s_%s_%s_%dlat_%sAvgT_%s_%s_cluster.mat',origDataType,sim_method,classif_str,eig_criterion,roi_str,size(latencies,1),avgovertime,lpfilt_str,analysisDate));
end
if exist(rsaFile,'file')
  fprintf('loading: %s...',rsaFile);
  load(rsaFile);
  fprintf('Done.\n');
else
  error('does not exist: %s',rsaFile);
end

%% stats

% nTrialThresh = 10; % 30
nTrialThresh = 12; % 27
% nTrialThresh = 14; % 25
% nTrialThresh = 16; % 22
% nTrialThresh = 17; % 21

plotit = false;

noNans = true(length(exper.subjects),length(exper.sesStr));

passTrlThresh = true(length(exper.subjects),length(exper.sesStr));

mean_similarity = struct;
for d = 1:length(dataTypes)
  mean_similarity.(dataTypes{d}) = nan(length(exper.subjects),length(exper.sesStr),size(latencies,1));
  for lat = 1:size(latencies,1)
    
    for sub = 1:length(exper.subjects)
      for ses = 1:length(exper.sesStr)
        
        % Average Pres1--Pres2 similarity
        if ~isempty(diag(similarity_all{sub,ses,d,lat}))
          if similarity_ntrials(sub,ses,d,lat) < nTrialThresh
            passTrlThresh(sub,ses) = false;
          end
          
          mean_similarity.(dataTypes{d})(sub,ses,lat) = mean(diag(similarity_all{sub,ses,d,lat},size(similarity_all{sub,ses,d,lat},1) / 2));
          %mean_similarity.(dataTypes{d}) = cat(1,mean_similarity.(dataTypes{d}),mean(diag(similarity_all{sub,ses,d,lat},size(similarity_all{sub,ses,d,lat},1) / 2)));
          
          if plotit
            figure
            imagesc(similarity_all{sub,ses,d,lat});
            colorbar;
            axis square;
            title(sprintf('%s, %.2f to %.2f',strrep(dataTypes{d},'_','-'),latencies(lat,1),latencies(lat,2)));
          end
        else
          noNans(sub,ses) = false;
        end
      end
    end
    
  end
end

% disp(mean_similarity);

fprintf('Threshold: >= %d trials. Including %d subjects.\n',nTrialThresh,sum(noNans & passTrlThresh));

%% ANOVA: factors: spaced/massed, recalled/forgotten, latency

% latencies = [0.0 0.2; 0.2 0.4; 0.4 0.6; 0.6 0.8; 0.8 1.0; ...
%   0.1 0.3; 0.3 0.5; 0.5 0.7; 0.7 0.9; ...
%   0 0.3; 0.3 0.6; 0.6 0.9; ...
%   0 0.5; 0.5 1.0; ...
%   0.3 0.8; ...
%   0 0.6; 0.1 0.7; 0.2 0.8; 0.3 0.9; 0.4 1.0; ...
%   0 0.8; 0.1 0.9; 0.2 1.0;
%   0 1.0];

% % 0 to 1, in 200 ms chunks
% latInd = [1:5];

% % 0.1 to 0.9, in 200 ms chunks
% latInd = [6:9];

% % 0-0.3, 0.3-0.6, 0.6-0.9
% latInd = [10:12];

% % 0-0.5, 0.5-1 *****
latInd = [13:14];

% % 0 to 1, in 600 ms chunks
% latInd = [16:20];

% % 0 to 1 in 800 ms chunks
% latInd = [21:23];

% % 0 to 1
% latInd = 24;

% =================================================

spacings = {'spac','mass'};
memConds = {'rc', 'fo'};
latency = cell(1,length(latInd));
latencySec = cell(1,length(latInd));
for i = 1:length(latency)
  latency{i} = sprintf('%dto%d',latencies(latInd(1)+i-1,1)*1000,latencies(latInd(1)+i-1,2)*1000);
  latencySec{i} = sprintf('%.1f-%.1f',latencies(latInd(1)+i-1,1),latencies(latInd(1)+i-1,2));
end
latStr = sprintf(repmat('_%s',1,length(latency)),latency{:});
latStr = latStr(2:end);

factorNames = {'spacings', 'memConds', 'latency'};

nVariables = nan(size(factorNames));
keepTheseFactors = false(size(factorNames));
levelNames_teg = cell(size(factorNames)); % TEG
for c = 1:length(factorNames)
  nVariables(c) = length(eval(factorNames{c}));
  levelNames_teg{c} = eval(factorNames{c}); % TEG
  if length(eval(factorNames{c})) > 1
    keepTheseFactors(c) = true;
  end
end

variableNames = cell(1,prod(nVariables));
levelNames = cell(prod(nVariables),length(factorNames));

ses=1;
nSub = sum(noNans & passTrlThresh(:,ses));
anovaData = nan(nSub,prod(nVariables));
rmaov_data_teg = nan(nSub*prod(nVariables),length(factorNames) + 2);

fprintf('Collecting %s %s ANOVA data for %d subjects:\n\t',data_str,origDataType,nSub);
fprintf('%s (%s),',sprintf(repmat(' %s',1,length(spacings)),spacings{:}),factorNames{1});
fprintf('%s (%s),',sprintf(repmat(' %s',1,length(memConds)),memConds{:}),factorNames{2});
fprintf('%s (%s),',latStr,factorNames{3});
fprintf('\n\tROI: %s, Eig: %s, Sim: %s...',roi_str,eig_criterion,sim_method);

lnDone = false;
vnDone = false;
subCount = 0;
rmCount = 0;
for sub = 1:length(exper.subjects)
  if all(noNans(sub,:)) && all(passTrlThresh(sub,:))
    subCount = subCount + 1;
    for ses = 1:length(exper.sesStr)
      lnCount = 0;
      vnCount = 0;
      
      for sp = 1:length(spacings)
        for mc = 1:length(memConds)
          cond_str = sprintf('%s_RgH_%s_%s',data_str,memConds{mc},spacings{sp});
          
          for lat = 1:length(latInd)
            if ~lnDone
              lnCount = lnCount + 1;
              levelNames{lnCount,1} = spacings{sp};
              levelNames{lnCount,2} = memConds{mc};
              levelNames{lnCount,3} = latency{lat};
            end
            
            vnCount = vnCount + 1;
            if ~vnDone
              variableNames{vnCount} = sprintf('y%d',vnCount);
            end
            
            anovaData(subCount,vnCount) = mean_similarity.(cond_str)(sub,ses,latInd(lat));
            
            rmCount = rmCount + 1;
            rmaov_data_teg(rmCount,:) = [mean_similarity.(cond_str)(sub,ses,latInd(lat)) sp mc lat sub];
          end
          
        end
      end
      
      lnDone = true;
      vnDone = true;
    end
  end
end

if any(~keepTheseFactors)
  factorNames = factorNames(keepTheseFactors);
  levelNames = levelNames(:,keepTheseFactors);
  nVariables = nVariables(keepTheseFactors);
  levelNames_teg = levelNames_teg(keepTheseFactors); % TEG
  
  rmaov_data_teg = rmaov_data_teg(:,[1 (find(keepTheseFactors) + 1) size(rmaov_data_teg,2)]); % TEG
  fprintf('\n\tOnly keeping factors:%s...',sprintf(repmat(' %s',1,length(factorNames)),factorNames{:}));
end
fprintf('Done.\n');

% TEG RM ANOVA

fprintf('=======================================\n');
fprintf('This ANOVA: %s %s, ROI: %s, Latency:%s, %s, %s\n\n',data_str,origDataType,roi_str,latStr,eig_criterion,sim_method);

O = teg_repeated_measures_ANOVA(anovaData, nVariables, factorNames,[],[],[],[],[],[],levelNames_teg,rmaov_data_teg);

fprintf('Prev ANOVA: %s %s, ROI: %s, Latency:%s, %s, %s\n',data_str,origDataType,roi_str,latStr,eig_criterion,sim_method);
fprintf('=======================================\n');

%% Matlab RM ANOVA

t = array2table(anovaData,'VariableNames',variableNames);

within = cell2table(levelNames,'VariableNames',factorNames);

% rm = fitrm(t,'Y1-Y8~1','WithinDesign',within);
rm = fitrm(t,sprintf('%s-%s~1',variableNames{1},variableNames{end}),'WithinDesign',within);

fprintf('=======================================\n');
fprintf('This ANOVA: ROI: %s, Latency:%s\n\n',roi_str,latStr);

margmean(rm,factorNames)
% % grpstats(rm,factorNames)

MODELSPEC = sprintf(repmat('*%s',1,length(factorNames)),factorNames{:});
MODELSPEC = MODELSPEC(2:end);

% Perform repeated measures analysis of variance.
if any(nVariables) > 2
  [ranovatbl,A,C,D] = ranova(rm, 'WithinModel',MODELSPEC)
  %Show epsilon values
  %I assume that HF epsilon values > 1 (in R) are truncated to 1 by epsilon.m
  [ranovatbl,A,C,D] = ranova(rm, 'WithinModel',MODELSPEC);
  for cn = 1:length(C)
    tbl = epsilon(rm, C(cn))
  end
else
  [ranovatbl] = ranova(rm, 'WithinModel',MODELSPEC)
end

fprintf('Prev ANOVA: ROI: %s, Latency:%s\n',roi_str,latStr);
fprintf('=======================================\n');

% multcompare(rm,'spacings','By','memConds')
% multcompare(rm,'memConds','By','spacings')
% multcompare(rm,'spacings','By','oldnew')
% multcompare(rm,'oldnew','By','spacings')
% multcompare(rm,'memConds','By','oldnew')
% multcompare(rm,'oldnew','By','memConds')

pairwiseComps = nchoosek(1:length(factorNames),2);
for i = 1:size(pairwiseComps,1)
  multcompare(rm,factorNames{pairwiseComps(i,1)},'By',factorNames{pairwiseComps(i,2)})
  multcompare(rm,factorNames{pairwiseComps(i,2)},'By',factorNames{pairwiseComps(i,1)})
end

% % these calculate the same thing
% manova(rm)
% manova(rm, 'WithinModel','separatemeans')
% 
% % set up a specific contrast
% manova(rm, 'WithinModel',[1 -1 0 0 0 0 0 0]')
% 
% % this tests the 3-way interaction
% manova(rm, 'WithinModel',[-1 1 1 -1 1 -1 -1 1]')
% 
% % MODELSPEC
% % manova(rm, 'WithinModel',sprintf('%s-%s~1',variableNames{1},variableNames{end}))
% % tests intercept
% manova(rm, 'WithinModel','1')
% 
% % manova(rm,'By','memConds') % doesn't work, between only
% 
% 
% % coeftest?
% % coeftest(rm,eye(8),[1 0 0 0 0 0 0 -1]')
% coeftest(rm,[1 1 1 1 -1 -1 -1 -1]',[1 0 0 0 0 0 0 -1]')

%% Suppose we want to compare latencies for each combination of levels of spacing and memory

% 1. Convert factors to categorical.
within2 = within;
within2.latency = categorical(within2.latency);
within2.spacings = categorical(within2.spacings);
within2.memConds = categorical(within2.memConds);

% 2. Create an interaction factor capturing each combination of levels
% of TestCond and TMS.
% within2.TestCond_TMS = within2.TestCond .* within2.TMS;
within2.spacings_memConds = within2.spacings .* within2.memConds;
within2.latency_memConds = within2.latency .* within2.memConds;
within2.spacings_latency = within2.spacings .* within2.latency;
% within2.spacings_memConds_latency = within2.spacings .* within2.memConds .* within2.latency;

% 3. Call fitrm with the modified within design.
rm2 = fitrm(t,'y1-y8~1','WithinDesign',within2);
ranovatbl2 = ranova(rm2, 'WithinModel','spacings*memConds*latency')

% 4. Use interaction factor TestCond_TMS as the 'By' variable in multcompare.
multcompare(rm2,'latency','By','spacings_memConds')
multcompare(rm2,'spacings_memConds','By','latency')


multcompare(rm2,'memConds','By','spacings_latency')
multcompare(rm2,'memConds','By','spacings_latency')
multcompare(rm2,'spacings','By','latency_memConds')

% not correct
multcompare(rm2,'spacings_memConds')
multcompare(rm2,'latency_memConds')
multcompare(rm2,'spacings_latency')

% do not correct for multiple comparisons
multcompare(rm2,'spacings_memConds_latency','ComparisonType','lsd')

%% plot RSA spacing x subsequent memory interaction

theseSub = noNans & passTrlThresh;

ses=1;

RgH_rc_spac = squeeze(mean_similarity.(sprintf('%s_RgH_rc_spac',data_str))(theseSub,ses,latInd));
RgH_fo_spac = squeeze(mean_similarity.(sprintf('%s_RgH_fo_spac',data_str))(theseSub,ses,latInd));
RgH_rc_mass = squeeze(mean_similarity.(sprintf('%s_RgH_rc_mass',data_str))(theseSub,ses,latInd));
RgH_fo_mass = squeeze(mean_similarity.(sprintf('%s_RgH_fo_mass',data_str))(theseSub,ses,latInd));

% mean across time
RgH_rc_spac_sub = mean(RgH_rc_spac,2);
RgH_fo_spac_sub = mean(RgH_fo_spac,2);
RgH_rc_mass_sub = mean(RgH_rc_mass,2);
RgH_fo_mass_sub = mean(RgH_fo_mass,2);

plotMeanLine = false;
plotSub = true;

if plotMeanLine
  s_mark = 'ko-';
  m_mark = 'rx-.';
else
  s_mark = 'ko';
  m_mark = 'rx';
end

if plotSub
  subSpacing = 0.1;
  s_mark_sub = 'ko';
  m_mark_sub = 'rx';
end

meanSizeR = 20;
meanSizeF = 20;

figure
hold on

if plotSub
  % forgotten
  plot((1-subSpacing)*ones(sum(theseSub(:,ses)),1), RgH_fo_spac_sub,s_mark_sub,'LineWidth',1);
  plot((1+subSpacing)*ones(sum(theseSub(:,ses)),1), RgH_fo_mass_sub,m_mark_sub,'LineWidth',1);
  
  % recalled
  plot((2-subSpacing)*ones(sum(theseSub(:,ses)),1), RgH_rc_spac_sub,s_mark_sub,'LineWidth',1);
  plot((2+subSpacing)*ones(sum(theseSub(:,ses)),1), RgH_rc_mass_sub,m_mark_sub,'LineWidth',1);
end

if plotMeanLine
  hs = plot([mean(RgH_fo_spac_sub,1) mean(RgH_rc_spac_sub,1)],s_mark,'LineWidth',3,'MarkerSize',meanSizeF);
  hm = plot([mean(RgH_fo_mass_sub,1) mean(RgH_rc_mass_sub,1)],m_mark,'LineWidth',3,'MarkerSize',meanSizeF);
  
%   % recalled
%   plot(2, ,s_mark,'LineWidth',3,'MarkerSize',meanSizeR);
%   plot(2, ,m_mark,'LineWidth',3,'MarkerSize',meanSizeR);
else
  % forgotten
  plot(1, mean(RgH_fo_spac_sub,1),s_mark,'LineWidth',3,'MarkerSize',meanSizeF);
  plot(1, mean(RgH_fo_mass_sub,1),m_mark,'LineWidth',3,'MarkerSize',meanSizeF);
  
  % recalled
  hs = plot(2, mean(RgH_rc_spac_sub,1),s_mark,'LineWidth',3,'MarkerSize',meanSizeR);
  hm = plot(2, mean(RgH_rc_mass_sub,1),m_mark,'LineWidth',3,'MarkerSize',meanSizeR);
end

% horiz
plot([-3 3], [0 0],'k--','LineWidth',2);

hold off
axis square
% axis([0.75 2.25 75 110]);
xlim([0.75 2.25]);
ylim([-0.61 0.61]);

set(gca,'XTick', [1 2]);
set(gca,'XTickLabel',{'Forgot','Recalled'});

ylabel('Neural Similarity');

title(sprintf('Spacing \\times Subsequent Memory: %s',data_str));
legend([hs, hm],{'Spaced','Massed'},'Location','North');

% ticFontSize = 20;
ticFontSize = 18;
publishfig(gcf,0,ticFontSize,[],[]);

% print(gcf,'-depsc2',sprintf('~/Desktop/similarity_spacXmem_%s_%s_%s_%s_%s_%s.eps',data_str,origDataType,roi_str,latStr,eig_criterion,sim_method));

%% plot RSA spacing x time interaction

theseSub = noNans & passTrlThresh;

ses=1;

RgH_rc_spac = squeeze(mean_similarity.(sprintf('%s_RgH_rc_spac',data_str))(theseSub,ses,latInd));
RgH_fo_spac = squeeze(mean_similarity.(sprintf('%s_RgH_fo_spac',data_str))(theseSub,ses,latInd));
RgH_rc_mass = squeeze(mean_similarity.(sprintf('%s_RgH_rc_mass',data_str))(theseSub,ses,latInd));
RgH_fo_mass = squeeze(mean_similarity.(sprintf('%s_RgH_fo_mass',data_str))(theseSub,ses,latInd));

% mean across rc/fo
RgH_spac = mean(cat(3,RgH_rc_spac,RgH_fo_spac),3);
RgH_mass = mean(cat(3,RgH_rc_mass,RgH_fo_mass),3);

plotMeanLines = true;
plotSub = true;
plotSubLines = false;

if plotMeanLines
  s_mark = 'ko-';
  m_mark = 'rx-.';
else
  s_mark = 'ko';
  m_mark = 'rx';
end

meanSize = 20;

if plotSub
  subSpacing = 0.1;
  if plotSubLines
    s_mark_sub = 'ko-';
    m_mark_sub = 'rx-.';
  else
    s_mark_sub = 'ko';
    m_mark_sub = 'rx';
  end
end

figure
hold on

if plotSub
  if plotSubLines
    for s = 1:sum(theseSub)
      plot(RgH_spac(s,:),s_mark_sub,'LineWidth',1);
      plot(RgH_mass(s,:),m_mark_sub,'LineWidth',1);
    end
  else
    for t = 1:length(latInd)
      if plotSub
        plot((t-subSpacing)*ones(sum(theseSub(:,ses)),1), RgH_spac(:,t),s_mark_sub,'LineWidth',1);
        plot((t+subSpacing)*ones(sum(theseSub(:,ses)),1), RgH_mass(:,t),m_mark_sub,'LineWidth',1);
      end
    end
  end
end
if plotMeanLines
  hs = plot(mean(RgH_spac,1),s_mark,'LineWidth',3,'MarkerSize',meanSize);
  hm = plot(mean(RgH_mass,1),m_mark,'LineWidth',3,'MarkerSize',meanSize);
else
  for t = 1:length(latInd)
    hs = plot(t, mean(RgH_spac(:,t),1),s_mark,'LineWidth',3,'MarkerSize',meanSize);
    hm = plot(t, mean(RgH_mass(:,t),1),m_mark,'LineWidth',3,'MarkerSize',meanSize);
  end
end

% horiz
plot([-length(latInd)-1, length(latInd)+1], [0 0],'k--','LineWidth',2);

hold off
axis square
xlim([0.75 length(latInd)+0.25]);
ylim([-0.65 0.65]);

set(gca,'XTick', 1:length(latInd));
set(gca,'XTickLabel',latencySec);
xlabel('Time (Sec)');

ylabel('Neural Similarity');

title(sprintf('Spacing \\times Time: %s',data_str));
legend([hs, hm],{'Spaced','Massed'},'Location','North');

% ticFontSize = 20;
ticFontSize = 18;
publishfig(gcf,0,ticFontSize,[],[]);

% print(gcf,'-depsc2',sprintf('~/Desktop/similarity_spacXtime_%s_%s_%s_%s_%s_%s.eps',data_str,origDataType,roi_str,latStr,eig_criterion,sim_method));

%% plot RSA spacing x memory x time interaction

theseSub = noNans & passTrlThresh;

ses=1;

RgH_rc_spac = squeeze(mean_similarity.(sprintf('%s_RgH_rc_spac',data_str))(theseSub,ses,latInd));
RgH_fo_spac = squeeze(mean_similarity.(sprintf('%s_RgH_fo_spac',data_str))(theseSub,ses,latInd));
RgH_rc_mass = squeeze(mean_similarity.(sprintf('%s_RgH_rc_mass',data_str))(theseSub,ses,latInd));
RgH_fo_mass = squeeze(mean_similarity.(sprintf('%s_RgH_fo_mass',data_str))(theseSub,ses,latInd));

plotMeanLines = true;
plotSub = false;
plotSubLines = false;

if plotMeanLines
  s_rc_mark = 'ko-';
  s_fo_mark = 'ko-.';
  m_rc_mark = 'rx-';
  m_fo_mark = 'rx-.';
else
  s_rc_mark = 'ko';
  s_fo_mark = 'ro';
  m_rc_mark = 'kx';
  m_fo_mark = 'rx';
end

meanSizeS = 20;
meanSizeM = 20;

if plotSub
  subSpacing = 0.2;
  if plotSubLines
    s_rc_mark_sub = 'ko-';
    s_fo_mark_sub = 'ko-.';
    m_rc_mark_sub = 'rx-';
    m_fo_mark_sub = 'rx-.';
  else
    s_rc_mark_sub = 'ko';
    s_fo_mark_sub = 'ro';
    m_rc_mark_sub = 'kx';
    m_fo_mark_sub = 'rx';
  end
end

figure
hold on

if plotSub
  if plotSubLines
    plotSub = false;
    for s = 1:sum(theseSub)
      % spaced
      plot(RgH_rc_spac(s,:),s_rc_mark_sub,'LineWidth',1);
      plot(RgH_fo_spac(s,:),s_fo_mark_sub,'LineWidth',1);
      % massed
      plot(RgH_rc_mass(s,:),m_rc_mark_sub,'LineWidth',1);
      plot(RgH_fo_mass(s,:),m_fo_mark_sub,'LineWidth',1);
    end
  else
    for t = 1:length(latInd)
      % spaced
      plot((t-subSpacing)*ones(sum(theseSub(:,ses)),1), RgH_rc_spac(:,t),s_rc_mark_sub,'LineWidth',1);
      plot((t+subSpacing)*ones(sum(theseSub(:,ses)),1), RgH_fo_spac(:,t),s_fo_mark_sub,'LineWidth',1);
      % massed
      plot((t-subSpacing)*ones(sum(theseSub(:,ses)),1), RgH_rc_mass(:,t),m_rc_mark_sub,'LineWidth',1);
      plot((t+subSpacing)*ones(sum(theseSub(:,ses)),1), RgH_fo_mass(:,t),m_fo_mark_sub,'LineWidth',1);
    end
  end
end
if plotMeanLines
  % spaced
  hsr = plot(mean(RgH_rc_spac,1),s_rc_mark,'LineWidth',3,'MarkerSize',meanSizeS);
  hsf = plot(mean(RgH_fo_spac,1),s_fo_mark,'LineWidth',3,'MarkerSize',meanSizeS);
  % massed
  hmr = plot(mean(RgH_rc_mass,1),m_rc_mark,'LineWidth',3,'MarkerSize',meanSizeM);
  hmf = plot(mean(RgH_fo_mass,1),m_fo_mark,'LineWidth',3,'MarkerSize',meanSizeM);
else
  for t = 1:length(latInd)
    % spaced
    hsr = plot(t,mean(RgH_rc_spac(:,t),1),s_rc_mark,'LineWidth',3,'MarkerSize',meanSizeS);
    hsf = plot(t,mean(RgH_fo_spac(:,t),1),s_fo_mark,'LineWidth',3,'MarkerSize',meanSizeS);
    % massed
    hmr = plot(t,mean(RgH_rc_mass(:,t),1),m_rc_mark,'LineWidth',3,'MarkerSize',meanSizeM);
    hmf = plot(t,mean(RgH_fo_mass(:,t),1),m_fo_mark,'LineWidth',3,'MarkerSize',meanSizeM);
  end
end

% horiz
plot([-length(latInd)-1, length(latInd)+1], [0 0],'k--','LineWidth',2);

hold off
axis square
xlim([0.75 length(latInd)+0.25]);
ylim([-0.35 0.35]);

set(gca,'XTick', 1:length(latInd));
set(gca,'XTickLabel',latencySec);
xlabel('Time (Sec)');

ylabel('Neural Similarity');

title(sprintf('Spacing \\times Memory \\times Time: %s',data_str));
legend([hsr, hsf, hmr, hmf],{'Spaced Rc','Spaced Fo','Massed Rc','Massed Fo'},'Location','North');

% ticFontSize = 20;
ticFontSize = 18;
publishfig(gcf,0,ticFontSize,[],[]);

% print(gcf,'-depsc2',sprintf('~/Desktop/similarity_spacXmemXtime_%s_%s_%s_%s_%s_%s.eps',data_str,origDataType,roi_str,latStr,eig_criterion,sim_method));
