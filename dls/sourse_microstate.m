clear; clc;
tic;

% 加载必要的数据
source_1_yuan = load('E:\Sourse\SEED\results_sLORETA_EEG_KERNEL_250121_1343.mat');
souct_1 = load('E:\Sourse\SEED\scout_HCP_MMP1_360.mat');
souct_1 = souct_1.Scouts;
labeldir = 'E:\Sourse\SEED\';

% 根目录路径
rootDir = 'E:\SEED\microstate\分频段数据\3_20140629\3\';

% 获取所有子文件夹（0, 1, 2, 3）
%subFolders = {'0', '1', '2'};
subFolders = {'1'};
% 初始化 cohort 对象
coh = microstate.cohort;

% 结果存储变量
all_participants = {};
all_filenames = {};
all_cov = [];
all_dur = [];
all_occur = [];
all_matrix = {};
all_labels = {};

% 遍历所有子文件夹
for f = 1:length(subFolders)
    folder = subFolders{f};
    label = str2double(folder); % 标签对应文件夹名称
    EEGdir = fullfile(rootDir, folder);
    EEGFiles = dir(fullfile(EEGdir, '*.set'));

    for i = 1:length(EEGFiles)
        try
            % 加载 EEG 数据
            EEG = pop_loadset('filename', EEGFiles(i).name, 'filepath', EEGdir);
            test_data.F = EEG.data;
            test_data.Time = EEG.srate;

            % 创建 microstate.individual 对象
            ms = microstate.individual;
            ms = ms.import_brainstorm(test_data, source_1_yuan, souct_1);

            % 添加到 cohort
            coh = coh.add_individuals(ms, 'scan1', 200);
        catch ME
            % 捕获错误并记录
            disp(['处理文件 ', EEGFiles(i).name, ' 时出错: ', ME.message]);
        end
    end


% 聚类
disp("聚类之前");
coh = coh.cluster_global(5, 'cohortstat', 'data');
disp("聚类之后");


template = 'hcp230' ; 
labels = readcell([labeldir '/ROIlabels.txt'],'Delimiter','\n');
%label是一个标签文件数据集合
layout = microstate.functions.layout_creator(template,labels) ;
disp(layout);
coh.plot('globalmaps', layout, 'cscale', [-0.1 1]);

% 计算 GEV 和其他统计数据
globalmaps = coh.globalmaps; clear coh;

% 重新初始化 cohort
coh = microstate.cohort;

    for i = 1:length(EEGFiles)
        try
            % 读取 EEG 数据
            EEG = pop_loadset('filename', EEGFiles(i).name, 'filepath', EEGdir);
            test_data.F = EEG.data;
            test_data.Time = EEG.srate;

            % 创建 microstate.individual 对象
            ms = microstate.individual;
            ms = ms.import_brainstorm(test_data, source_1_yuan, souct_1);
            ms.maps = globalmaps;

            % 计算 GEV
            ms = ms.cluster_alignmaps;
            ms = ms.stats_all;
            ms = ms.stats_gev;

            % 添加到 cohort
            coh = coh.add_individuals(ms, 'subject', 0);

            % 存储结果
            all_participants{end+1, 1} = i;
            all_filenames{end+1, 1} = EEGFiles(i).name;
            all_cov = [all_cov; ms.stats.coverage];
            all_dur = [all_dur; ms.stats.duration];
            all_occur = [all_occur; ms.stats.occurrence];
            all_matrix{end+1, 1} = ms.stats.syntax.matrix;
            all_labels{end+1, 1} = label;

            disp(['成功处理文件: ', EEGFiles(i).name]);

        catch ME
            disp(['处理文件 ', EEGFiles(i).name, ' 时出错: ', ME.message]);
            continue;
        end
    end
end

% 处理矩阵
matrix_results = zeros(size(all_matrix, 1), numel(all_matrix{1})); % 预分配

for i = 1:size(all_matrix, 1)
    matrix_results(i, :) = reshape(all_matrix{i}', 1, []);
end


% 定义列名
columnNames = {'participant', 'filename', 'coverage', 'duration', 'occurrence', 'transition_probability', 'labels'};

% 创建表格
T = table;
T.(columnNames{1}) = all_participants;
T.(columnNames{2}) = all_filenames;
T.(columnNames{3}) = all_cov;
T.(columnNames{4}) = all_dur;
T.(columnNames{5}) = all_occur;
T.(columnNames{6}) = matrix_results;
T.(columnNames{7}) = all_labels;

% 保存 Excel 文件
[filename, pathname] = uiputfile('*.xlsx', '选择保存位置');
if isequal(filename, 0) || isequal(pathname, 0)
    disp('用户取消了保存操作。');
else
    fullFilePath = fullfile(pathname, filename);
    writetable(T, fullFilePath);
    disp(['文件已成功保存到: ', fullFilePath]);
end

toc;
disp(['程序运行时间: ', num2str(toc)]);