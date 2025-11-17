clear ;  clc ;
tic
bst_scout=load('G:\+microstate\bst_scout.mat')
bst_source=load('G:\+microstate\bst_source.mat')
labeldir = 'E:\+microstate\toolbox-master\tutorials\tutorial2_RestingSource_Group\MEG-rest' ;
EEGdir = 'I:\OVPD-II\VS_pre_popeline_5band\YXK\theta' ;
EEGFiles = dir(fullfile(EEGdir, '*.set'));
coh = microstate.cohort ;
for i = 1:length(EEGFiles)
EEG = pop_loadset('filename',EEGFiles(i).name,'filepath',EEGdir) ;
test_data.F = EEG.data;
test_data.Time = EEG.srate;
ms = microstate.individual;
ms = ms.import_brainstorm(test_data,OVPD_source,bst_scout);
coh = coh.add_individuals(ms,'scan1',860);
end
coh = coh.cluster_global(1,'cohortstat','data') ;
template = 'hcp230' ; % Use the HCP230 atlas template
labels = readcell([labeldir '/ROIlabels.txt'],'Delimiter','\n');
layout = microstate.functions.layout_creator(template,labels) ;
coh.plot('globalmaps',layout,'cscale',[0.5 1]) ;
%%
globalmaps = coh.globalmaps ; clear coh
% Initialize an empty microstate cohort object
coh = microstate.cohort ;
% Loop over scans
rng('default') % for reproducibility
for i = 1:length(EEGFiles)
% Make an empty microstate individual
EEG = pop_loadset('filename',EEGFiles(i).name,'filepath',EEGdir) ;
test_data.F = EEG.data;
test_data.Time = EEG.srate;
ms = microstate.individual;
ms = ms.import_brainstorm(test_data,OVPD_source,bst_scout);
% Add the global maps to the microstate individual
ms.maps = globalmaps ;
% Backfit the globalmaps to the data
ms = ms.cluster_alignmaps ;
%     Calculate GEV
ms = ms.stats_all ;
%     ms = ms.stats_gev ;
coh = coh.add_individuals(ms,'subject',0) ;
end
for j = 1:length(EEGFiles)
gevall(j,:) = coh.individual(j, 1).stats.gev ;
gevsing(j,:) = coh.individual(j, 1).stats.gev_sing ;
durationcut{j,:} = coh.individual(j, 1).stats.durationcut ;
coveragecut{j,:} = coh.individual(j, 1).stats.coveragetotal ;
occurrencecut{j,:} = coh.individual(j, 1).stats.occurrencetotal ;
matrixcut{j,:} = coh.individual(j, 1).stats.syntax.matrixcut ;
end
toc
disp(['程序运行时间', num2str(toc)]) ;
% ms.plot('gfp')