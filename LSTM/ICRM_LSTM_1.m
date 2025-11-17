clc;clear all
for sub_no = 1:45
    %% 数据预处理
    seg_len = 2000;
    overlap = 1000;
    Noise_Range = [0,10,20,30];
    for i = 1%:length(Noise_Range)
        fprintf('subject %d : 加噪声X %d\n', sub_no,Noise_Range(i))
        chan_select = 0;
        ica = 1; max_step = 1000; lrate = 0.01; add_noise = 1; noise_range = Noise_Range(i); insort_index = 0;
        [samp,samp_label] = SEEDSingleSubData1(sub_no,chan_select,seg_len,overlap,ica,max_step,lrate,add_noise,noise_range);
        % 用ICA对分割后数据进行BSS
        ica = 3; max_step = 1000; lrate = 0.01;
        [samp_postica,~] = SEEDSingleSubData1(sub_no,chan_select,seg_len,overlap,ica,max_step,lrate,add_noise,noise_range);
        
        %% 交叉验证
        n = size(samp,3);
        %         shuffle_index = randperm(n);
        %         samp = samp(:,:,shuffle_index);
        %         samp_label = samp_label(shuffle_index);
        %         samp_postica = samp_postica(:,:,shuffle_index);
        K = 5;
        indices = crossvalind('Kfold',n,K);
        acc_1 = zeros(1,K);
        acc_2 = zeros(1,K); 
        acc_3 = zeros(1,K);
        acc_prerm_1 = zeros(1,K);
        acc_prerm_2 = zeros(1,K); 
        acc_prerm_3 = zeros(1,K);
        acc_postica_1 = zeros(1,K);
        acc_postica_2 = zeros(1,K); 
        acc_postica_3 = zeros(1,K);
        for k = 1:K
            test_index = (indices == k);
            train_index = ~test_index;
            
            %% 定义 LSTM 网络架构相关参数
            numHiddenUnits = 200;
            numClasses = 3;
            % 选择小批量大小 25 以均匀划分训练数据
            miniBatchSize = 64;
            maxEpochs = 50;
            % 指定训练选项
            options = trainingOptions('adam', ...
                'ExecutionEnvironment','cpu', ...
                'GradientThreshold',1, ...
                'Epsilon',0.000001,...
                'InitialLearnRate',0.001,...
                'LearnRateSchedule', 'piecewise', ...
                'MaxEpochs',maxEpochs, ...
                'MiniBatchSize',miniBatchSize, ...
                'SequenceLength','longest', ...
                'Shuffle','once', ...
                'Verbose',1);
            
            %% 加噪数据ICA处理前切空间特征
            fprintf('***第 %d 次交叉验证***\n',k)
            fprintf('***训练加噪数据ICA处理前切空间特征作为输入的LSTM网络***\n')
            
            train_samp = samp(:,:,train_index);
            train_label = samp_label(train_index);
            test_samp = samp(:,:,test_index);
            test_label = samp_label(test_index);
            step0 = floor(0.5*200);
            overlap0 = floor(0.25*200);
            num = floor((2000-0.5*200)/((0.5-0.25)*200))+1;
            train_cov = CovComb(train_samp,step0,overlap0);
            test_cov = CovComb(test_samp,step0,overlap0);
%             Strain = spd2vec(train_cov);
%             Stest = spd2vec(test_cov);
            % Tangent Space
            C = logeuclid_mean(train_cov);
            %             C = mean_covariances(train_cov);
            [Strain,C] = Tangent_space(train_cov,C);
            Stest = Tangent_space(test_cov,C);
            Strain = (Strain - mean(Strain,'all')) / std(Strain,[],'all');
            Stest = (Stest - mean(Stest,'all')) / std(Strain,[],'all');
            XTrain = TSVecSeg(Strain,num);
            YTrain = categorical(train_label');
            XTest = TSVecSeg(Stest,num);
            YTest = categorical(test_label');
            % 训练 LSTM 网络
            % 1层LSTM
            fprintf('******** 一层LSTM层 ********\n')
            inputSize = size(XTrain{1},1);
            layers_1 = [sequenceInputLayer(inputSize)
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
%                 dropoutLayer(0.5)
                lstmLayer(numHiddenUnits,'OutputMode','last')
                dropoutLayer(0.3)
                fullyConnectedLayer(100)
                dropoutLayer(0.3)
                fullyConnectedLayer(50)
%                 dropoutLayer(0.5)
                fullyConnectedLayer(numClasses)
                softmaxLayer
                classificationLayer];
            net_1 = trainNetwork(XTrain,YTrain,layers_1,options);
            % 测试 LSTM 网络
            % 对测试数据进行分类
            YPred = classify(net_1,XTest, ...
                'MiniBatchSize',miniBatchSize, ...
                'SequenceLength','longest');
            % 计算预测值的分类准确度
            acc_1(k) = sum(YPred == YTest)./numel(YTest)
            
%             % 2层LSTM
%             fprintf('******** 两层LSTM层 ********\n')
%             inputSize = size(XTrain{1},1);
%             layers_2 = [sequenceInputLayer(inputSize)
% %                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
% %                 dropoutLayer(0.5)
%                 lstmLayer(numHiddenUnits,'OutputMode','last')
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(100)
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(50)
% %                 dropoutLayer(0.5)
%                 fullyConnectedLayer(numClasses)
%                 softmaxLayer
%                 classificationLayer];
%             net_2 = trainNetwork(XTrain,YTrain,layers_2,options);
%             % 测试 LSTM 网络
%             % 对测试数据进行分类
%             YPred = classify(net_2,XTest, ...
%                 'MiniBatchSize',miniBatchSize, ...
%                 'SequenceLength','longest');
%             % 计算预测值的分类准确度
%             acc_2(k) = sum(YPred == YTest)./numel(YTest)
%             
%             % 3层LSTM
%             fprintf('******** 三层LSTM层 ********\n')
%             inputSize = size(XTrain{1},1);
%             layers_3 = [sequenceInputLayer(inputSize)
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
% %                 dropoutLayer(0.5)
%                 lstmLayer(numHiddenUnits,'OutputMode','last')
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(100)
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(50)
% %                 dropoutLayer(0.5)
%                 fullyConnectedLayer(numClasses)
%                 softmaxLayer
%                 classificationLayer];
%             net_3 = trainNetwork(XTrain,YTrain,layers_3,options);
%             % 测试 LSTM 网络
%             % 对测试数据进行分类
%             YPred = classify(net_3,XTest, ...
%                 'MiniBatchSize',miniBatchSize, ...
%                 'SequenceLength','longest');
%             % 计算预测值的分类准确度
%             acc_3(k) = sum(YPred == YTest)./numel(YTest)
            
            clear train_samp test_samp train_cov test_cov XTrain XTest Strain Stest
            
             %% 加噪数据ICA处理后RM处理前切空间特征
            fprintf('***训练加噪数据ICA处理后RM处理前切空间特征作为输入的LSTM网络***\n')
            
            train_samp_prerm = samp_postica(:,:,train_index);
            test_samp_prerm = samp_postica(:,:,test_index);
            train_cov_prerm = CovComb(train_samp_prerm,step0,overlap0);
            test_cov_prerm = CovComb(test_samp_prerm,step0,overlap0);
            Strain_prerm = spd2vec(train_cov_prerm);
            Stest_prerm = spd2vec(test_cov_prerm);
            Strain_prerm = (Strain_prerm - mean(Strain_prerm,'all')) / std(Strain_prerm,0,'all');
            Stest_prerm = (Stest_prerm - mean(Stest_prerm,'all')) / std(Stest_prerm,0,'all');
            XTrain_prerm = TSVecSeg(Strain_prerm,num);
            YTrain = categorical(train_label');
            XTest_prerm = TSVecSeg(Stest_prerm,num);
            YTest = categorical(test_label');
            % 训练 LSTM 网络
            % 定义网络架构
            % 1层LSTM
            fprintf('******** 一层LSTM层 ********\n')
            inputSize = size(XTrain_prerm{1},1);
            layers_1 = [sequenceInputLayer(inputSize)
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
                lstmLayer(numHiddenUnits,'OutputMode','sequence')
%                 dropoutLayer(0.3)
                lstmLayer(numHiddenUnits,'OutputMode','last')
                dropoutLayer(0.3)
                fullyConnectedLayer(100)
                dropoutLayer(0.3)
                fullyConnectedLayer(50)
                fullyConnectedLayer(numClasses)
                softmaxLayer
                classificationLayer];
            net_prerm_1 = trainNetwork(XTrain_prerm,YTrain,layers_1,options);
            % 测试 LSTM 网络
            % 对测试数据进行分类
            YPred_prerm = classify(net_prerm_1,XTest_prerm, ...
                'MiniBatchSize',miniBatchSize, ...
                'SequenceLength','longest');
            % 计算预测值的分类准确度
            acc_prerm_1(k) = sum(YPred_prerm == YTest)./numel(YTest)
%             
%             % 2层LSTM
%             fprintf('******** 两层LSTM层 ********\n')
%             inputSize = size(XTrain_prerm{1},1);
%             layers_2 = [sequenceInputLayer(inputSize)
% %                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
% %                 dropoutLayer(0.3)
%                 lstmLayer(numHiddenUnits,'OutputMode','last')
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(100)
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(50)
%                 fullyConnectedLayer(numClasses)
%                 softmaxLayer
%                 classificationLayer];
%             net_prerm_2 = trainNetwork(XTrain_prerm,YTrain,layers_2,options);
%             % 测试 LSTM 网络
%             % 对测试数据进行分类
%             YPred_prerm = classify(net_prerm_2,XTest_prerm, ...
%                 'MiniBatchSize',miniBatchSize, ...
%                 'SequenceLength','longest');
%             % 计算预测值的分类准确度
%             acc_prerm_2(k) = sum(YPred_prerm == YTest)./numel(YTest)
%             
%             % 3层LSTM
%             fprintf('******** 三层LSTM层 ********\n')
%             inputSize = size(XTrain_prerm{1},1);
%             layers_3 = [sequenceInputLayer(inputSize)
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
% %                 dropoutLayer(0.3)
%                 lstmLayer(numHiddenUnits,'OutputMode','last')
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(100)
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(50)
%                 fullyConnectedLayer(numClasses)
%                 softmaxLayer
%                 classificationLayer];
%             net_prerm_3 = trainNetwork(XTrain_prerm,YTrain,layers_3,options);
%             % 测试 LSTM 网络
%             % 对测试数据进行分类
%             YPred_prerm = classify(net_prerm_3,XTest_prerm, ...
%                 'MiniBatchSize',miniBatchSize, ...
%                 'SequenceLength','longest');
%             % 计算预测值的分类准确度
%             acc_prerm_3(k) = sum(YPred_prerm == YTest)./numel(YTest)
%             
            clear train_samp_prerm test_samp_prerm train_cov_prerm test_cov_prerm XTrain_prerm YTrain_prerm XTest_prerm YTest_prerm Strain_prerm Stest_prerm
             
            %% 加噪数据ICA处理后切空间特征
            fprintf('***训练加噪数据ICA处理后切空间特征作为输入的LSTM网络***\n')
            
            train_samp_postica = samp_postica(:,:,train_index);
            test_samp_postica = samp_postica(:,:,test_index);
            train_cov_postica = CovComb(train_samp_postica,step0,overlap0);
            test_cov_postica = CovComb(test_samp_postica,step0,overlap0);
            % Tangent Space
            C_postica = logeuclid_mean(train_cov_postica);
            [Strain_postica,C_postica] = Tangent_space(train_cov_postica,C_postica);
            Stest_postica = Tangent_space(test_cov_postica,C_postica);
            Strain_postica = (Strain_postica - mean(Strain_postica,'all')) / std(Strain_postica,0,'all');
            Stest_postica = (Stest_postica - mean(Stest_postica,'all')) / std(Stest_postica,0,'all');
            XTrain_postica = TSVecSeg(Strain_postica,num);
            YTrain = categorical(train_label');
            XTest_postica = TSVecSeg(Stest_postica,num);
            YTest = categorical(test_label');
            
            % 训练 LSTM 网络
            % 定义网络架构
            % 1层LSTM
            fprintf('******** 两层LSTM层 ********\n')
            inputSize = size(XTrain_postica{1},1);
            layers_1 = [sequenceInputLayer(inputSize)
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
%                 dropoutLayer(0.5)
                lstmLayer(numHiddenUnits,'OutputMode','last')
                dropoutLayer(0.3)
                fullyConnectedLayer(100)
                dropoutLayer(0.3)
                fullyConnectedLayer(50)
                fullyConnectedLayer(numClasses)
                softmaxLayer
                classificationLayer];
            net_postica_1 = trainNetwork(XTrain_postica,YTrain,layers_1,options);
            % 测试 LSTM 网络
            % 对测试数据进行分类
            YPred_postica = classify(net_postica_1,XTest_postica, ...
                'MiniBatchSize',miniBatchSize, ...
                'SequenceLength','longest');
            % 计算预测值的分类准确度
            acc_postica_1(k) = sum(YPred_postica == YTest)./numel(YTest)
                      
%             % 2层LSTM
%             fprintf('******** 两层LSTM层 ********\n')
%             inputSize = size(XTrain_postica{1},1);
%             layers_2 = [sequenceInputLayer(inputSize)
% %                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
% %                 dropoutLayer(0.5)
%                 lstmLayer(numHiddenUnits,'OutputMode','last')
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(100)
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(50)
%                 fullyConnectedLayer(numClasses)
%                 softmaxLayer
%                 classificationLayer];
%             net_postica_2 = trainNetwork(XTrain_postica,YTrain,layers_2,options);
%             % 测试 LSTM 网络
%             % 对测试数据进行分类
%             YPred_postica = classify(net_postica_2,XTest_postica, ...
%                 'MiniBatchSize',miniBatchSize, ...
%                 'SequenceLength','longest');
%             % 计算预测值的分类准确度
%             acc_postica_2(k) = sum(YPred_postica == YTest)./numel(YTest)
%             
%             % 3层LSTM
%             fprintf('******** 三层LSTM层 ********\n')
%             inputSize = size(XTrain_postica{1},1);
%             layers_3 = [sequenceInputLayer(inputSize)
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
% %                 dropoutLayer(0.5)
%                 lstmLayer(numHiddenUnits,'OutputMode','last')
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(100)
%                 dropoutLayer(0.3)
%                 fullyConnectedLayer(50)
%                 fullyConnectedLayer(numClasses)
%                 softmaxLayer
%                 classificationLayer];
%             net_postica_3 = trainNetwork(XTrain_postica,YTrain,layers_3,options);
%             % 测试 LSTM 网络
%             % 对测试数据进行分类
%             YPred_postica = classify(net_postica_3,XTest_postica, ...
%                 'MiniBatchSize',miniBatchSize, ...
%                 'SequenceLength','longest');
%             % 计算预测值的分类准确度
%             acc_postica_3(k) = sum(YPred_postica == YTest)./numel(YTest)
            
            clear train_samp_postica train_label test_samp_postica test_label train_cov_postica test_cov_postica XTrain_postica YTrain_postica XTest_postica YTest_postica Strain_postica Stest_postica
        end
        
        ACC_1(sub_no,i) = mean(acc_1);
%         ACC_2(sub_no,i) = mean(acc_2); 
%         ACC_3(sub_no,i) = mean(acc_3);
        ACC_prerm_1(sub_no,i) = mean(acc_prerm_1);
%         ACC_prerm_2(sub_no,i) = mean(acc_prerm_2);
%         ACC_prerm_3(sub_no,i) = mean(acc_prerm_3);
        ACC_postica_1(sub_no,i) = mean(acc_postica_1);
%         ACC_postica_2(sub_no,i) = mean(acc_postica_2);
%         ACC_postica_3(sub_no,i) = mean(acc_postica_3);
        
        ACC.noica_1lstm = ACC_1;
%         ACC.noica_2lstm = ACC_2;
%         ACC.noica_3lstm = ACC_3;
        ACC.norm_1lstm = ACC_prerm_1;
%         ACC.norm_2lstm = ACC_prerm_2;
%         ACC.norm_3lstm = ACC_prerm_3;
        ACC.icrm_1lstm = ACC_postica_1;
%         ACC.icrm_2lstm = ACC_postica_2;
%         ACC.icrm_3lstm = ACC_postica_3;
        save('G:\MAHNOB\MATLAB程序\ACC_1lstm','-struct','ACC');
        clear samp samp_postica acc acc_prerm acc_postica
        clear net_1 net_2 net_3 
        clear net_postica_1 net_postica_2 net_postica_3 
        clear net_prerm_1 net_prerm_2 net_prerm_3
    end
end