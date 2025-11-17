tic
clear;  clc;
% start EEGLAB to load all dependent paths
eeglab
%% set the path to the directory with the EEG files
% change this path to the folder where the EEG files are saved
EEGdir = 'E:\DEAP\sub2_40\';
m=40;
% retrieve a list of all EEG Files in EEGdir
EEGFiles = dir(fullfile(EEGdir, '*.set'));
%% 3.3 Data selection and aggregation
%% 3.3.1 Loading datasets in EEGLAB
for i=1:length(EEGFiles)
EEG = pop_loadset('filename',EEGFiles(i).name,'filepath',EEGdir);

[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
eeglab redraw % updates EEGLAB datasets
end
%% 3.3.2 Select data for microstate analysis  计算GFP
[EEG, ALLEEG] = pop_micro_selectdata( EEG, ALLEEG, 'datatype', 'spontaneous',...
'avgref', 1, ...
'normalise', 1, ...
'MinPeakDist', 10, ...
'Npeaks', 1000, ...
'GFPthresh', 1, ...
'dataset_idx', 1:m );
% store data in a new EEG structure
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw % updates EEGLAB datasets
%% 3.4 Microstate segmentation  对GFP进行聚类
% select the "GFPpeak" dataset and make it the active set
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, m,'retrieve',m+1,'study',0);
eeglab redraw
% Perform the microstate segmentation 执行微状态分割 
EEG = pop_micro_segment( EEG, 'algorithm', 'modkmeans', ...
'sorting', 'Global explained variance', ...
'Nmicrostates', 5:5, ...
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
EEG = pop_micro_selectNmicro( EEG, 'Nmicro', 5 );
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
occurence = cell(m,1);
duration = cell(m,1);
coverage = cell(m,1);
MGfp = cell(m,1);
data = cell(m,1);
TP_all = cell(m,1);
fit = cell(m,1);
prototypes = EEG.microstate.prototypes;
for i = 1:length(EEGFiles)
    fprintf('Importing prototypes and backfitting for dataset %i\n',i)
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',i,'study',0);
%% Import microstate prototypes from other dataset to the datasets that should be back-fitted
% 将其他数据集的微状态原型导入到需要进行回配的数据集  
% note that dataset number 5 is the GFPpeaks dataset with the microstate
% prototypes
    EEG = pop_micro_import_proto( EEG, ALLEEG,m+1);
%% 3.6 Back-fit microstates on EEG
    EEG = pop_micro_fit( EEG, 'polarity', 0 );
 
%% 3.7 Temporally smooth microstates labels
    EEG = pop_micro_smooth( EEG, 'label_type', 'backfit', ...
    'smooth_type', 'reject segments', ...
    'minTime', 30, ...
    'polarity', 0 );
%% 3.9 Calculate microstate statistics
    EEG = pop_micro_stats( EEG, 'label_type', 'backfit', ...
    'polarity', 0 );
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    occurence{i,1} = EEG.microstate.stats.Occurence;
    duration{i,1} = EEG.microstate.stats.Duration;
    coverage{i,1} = EEG.microstate.stats.Coverage;
    fitlabels = EEG.microstate.fit.labels;
    MGfp{i,1} =EEG.microstate.stats.Gfp;
    TP = EEG.microstate.stats.TP;
    GEVall(i,:) = EEG.microstate.stats.GEV;
    TP_all{i,1} = TP; % 按列排序
%     data{i,1} = [occurence, duration, coverage];
    fit{i,1} = fitlabels;
end
toc
 disp(['程序运行时间', num2str(toc)]) ;
%% 3.8 Illustrating microstate segmentation
%Plotting GFP of active microstates for the first 1500 ms for subject 1.
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',1,'study',0);
figure;MicroPlotSegments( EEG, 'label_type', 'backfit', ...
'plotsegnos', 'first', 'plot_time', [1 5000], 'plottopos', 1 );
eeglab redraw
 %合并数据
 features_data = feature_fusion(coverage, duration, occurence,TP_all);
 %xlswrite('E:\SEED\SEED_EEG\测试\4.xlsx', features_data,1, 'B1');
