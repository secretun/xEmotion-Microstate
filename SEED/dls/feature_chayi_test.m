clc;clear;
filePath = 'E:\SEED\SEED_EEG\测试\2_20140413.xlsx';
%cols = {'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF', 'AG', 'AH', 'AI', 'AJ', 'AK', 'AL', 'AM', 'AN', 'AO'};
cols = {'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF', 'AG', 'AH', 'AI', 'AJ', 'AK', 'AL', 'AM', 'AN', 'AO','AO', 'AP', 'AQ', 'AR', 'AS', 'AT', 'AU', 'AV', 'AW', 'AX', 'AY', 'AZ', 'BA', 'BB', 'BC', 'BD', 'BE', 'BF', 'BG', 'BH', 'BI', 'BJ', 'BK', 'BL', 'BM', 'BN', 'BO', 'BP', 'BQ', 'BR', 'BS', 'BT', 'BU', 'BV', 'BW', 'BX', 'BY', 'BZ', 'CA', 'CB', 'CC', 'CD', 'CE', 'CF', 'CG', 'CH', 'CI', 'CJ', 'CK', 'CL', 'CM', 'CN', 'CO', 'CP', 'CQ', 'CR', 'CS', 'CT', 'CU', 'CV', 'CW', 'CX', 'CY', 'CZ', 'DA', 'DB', 'DC', 'DD', 'DE', 'DF', 'DG', 'DH', 'DI', 'DJ', 'DK', 'DL', 'DM', 'DN', 'DO', 'DP', 'DQ', 'DR', 'DS', 'DT', 'DU', 'DV', 'DW', 'DX', 'DY', 'DZ', 'EA', 'EB', 'EC', 'ED', 'EE', 'EF', 'EG', 'EH', 'EI', 'EJ', 'EK', 'EL', 'EM', 'EN', 'EO', 'EP', 'EQ', 'ER', 'ES', 'ET', 'EU', 'EV', 'EW', 'EX', 'EY', 'EZ', 'FA', 'FB', 'FC', 'FD', 'FE', 'FF', 'FG', 'FH', 'FI', 'FJ', 'FK', 'FL', 'FM', 'FN', 'FO', 'FP', 'FQ', 'FR', 'FS', 'FT', 'FU', 'FV', 'FW', 'FX', 'FY', 'FZ', 'GA', 'GB', 'GC', 'GD', 'GE', 'GF', 'GG', 'GH', 'GI', 'GJ', 'GK', 'GL', 'GM', 'GN', 'GO', 'GP', 'GQ', 'GR', 'GS'};
significantCols = {};  % 创建一个空的cell数组来存储p值小于0.05的列
for i = 1:length(cols)
    group1 = readmatrix(filePath, 'Sheet', 'Sheet6', 'Range', [cols{i} '1:' cols{i} '52']);
    group2 = readmatrix(filePath, 'Sheet', 'Sheet6', 'Range', [cols{i} '56:' cols{i} '107']);
    group3 = readmatrix(filePath, 'Sheet', 'Sheet6', 'Range', [cols{i} '109:' cols{i} '160']);
    [p, ~, ~] = anova1([group1, group2, group3], [], 'off');
    if p < 0.05
        disp(['p value for column ' cols{i} ' is: ' num2str(p)]);
        significantCols = [significantCols, cols{i}];  % 添加到significantCols数组
    end
end
disp(significantCols);

% 设置要读取的工作表
sheetName = 'Sheet6';
 columnsToExtract =significantCols;
extractedData = [];
% 循环读取数据
for colIndex = 1:numel(columnsToExtract)
    col = columnsToExtract{colIndex};
    % 读取数据
    range = [col '1:' col '160'];
   % [~, ~, raw] = xlsread(filePath, sheetName, range);
    raw = readcell(filePath, 'Sheet', sheetName, 'Range', range);
    % 转换为数值矩阵
    data = cell2mat(raw);
    % 将提取的列数据添加到矩阵中
    extractedData = [extractedData, data];
end
writematrix(extractedData, filePath, 'Sheet', 'Sheet7', 'Range', 'B1');











filePath = 'E:\SEED\SEED_EEG\分频段表格\1.xlsx';
cols = {'AU', 'AV', 'AW', 'AX', 'AY', 'AZ', 'BA', 'BB', 'BC', 'BD', 'BE', 'BF', 'BG', 'BH', 'BI', 'BJ', 'BK', 'BL', 'BM', 'BN'};
significantCols = {};  % 创建一个空的cell数组来存储p值小于0.05的列
for i = 1:length(cols)
    group1 = readmatrix(filePath, 'Sheet', 'Sheet7', 'Range', [cols{i} '1:' cols{i} '15']);
    group2 = readmatrix(filePath, 'Sheet', 'Sheet7', 'Range', [cols{i} '16:' cols{i} '30']);
    group3 = readmatrix(filePath, 'Sheet', 'Sheet7', 'Range', [cols{i} '31:' cols{i} '45']);
    [p, ~, ~] = anova1([group1, group2, group3], [], 'off');
    if p < 0.05
        disp(['p value for column ' cols{i} ' is: ' num2str(p)]);
        significantCols = [significantCols, cols{i}];  % 添加到significantCols数组
    end
end
disp(significantCols);
% 设置要读取的工作表
sheetName = 'Sheet6';
 columnsToExtract =significantCols;
extractedData = [];
% 循环读取数据
for colIndex = 1:numel(columnsToExtract)
    col = columnsToExtract{colIndex};
    % 读取数据
    range = [col '1:' col '45'];
   % [~, ~, raw] = xlsread(filePath, sheetName, range);
    raw = readcell(filePath, 'Sheet', sheetName, 'Range', range);
    % 转换为数值矩阵
    data = cell2mat(raw);
    % 将提取的列数据添加到矩阵中
    extractedData = [extractedData, data];
end
writematrix(extractedData, filePath, 'Sheet', 'Sheet7', 'Range', 'B1');