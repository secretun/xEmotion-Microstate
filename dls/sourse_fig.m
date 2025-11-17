clear; clc;
tic;
% 加载必要的数据
source_1_yuan = load('E:\Sourse\SEED\results_sLORETA_EEG_KERNEL_250121_1343.mat');
souct_1 = load('E:\Sourse\SEED\scout_HCP_MMP1_360.mat');
souct_1 = souct_1.Scouts;
% 文件路径
labeldir = 'E:\Sourse\SEED\';
%EEGdir = 'C:\Users\walam\Desktop\毕业设计-基于脑电微状态源空间表征的情感识别研究\数据处理实验\seed4_fen_single\zztest';
EEGdir = 'E:\SEED\microstate\分频段数据\4_20140621\1\2';
EEGFiles = dir(fullfile(EEGdir, '*.set'));
% 初始化 cohort 对象
coh = microstate.cohort;
% 遍历 .set 文件
for i = 1:length(EEGFiles)
    try
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
        error(['处理文件 ', EEGFiles(i).name, ' 时出错: ', ME.message]);
    end
end
  % 保存当前运行环境
% 后续处理
disp("聚类之前");
coh = coh.cluster_global(5, 'cohortstat', 'data');
disp("聚类之后");
template = 'hcp230' ; 
labels = readcell([labeldir '/ROIlabels.txt'],'Delimiter','\n');
%label是一个标签文件数据集合
layout = microstate.functions.layout_creator(template,labels) ;
disp(layout);
coh.plot('globalmaps', layout, 'cscale', [0.2 1]);
%%
globalmaps = coh.globalmaps ; clear coh

















% Initialize an empty microstate cohort object
coh = microstate.cohort ;
% Loop over scans
rng('default') % for reprodu cibility
for i = 1:length(EEGFiles)
    try
        % Make an empty microstate individual
        EEG = pop_loadset('filename', EEGFiles(i).name, 'filepath', EEGdir);
        test_data.F = EEG.data;
        test_data.Time = EEG.srate;
        ms = microstate.individual;
        ms = ms.import_brainstorm(test_data, source_1_yuan, souct_1);
        
        % Add the global maps to the microstate individual
        ms.maps = globalmaps;
        
        % Backfit the globalmaps to the data
        ms = ms.cluster_alignmaps;
        
        % Calculate GEV
        ms = ms.stats_all;
        ms = ms.stats_gev;

        % Add the individual to the cohort
        coh = coh.add_individuals(ms, 'subject', 0);
        
        % 输出当前文件处理成功的信息
        disp(['成功处理文件: ', EEGFiles(i).name]);
        
    catch ME
        % 捕获错误并输出错误信息
        error_message = ['处理文件 ', EEGFiles(i).name, ' 时出错: ', ME.message];
        disp(error_message);
        
        % 可选：将错误信息保存到日志文件
        fid = fopen('error_log2.txt', 'a');
        fprintf(fid, '文件: %s, 错误: %s\n', EEGFiles(i).name, ME.message);
        fclose(fid);
        
        % 跳过当前循环，继续处理下一个文件
        continue;
    end
end
for j = 1:length(EEGFiles)
    try
        gevall(j,:) = coh.individual(j, 1).stats.gev ;
        %gevsing(j,:) = coh.individual(j, 1).stats.gev_sing ;
        durationcut{j,:} = coh.individual(j, 1).stats.duration ;
        coveragecut{j,:} = coh.individual(j, 1).stats.coverage ;
        occurrencecut{j,:} = coh.individual(j, 1).stats.occurrence ;
        matrixcut{j,:} = coh.individual(j, 1).stats.syntax.matrix ;
    catch ME
        % 捕获错误并输出错误信息
        error_message = ['处理文件 ', num2str(j), ' 时出错: ', ME.message];
        disp(error_message);
        
        % 可选：将错误信息保存到日志文件
        fid = fopen('error_log.txt', 'a');
        fprintf(fid, '文件索引: %d, 错误: %s\n', j, ME.message);
        fclose(fid);
        
      
        % 跳过当前循环，继续处理下一个文件
        continue;
    end
    end
toc
disp(['程序运行时间', num2str(toc)]);
%ms.plot('gfp')
% 如果 coveragecut 是一个 cell 数组，可以先将其转换为数值矩阵
% 将 cell 数组转换为数值矩阵
%ms.plot('gfp')
% 如果 coveragecut 是一个 cell 数组，可以先将其转换为数值矩阵
coveragecut = cell2mat(coveragecut);

% 然后使用循环将值赋给 cov
cov = zeros(24, 5);
for i = 1:24
    for j = 1:5
        cov(i, j) = coveragecut(i, j);
    end
end
% 显示 cov 矩阵

% 显示 cov 矩阵
% 将cell数组转换为数值矩阵
temp = cell2mat(durationcut);

% 将数值矩阵转换为表格
dur = array2table(temp);
dur=table2cell(dur);
% 将cell数组转换为数值矩阵
temp = cell2mat(occurrencecut);

% 将数值矩阵转换为表格
occur = array2table(temp);
occur=table2cell(occur);

% 假设 a 是 24x1 的 cell 数组，这里简单模拟一下数据
matrixcut = cell(24, 1);
for i = 1:24
    matrixcut{i} = num2cell(rand(5, 5)); % 生成 5x5 的随机数矩阵并转换为 cell 数组
end

% 初始化一个 24x25 的 cell 数组
result = cell(24, 25);

% 遍历 a 中的每个元素
for i = 1:size(matrixcut, 1)
    % 将 5x5 的 cell 数组按行拼接成 1x25 的 cell 数组
    result(i, :) = reshape(matrixcut{i}', 1, []);
end

% 将结果存储到 Excel 文件
matrix = array2table(result);
matrix=table2cell(matrix);
% 初始化一个空的 cell 数组
filenametable=[]
filenametable = cell(24, 1);

for j = 1:24
    % 将每个文件名存储到 cell 数组中
    filenametable{j} = EEGFiles(j).name;
end

% 假设这是你的7个变量
% 第一个变量a，24x1的cell，值为1
participants= repmat({1}, 24, 1);

% 第七个变量g，24x1的cell，值为2
g = repmat({2}, 24, 1);

% 定义列名
columnNames = {'participant', 'filename', 'coverage', 'duration', 'occurance', 'transition_probability', 'labels'};

% 创建一个空的表格
T = table;

% 将变量添加到表格中
T.(columnNames{1}) = participants;
T.(columnNames{2}) = filenametable;
T.(columnNames{3}) = cov;
T.(columnNames{4}) = dur;
T.(columnNames{5}) = occur;
T.(columnNames{6}) = matrix;
T.(columnNames{7}) = g;

% 将表格写入Excel文件
% 使用 uiputfile 让用户选择保存路径和文件名
[filename, pathname] = uiputfile('*.xlsx', '选择保存位置');

% 检查用户是否取消了保存操作
if isequal(filename, 0) || isequal(pathname, 0)
    disp('用户取消了保存操作。');
else
    % 构建完整的文件路径
    fullFilePath = fullfile(pathname, filename);
    % 将表格写入指定路径的 Excel 文件
    writetable(T, fullFilePath);
    disp(['文件已成功保存到: ', fullFilePath]);
end