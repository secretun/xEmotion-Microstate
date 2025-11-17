srcDir = 'E:\SEED\Sourse\sourse_mat';
destDir = 'E:\SEED\Sourse\soutse_set';
mainDir = '1_20131027';
subDirs = {'1', '2', '3', '4', '5'};
for j = 1:length(subDirs)
    files = dir(fullfile(srcDir, mainDir, subDirs{j}, '*.mat'));
    for i = 1:length(files)
        matData = load(fullfile(srcDir, mainDir, subDirs{j}, files(i).name));
        EEG = eeg_emptyset;
        EEG.data = matData.Value;
        EEG.srate = 200; 
        EEG = eeg_checkset(EEG);
        EEG = pop_reref(EEG, []); 
        [~, name, ~] = fileparts(files(i).name);
        outName = fullfile(destDir, mainDir, subDirs{j}, [name '.set']);
        if ~exist(fullfile(destDir, mainDir, subDirs{j}), 'dir')
            mkdir(fullfile(destDir, mainDir, subDirs{j}));
        end
        pop_saveset(EEG, 'filename', outName);
    end
end




















% 定义源文件和目标文件路径
srcFile = 'E:\Sourse\hcp230\data\Subject01\2_20140404Data1\matrix_scout_240313_1156.mat';
destDir = 'E:\Sourse\hcp230\data\Subject01\2_20140404Data1';
destFile = 'matrix_scout_240307_1156.set';

% 确保目标目录存在
if ~exist(destDir, 'dir')
    mkdir(destDir);
end

% 加载.mat文件
matData = load(srcFile);

% 初始化EEGLAB EEG结构
EEG = eeg_emptyset;
EEG.data = matData.Value; % 假设加载的.mat文件中的数据变量名为Value
EEG.srate = 200; % 设置采样率
EEG = eeg_checkset(EEG);
EEG = pop_reref(EEG, []);

% 保存为.set格式
pop_saveset(EEG, 'filename', fullfile(destDir, destFile));
