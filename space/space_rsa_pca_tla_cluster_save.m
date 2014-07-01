% load and re-save RSA PCA tla results

% also saves files using the hilbert method

expName = 'SPACE';
saveDirProc = fullfile(filesep,'data','projects','curranlab',expName,'EEG/Sessions/ftpp/ft_data/cued_recall_stim_expo_stim_multistudy_image_multistudy_word_art_ftManual_ftICA/tla');

subjects = {
  %'SPACE001'; % low trial counts
  'SPACE002';
  'SPACE003';
  'SPACE004';
  'SPACE005';
  'SPACE006';
  'SPACE007';
  %'SPACE008'; % didn't perform task correctly, didn't perform well
  'SPACE009';
  'SPACE010';
  'SPACE011';
  'SPACE012';
  'SPACE013';
  'SPACE014';
  'SPACE015';
  'SPACE016';
  %'SPACE017'; % old assessment: really noisy EEG, half of ICA components rejected
  'SPACE018';
  %'SPACE019';
  'SPACE020';
  'SPACE021';
  'SPACE022';
  'SPACE027';
  'SPACE029';
  'SPACE037';
  %'SPACE039'; % noisy EEG; original EEG analyses stopped here
  'SPACE023';
  'SPACE024';
  'SPACE025';
  'SPACE026';
  'SPACE028';
  %'SPACE030'; % low trial counts
  'SPACE032';
  'SPACE034';
  'SPACE047';
  'SPACE049';
  'SPACE036';
  };

% only one cell, with all session names
sesNames = {'session_1'};

analysisDate = '13-Jun-2014';

% thisROI = {'center109'};
thisROI = {'LPI2','LPS','LT','RPI2','RPS','RT'};
if iscell(thisROI)
  roi_str = sprintf(repmat('%s',1,length(thisROI)),thisROI{:});
elseif ischar(thisROI)
  roi_str = thisROI;
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
% origDataType = 'hilbert';

if strcmp(origDataType,'hilbert')
  freqs = [4 8; 8 12; 12 30; 30 50];
end

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

dataTypes = {'img_RgH_rc_spac', 'img_RgH_rc_mass','img_RgH_fo_spac', 'img_RgH_fo_mass'};

eig_criterion = 'CV85';
% eig_criterion = 'kaiser';
% eig_criterion = 'analytic';

similarity_all = cell(length(subjects),length(sesNames),length(dataTypes),size(latencies,1));
similarity_ntrials = nan(length(subjects),length(sesNames),length(dataTypes),size(latencies,1));

for sub = 1:length(subjects)
  for ses = 1:length(sesNames)
    if strcmp(origDataType,'tla')
      savedFile = fullfile(dirs.saveDirProc,sprintf('RSA_PCA_%s_%s_%s_%s_%s_%dlat_%sAvgT_%s.mat',origDataType,sim_method,classif_str,eig_criterion,roi_str,size(latencies,1),avgovertime,analysisDate));
    elseif strcmp(origDataType,'hilbert')
      savedFile = fullfile(dirs.saveDirProc,sprintf('RSA_PCA_%s_%s_%s_%s_%s_%dlat_%dfreq_%sAvgT_%s.mat',origDataType,sim_method,classif_str,eig_criterion,roi_str,size(latencies,1),size(freqs,1),avgovertime,analysisDate));
    end
    if exist(savedFile,'file')
      fprintf('Loading %s...\n',savedFile);
      subData = load(savedFile);
      fprintf('Done.\n');
    else
      error('Does not exist: %s',savedFile);
    end
    
    exper = subData.exper;
    cfg_sel = subData.cfg_sel;
    
    for d = 1:length(dataTypes)
      for lat = 1:size(latencies,1)
        similarity_all{sub,ses,d,lat} = subData.similarity_all{1,1,d,lat};
        similarity_ntrials(sub,ses,d,lat) = subData.similarity_ntrials(1,1,d,lat);
      end
    end
    
  end
end

exper.subjects = subjects;
exper.sesNames = sesNames;

if strcmp(origDataType,'tla')
  saveFile = fullfile(saveDirProc,sprintf('RSA_PCA_tla_classif_%s_%s_%dlat_%sAvgT_%s_cluster.mat',eig_criterion,roi_str,size(latencies,1),cfg_sel.avgovertime,analysisDate));
elseif strcmp(origDataType,'hilbert')
  saveFile = fullfile(saveDirProc,sprintf('RSA_PCA_tla_classif_%s_%s_%dlat_%dfreq_%sAvgT_%s_cluster.mat',eig_criterion,roi_str,size(latencies,1),size(freqs,1),cfg_sel.avgovertime,analysisDate));
end
  
fprintf('Saving %s...\n',saveFile);
if strcmp(origDataType,'tla')
  save(saveFile,'exper','dataTypes','thisROI','cfg_sel','eig_criterion','latencies','similarity_all','similarity_ntrials');
elseif strcmp(origDataType,'hilbert')
  save(saveFile,'exper','dataTypes','thisROI','cfg_sel','eig_criterion','latencies','freqs','similarity_all','similarity_ntrials');
end
fprintf('Done.\n');

