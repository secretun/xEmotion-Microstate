% 设置存储set文件的文件夹路径
set_folder = 'D:\xiaodi\date_nochannols\xiayulu_20140527\';

% 获取文件夹中的所有set文件
set_files = dir(fullfile(set_folder, '*.set'));

% 循环导入每个set文件
for i = 1:length(set_files)
    % 构建set文件的完整路径
    set_path = fullfile(set_folder, set_files(i).name);
    
    % 使用pop_loadset函数导入set文件
    EEG = pop_loadset('filename', set_files(i).name, 'filepath', set_folder);
    disp(['采样率: ' num2str(EEG.srate) ' Hz']);
    % 显示已导入数据的信息
    disp(['Loaded EEG data from ' set_files(i).name]);
end