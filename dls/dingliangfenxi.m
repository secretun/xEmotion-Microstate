%% 从TF重构矩阵并计算指标 + 热图可视化
clear; clc; close all;

fprintf('脑电功能连接定量分析 - 从TF数据重构矩阵\n');

%% === 读取数据 ===
data1 = load('E:\Sourse\定量分析\1.mat'); TF1 = data1.one.TF;
data2 = load('E:\Sourse\定量分析\2.mat'); TF2 = data2.two.TF;
data3 = load('E:\Sourse\定量分析\3.mat'); TF3 = data3.three.TF;

%% === 自动确定节点数 ===
n_connections = length(TF1);
n_nodes = round((1 + sqrt(1 + 8*n_connections)) / 2);
fprintf('检测到节点数: %d\n', n_nodes);

%% === 重构为对称矩阵 ===
matrix_emo1 = squareform(TF1); matrix_emo1(1:n_nodes+1:end) = 1;
matrix_emo2 = squareform(TF2); matrix_emo2(1:n_nodes+1:end) = 1;
matrix_emo3 = squareform(TF3); matrix_emo3(1:n_nodes+1:end) = 1;

%% === 计算指标 ===
% 平均连接强度
avg_strength = [mean(abs(matrix_emo1(triu(true(n_nodes), 1)))), ...
                mean(abs(matrix_emo2(triu(true(n_nodes), 1)))), ...
                mean(abs(matrix_emo3(triu(true(n_nodes), 1))))];

% 简化全局效率
global_eff = zeros(1,3);
matrices = {matrix_emo1, matrix_emo2, matrix_emo3};
for i = 1:3
    mat = abs(matrices{i});
    mat(1:n_nodes+1:end) = 0;
    efficiency_matrix = 1./(mat + eps);
    efficiency_matrix(efficiency_matrix > 1000) = 0;
    global_eff(i) = mean(efficiency_matrix(efficiency_matrix > 0));
end

%% === 输出结果 ===
fprintf('\n结果:\n');
fprintf('情绪\t平均连接强度\t全局效率\n');
labels = {'正情绪', '中性情绪', '负情绪'};
for i = 1:3
    fprintf('%s\t%.4f\t\t%.4f\n', labels{i}, avg_strength(i), global_eff(i));
end

%% === 可视化指标 ===
figure('Name','脑功能连接定量分析结果','Position',[100 100 900 400]);
subplot(1,2,1);
bar(avg_strength);
title('平均连接强度');
set(gca, 'XTickLabel', labels, 'FontSize', 12);

subplot(1,2,2);
bar(global_eff);
title('全局效率');
set(gca, 'XTickLabel', labels, 'FontSize', 12);
%sgtitle('脑功能连接定量分析指标结果', 'FontSize', 14);

%% === 功能连接热图可视化 ===
figure('Name','功能连接热图','Position',[100 100 1200 400]);

subplot(1,3,1);
imagesc(matrix_emo1);
title('正情绪 - 功能连接矩阵');
xlabel('节点'); ylabel('节点');
colorbar;
axis square; colormap(jet);

subplot(1,3,2);
imagesc(matrix_emo2);
title('中性情绪 - 功能连接矩阵');
xlabel('节点'); ylabel('节点');
colorbar;
axis square; colormap(jet);

subplot(1,3,3);
imagesc(matrix_emo3);
title('负情绪 - 功能连接矩阵');
xlabel('节点'); ylabel('节点');
colorbar;
axis square; colormap(jet);

sgtitle('三种情绪的脑功能连接热图', 'FontSize', 14);
