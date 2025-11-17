clc; clear; close all;

% 设置文件路径
outputFile = 'E:\Sourse\SEED\特征\1.1.xlsx';
%outputFile ='C:\Users\walam\Desktop\PSD_results\cz\alpha_psd.xlsx';
% 读取数据
data = readmatrix(outputFile);

% 提取标签和特征
label = data(:, end);      % 第二列是标签
data = data(:, 3:end-1);   % 从第三列开始是特征
data(isnan(data)) = 0;   % 处理 NaN 值
data = data(:, any(data)); % 去除全为0的列

% 检查数据大小
disp(['数据集样本数: ', num2str(size(data, 1))]);

% 如果数据量过小，终止程序
if size(data, 1) < 2
    error('数据集样本数太少，无法进行交叉验证。');
end

% 使用标签进行分层抽样，防止 cvpartition 误判
cv = cvpartition(label, 'KFold', 11);

% 初始化存储结果的变量
accuracy_svm = zeros(10, 1);

% 网格搜索 SVM 超参数
boxConstraintRange = [0.1, 1, 10, 100];
kernelScaleRange = [0.1, 0.5, 1, 2, 5];
best_accuracy = 0;

% 使用交叉验证进行 SVM 模型训练和评估
for i = 1:10
    % 获取训练集和测试集索引
    train_idx = training(cv, i);
    test_idx = test(cv, i);

    % 提取训练数据和测试数据
    traindata = data(train_idx, :);
    testdata = data(test_idx, :);
    train_label = label(train_idx, :);
    test_label = label(test_idx, :);

    % 归一化方法 - Z-score标准化
    [train_data, mu, sigma] = zscore(traindata);  % Z-score标准化
    test_data = (testdata - mu) ./ sigma;         % 使用训练数据的均值和标准差转换测试数据

    % 网格搜索 SVM 超参数
    for boxC = boxConstraintRange
        for kernelScale = kernelScaleRange
            model = fitcecoc(train_data, train_label, ...
                'Learners', templateSVM('KernelFunction', 'rbf', 'BoxConstraint', boxC, 'KernelScale', kernelScale));
            svmpredict_label = predict(model, test_data);
            accuracy = sum(svmpredict_label == test_label) / length(test_label) * 100;

            % 记录最优结果
            if accuracy > best_accuracy
                best_accuracy = accuracy;
                best_boxC = boxC;
                best_kernelScale = kernelScale;
            end
        end
    end
    
    % 训练最终的 SVM 模型
    final_model = fitcecoc(train_data, train_label, ...
        'Learners', templateSVM('KernelFunction', 'rbf', 'BoxConstraint', best_boxC, 'KernelScale', best_kernelScale));
    
    % 测试模型
    svmpredict_label = predict(final_model, test_data);
    accuracy_svm(i) = sum(svmpredict_label == test_label) / length(test_label) * 100;
end

% 计算最终结果
mean_accuracys = mean(accuracy_svm);
svm_sd = std(accuracy_svm);

disp(['最佳 BoxConstraint: ', num2str(best_boxC)]);
disp(['最佳 KernelScale: ', num2str(best_kernelScale)]);
disp(['SVM 平均准确率: ', num2str(mean_accuracys), '%']);
disp(['SVM 标准差: ', num2str(svm_sd)]);

