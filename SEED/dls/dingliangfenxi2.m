%% 策略二：特定脑网络分析 - 读取真实TF数据版（最终修正版）
clear; clc; close all;

fprintf('策略二：特定脑网络功能连接分析\n');

%% === 1. 定义情绪相关脑网络 ===
fprintf('1. 定义情绪相关脑网络...\n');

% 情绪网络脑区索引（基于69个脑区的典型编号，可根据实际调整）
prefrontal_regions = [1, 2, 3, 4, 5, 6, 17, 18]; % 前额叶区域
limbic_regions = [31, 32, 33, 34, 35, 36, 37, 38]; % 边缘系统
temporal_regions = [15, 16, 19, 20, 41, 42, 43, 44]; % 颞叶区域
insular_regions = [13, 14]; % 岛叶

% 定义四个情绪相关网络
networks = {
    struct('name', '全情绪网络', 'regions', unique([prefrontal_regions, limbic_regions, temporal_regions, insular_regions])), ...
    struct('name', '前额叶网络', 'regions', prefrontal_regions), ...
    struct('name', '边缘系统', 'regions', limbic_regions), ...
    struct('name', '颞叶网络', 'regions', temporal_regions) ...
};
fprintf('   定义了 %d 个情绪相关网络\n', length(networks));

%% === 2. 读取真实TF数据 ===
fprintf('2. 读取功能连接数据...\n');

data1 = load('E:\Sourse\定量分析\1.mat'); TF1 = data1.one.TF;
data2 = load('E:\Sourse\定量分析\2.mat'); TF2 = data2.two.TF;
data3 = load('E:\Sourse\定量分析\3.mat'); TF3 = data3.three.TF;

% 自动确定节点数
n_connections = length(TF1);
n_nodes = round((1 + sqrt(1 + 8*n_connections)) / 2);
fprintf('   检测到节点数: %d\n', n_nodes);

% 重构矩阵
matrix_emo1 = squareform(TF1); matrix_emo1(1:n_nodes+1:end) = 1;
matrix_emo2 = squareform(TF2); matrix_emo2(1:n_nodes+1:end) = 1;
matrix_emo3 = squareform(TF3); matrix_emo3(1:n_nodes+1:end) = 1;

matrices = {matrix_emo1, matrix_emo2, matrix_emo3};
emotion_labels = {'正情绪', '中性情绪', '负情绪'};

%% === 3. 分析各网络 ===
fprintf('3. 分析各网络连接强度...\n');
results = struct();

for net_idx = 1:length(networks)
    net = networks{net_idx};
    fprintf('\n分析网络: %s (包含 %d 个脑区)\n', net.name, length(net.regions));
    
    network_strengths = zeros(1, 3);
    network_efficiencies = zeros(1, 3);
    
    for emotion_idx = 1:3
        submatrix = matrices{emotion_idx}(net.regions, net.regions);
        
        n_net_nodes = length(net.regions);
        if n_net_nodes > 1
            upper_triangular = triu(true(n_net_nodes), 1);
            connection_values = abs(submatrix(upper_triangular));
            strength = mean(connection_values);
            
            weighted_matrix = abs(submatrix);
            weighted_matrix(1:n_net_nodes+1:end) = 0;
            efficiency_matrix = 1./(weighted_matrix + eps);
            efficiency_matrix(efficiency_matrix > 1000) = 0;
            valid_efficiencies = efficiency_matrix(efficiency_matrix > 0 & efficiency_matrix < 1000);
            efficiency = mean(valid_efficiencies);
        else
            strength = 0;
            efficiency = 0;
        end
        
        network_strengths(emotion_idx) = strength;
        network_efficiencies(emotion_idx) = efficiency;
        
        fprintf('   %s: 强度=%.4f, 效率=%.4f\n', ...
            emotion_labels{emotion_idx}, strength, efficiency);
    end
    
    results(net_idx).name = net.name;
    results(net_idx).strengths = network_strengths;
    results(net_idx).efficiencies = network_efficiencies;
    results(net_idx).regions = net.regions;
end

%% === 4. Visualization Results ===
fprintf('4. Generating visualization charts...\n');

% Define data
networks = {'Global Emotion Network', 'Prefrontal Network', 'Limbic System', 'Temporal Network'};
emotion_labels = {'Positive', 'Neutral', 'Negative'};
colors = lines(length(networks));

% Connection strength data
strengths_data = [
    0.0224, 0.0283, 0.0253;  % Global Emotion Network
    0.0198, 0.0261, 0.0361;  % Prefrontal Network
    0.0163, 0.0226, 0.0125;  % Limbic System
    0.0104, 0.0148, 0.0160   % Temporal Network
];

% Network efficiency data
efficiencies_data = [
    165.9455, 137.1637, 140.6964;  % Global Emotion Network
    178.3356, 175.2367, 117.5839;  % Prefrontal Network
    180.4800, 140.6809, 210.5158;  % Limbic System
    251.2834, 180.0721, 144.7313   % Temporal Network
];

% ===== Figure 1: Network Connection Strength Comparison =====
figure('Position', [100, 100, 1000, 700]);
hold on;

for i = 1:length(networks)
    plot(1:3, strengths_data(i,:), 'o-', 'LineWidth', 2.5, ...
        'MarkerSize', 8, 'Color', colors(i,:), 'DisplayName', networks{i});
end

set(gca, 'XTick', 1:3, 'XTickLabel', emotion_labels);
ylabel('Average Connection Strength');
title('Brain Network Connection Strength Comparison', 'FontSize', 14, 'FontWeight', 'bold');
legend('show', 'Location', 'northeast');
grid on;

% Add value labels
for i = 1:length(networks)
    for j = 1:3
        text(j, strengths_data(i,j) + 0.001, sprintf('%.4f', strengths_data(i,j)), ...
            'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
    end
end
ylim([0.008, 0.04]);

% ===== Figure 2: Network Efficiency Comparison =====
figure('Position', [200, 100, 1000, 700]);
hold on;

for i = 1:length(networks)
    plot(1:3, efficiencies_data(i,:), 's-', 'LineWidth', 2, ...
        'MarkerSize', 6, 'Color', colors(i,:), 'DisplayName', networks{i});
end

set(gca, 'XTick', 1:3, 'XTickLabel', emotion_labels);
ylabel('Network Efficiency');
title('Brain Network Efficiency Comparison', 'FontSize', 14, 'FontWeight', 'bold');
legend('show', 'Location', 'northeast');
grid on;

% Add efficiency value labels
for i = 1:length(networks)
    for j = 1:3
        text(j, efficiencies_data(i,j) + 5, sprintf('%.1f', efficiencies_data(i,j)), ...
            'HorizontalAlignment', 'center', 'FontSize', 8, 'FontWeight', 'bold');
    end
end
ylim([100, 260]);

