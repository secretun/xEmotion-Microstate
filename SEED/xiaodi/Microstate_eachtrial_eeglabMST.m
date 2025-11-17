clear all; clc;
eeglab

%导入数据
EEGdir ='D:\xiaodi\date_yeschannols\xiayulu_20140527\';
EEGFiles = dir([EEGdir, '*.set']);
for i=1:length(EEGFiles)
EEG = pop_loadset('filename',EEGFiles(i).name,'filepath',EEGdir);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = pop_reref(EEG, []);  % 设置平均参考
eeglab redraw % updates EEGLAB datasets
end
%% 3.3 Data selection and aggregation
%% 3.3.1 Loading datasets in EEGLAB
n = length(EEGFiles);


%% 3.3.2 Select data for microstate analysis
[EEG, ALLEEG] = pop_micro_selectdata(EEG, ALLEEG, 'datatype', 'spontaneous',...
'avgref', 1, ...
'normalise', 0, ...
'MinPeakDist', 10, ...
'Npeaks', 1000, ...
'GFPthresh', 1, ...
'dataset_idx', 1:n );
% store data in a new EEG structure
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw % updates EEGLAB datasets

%% 3.4 Microstate segmentation
m = n + 1;%n为原始数据集的个数，m为需要选择的数据集的个数，直接导入时，总数据集设为n，m=n+1
% select the "GFPpeak" dataset and make it the active set
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, n,'retrieve',m,'study',0);
eeglab redraw
% Perform the microstate ,egmentation
EEG = pop_micro_segment( EEG, 'algorithm', 'modkmeans', ...
'sorting', 'Global explained variance', ...
'Nmicrostates', 4:5, ...
'verbose', 1, ...
'normalise', 0, ...
'Nrepetitions', 50, ...
'max_iterations', 1000, ...
'threshold', 1e-06, ...
'fitmeas', 'CV',...
'optimised',1);
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%% 3.5 Review and select microstate segmentation
%% 3.5.1 Plot microstate prototype topographies
figure;MicroPlotTopo( EEG, 'plot_range', [] );

%% 3.5.2 Select active number of microstates
EEG = pop_micro_selectNmicro( EEG, 'Nmicro', 5 );%聚为4类
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%% Import microstate prototypes from other dataset to the datasets that should be back-fitted
% note that dataset number 50 is the GFPpeaks dataset with the microstate prototypes
for i = 1:length(EEGFiles)
fprintf('Importing prototypes and backfitting for dataset %i\n',i)
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',i,'study',0);
EEG = pop_micro_import_proto( EEG, ALLEEG, m); %这个数字=MicroGFPpeaksData在datasets中的编号，eeglab redraw可以看到
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
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

occurence{i,1} = EEG.microstate.stats.Occurence;
duration{i,1} = EEG.microstate.stats.Duration;
coverage{i,1} = EEG.microstate.stats.Coverage;
GEVall(i,:) = EEG.microstate.stats.GEV;
prototypes = EEG.microstate.prototypes;  
TP = EEG.microstate.stats.TP;
TP_all{i,1} = TP; 
end
%% 3.8 Illustrating microstate segmentation
% Plotting GFP of active microstates for the first 1500 ms for subject 1.
% [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',1,'study',0);
% figure;MicroPlotSegments( EEG, 'label_type', 'backfit', ...
% 'plotsegnos', 'first', 'plot_time', [1 8000], 'plottopos', 1);
% eeglab redraw


%%保存统计数据PLUGINLIST
features_data = feature_fusion(coverage, duration, occurence, TP_all);
