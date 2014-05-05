% load and re-save RSA PCA tla results

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

thisROI = {'center109'};
latencies = [0.0 0.2; 0.2 0.4; 0.4 0.6; 0.6 0.8; 0.8 1.0; ...
  0.1 0.3; 0.3 0.5; 0.5 0.7; 0.7 0.9; ...
  0 0.3; 0.3 0.6; 0.6 0.9; ...
  0 0.5; 0.5 1.0; ...
  0.3 0.8; ...
  0 0.6; 0.1 0.7; 0.2 0.8; 0.3 0.9; 0.4 1.0; ...
  0 0.8; 0.1 0.9; 0.2 1.0];

% thisROI = {'LPI2','LPS','LT','RPI2','RPS','RT'};
% latencies = [0.0 0.2; 0.2 0.4; 0.4 0.6; 0.6 0.8; 0.8 1.0; ...
%   0.1 0.3; 0.3 0.5; 0.5 0.7; 0.7 0.9; ...
%   0 0.3; 0.3 0.6; 0.6 0.9; ...
%   0 0.5; 0.5 1.0; ...
%   0.3 0.8; ...
%   0 0.6; 0.1 0.7; 0.2 0.8; 0.3 0.9; 0.4 1.0; ...
%   0 0.8; 0.1 0.9; 0.2 1.0;
%   0 1.0];

avgoverfreq = 'yes';
avgovertime = 'no';

dataTypes = {'img_RgH_rc_spac', 'img_RgH_rc_mass','img_RgH_fo_spac', 'img_RgH_fo_mass'};

if iscell(thisROI)
  roi_str = sprintf(repmat('%s',1,length(thisROI)),thisROI{:});
elseif ischar(thisROI)
  roi_str = thisROI;
end

eig_criterion = 'CV85';

similarity_all = cell(length(subjects),length(sesNames),length(dataTypes),size(latencies,1));
similarity_ntrials = nan(length(subjects),length(sesNames),length(dataTypes),size(latencies,1));

expName = 'SPACE';
saveDirProc = fullfile(filesep,'data','projects','curranlab',expName,'EEG/Sessions/ftpp/ft_data/cued_recall_stim_expo_stim_multistudy_image_multistudy_word_art_ftManual_ftICA/pow');

thisDate = '04-May-2014';

for sub = 1:length(subjects)
  for ses = 1:length(sesNames)
    savedFile = fullfile(saveDirProc,subjects{sub},sesNames{ses},sprintf('RSA_PCA_pow_classif_%s_%s_%dlat_%sAvgT_%sAvgF_%s.mat',eig_criterion,roi_str,size(latencies,1),avgovertime,avgoverfreq,thisDate));
    subData = load(savedFile);
    
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

saveFile = fullfile(saveDirProc,sprintf('RSA_PCA_pow_classif_%s_%s_%dlat_%sAvgT_%sAvgF_cluster.mat',eig_criterion,roi_str,size(latencies,1),cfg_sel.avgovertime,cfg_sel.avgoverfreq));
save(saveFile,'exper','dataTypes','thisROI','cfg_sel','eig_criterion','latencies','similarity_all','similarity_ntrials');

