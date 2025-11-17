clc;clear;
baseDir = 'E:\DEAP\sub\sub20\分时间段_频段\';
subDirs = {'1','2','3','4','5'};
prefixes = {'s20_trial2_', 's20_trial3_', 's20_trial4_', 's20_trial5_', 's20_trial6_', 's20_trial8_', 's20_trial9_', 's20_trial11_', 's20_trial12_', 's20_trial13_', 's20_trial14_', 's20_trial15_', 's20_trial18_', 's20_trial19_', 's20_trial20_', 's20_trial32_'}
for s = 1:length(subDirs)
    [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
    EEGdir = fullfile(baseDir, subDirs{s});
    for p = 1:length(prefixes)
        files = dir(fullfile(EEGdir, strcat(prefixes{p}, '*.set')));
        for i = 1:length(files)
            EEG = pop_loadset('filename', files(i).name, 'filepath', EEGdir);
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
            CURRENTSET = length(ALLEEG);
        end
    end
    eeglab redraw;
    m=CURRENTSET;
    [EEG, ALLEEG] = pop_micro_selectdata( EEG, ALLEEG, 'datatype', 'spontaneous',...
    'avgref', 1, ...
    'normalise', 1, ...
    'MinPeakDist', 10, ...
    'Npeaks', 1000, ...
    'GFPthresh', 1, ...
    'dataset_idx', 1:m);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw 
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG,m,'retrieve',m+1,'study',0);
    eeglab redraw
    EEG = pop_micro_segment( EEG, 'algorithm', 'modkmeans', ...
    'sorting', 'Global explained variance', ...
    'Nmicrostates', 5:5, ...
    'verbose', 1, ...
    'normalise', 0, ...
    'Nrepetitions', 35, ...
    'max_iterations', 1000, ...
    'threshold', 1e-06, ...
    'fitmeas', 'CV',...
    'optimised',1);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    figure;MicroPlotTopo( EEG, 'plot_range', [] );
    EEG = pop_micro_selectNmicro( EEG, 'Nmicro', 5 );
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    occurence = cell(m,1);duration = cell(m,1);coverage = cell(m,1);MGfp = cell(m,1);data = cell(m,1);TP_all = cell(m,1);fit = cell(m,1);
    prototypes = EEG.microstate.prototypes;
    for i = 1:length(ALLEEG)-1
        fprintf('Importing prototypes and backfitting for dataset %i\n',i)
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',i,'study',0);
        EEG = pop_micro_import_proto( EEG, ALLEEG,m+1);
        EEG = pop_micro_fit( EEG, 'polarity', 0 );
        EEG = pop_micro_smooth( EEG, 'label_type', 'backfit', ...
        'smooth_type', 'reject segments', ...
        'minTime', 30, ...
        'polarity', 0 );
        EEG = pop_micro_stats( EEG, 'label_type', 'backfit', ...
        'polarity', 0 );
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);occurence{i,1} = EEG.microstate.stats.Occurence;
        duration{i,1} = EEG.microstate.stats.Duration;coverage{i,1} = EEG.microstate.stats.Coverage;
        fitlabels = EEG.microstate.fit.labels;MGfp{i,1} =EEG.microstate.stats.Gfp;
        TP = EEG.microstate.stats.TP;GEVall(i,:) = EEG.microstate.stats.GEV;TP_all{i,1} = TP; % 按列排序
    end
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',1,'study',0);
    figure;MicroPlotSegments( EEG, 'label_type', 'backfit', ...
    'plotsegnos', 'first', 'plot_time', [1 5000], 'plottopos', 1 );eeglab redraw
    for i = 1:1:length(TP_all)
        tp = TP_all{i,1};
        a = reshape(tp,1,[]);
        TP2{i,1} = a;
    end
    TP1 = cell2mat(TP2);occurence1=cell2mat(occurence);duration1=cell2mat(duration);coverage1 = cell2mat(coverage);
    features_data = [coverage1,duration1, occurence1,TP1];
    xlswrite('E:\DEAP\sub\sub20\fea.xlsx', features_data, strcat('Sheet', num2str(s)), 'B1');
end