function [coverage, duration, occurence, TP_all] = auto_analysis_VOPDms(EEGdir, EEGFiles)
%% set the path to the directory with the EEG files
% retrieve a list of all EEG Files in EEGdir
clear
clc
tic
eeglab
EEGdir = 'I:\OVPD-II\VS_pre_popeline_5band\CL\alpha';
EEGFiles= dir(fullfile(EEGdir, '*.set')); 
%% 3.3 Data selection and aggregation
%% 3.3.1 Loading datasets in EEGLAB
for i=1:length(EEGFiles)
EEG = pop_loadset('filename',EEGFiles(i).name,'filepath',EEGdir);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
eeglab redraw % updates EEGLAB datasets
end
%% 3.3.2 Select data for microstate analysis  
[EEG, ALLEEG] = pop_micro_selectdata( EEG, ALLEEG, 'datatype', 'spontaneous',...
'avgref', 1, ...
'normalise', 1, ...
'MinPeakDist', 10, ...
'Npeaks', 1500, ...
'GFPthresh', 1, ...
'dataset_idx', 1:3 );
% store data in a new EEG structure
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw % updates EEGLAB datasets
%% 3.4 Microstate segmentation  
% select the "GFPpeak" dataset and make it the active set
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'retrieve',4,'study',0);
eeglab redraw
% Perform the microstate segmentation  
EEG = pop_micro_segment( EEG, 'algorithm', 'modkmeans', ...
'sorting', 'Global explained variance', ...
'Nmicrostates', 2:3, ...
'verbose', 1, ...
'normalise', 0, ...
'Nrepetitions', 50, ...
'max_iterations', 1000, ...
'threshold', 1e-06, ...
'fitmeas', 'CV',...
'optimised',1);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
%% 3.5 Review and select microstate segmentation
%% 3.5.1 Plot microstate prototype topographies
figure;MicroPlotTopo( EEG, 'plot_range', [] );
%% 3.5.2 Select active number of microstates
EEG = pop_micro_selectNmicro(EEG);
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
%% Import microstate prototypes from other dataset to the datasets that should be back-fitted
occurence = cell(3,1);
duration = cell(3,1);
coverage = cell(3,1);
TP_all = cell(3,1);
for i = 1:length(EEGFiles)
    fprintf('Importing prototypes and backfitting for dataset %i\n',i)
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',i,'study',0);
    EEG = pop_micro_import_proto( EEG, ALLEEG, 4);
%% 3.6 Back-fit microstates on EEG
    EEG = pop_micro_fit( EEG, 'polarity', 0 );
%% 3.7 Temporally smooth microstates labels
    EEG = pop_micro_smooth( EEG, 'label_type', 'backfit', ...
    'smooth_type', 'reject segments', ...
    'minTime', 30, ...
    'polarity', 0 );
%% 3.9 Calculate microstate statistics
    EEG = pop_micro_stats_VOPDIINs( EEG, 'label_type', 'backfit', ...
    'polarity', 0 );
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    occurence{i,1} = EEG.microstate.stats.Occurence;
    duration{i,1} = EEG.microstate.stats.Duration;
    coverage{i,1} = EEG.microstate.stats.Coverage;
    GEVall(i,:) = EEG.microstate.stats.GEV;
    prototypes = EEG.microstate.prototypes;  
    TP = EEG.microstate.stats.TP;
    TP_all{i,1} = TP; 
end
toc