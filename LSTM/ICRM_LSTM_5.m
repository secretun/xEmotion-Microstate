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
        for k = 1:K
            test_index = (indices == k);
            train_index = ~test_index;
            
            %% 定义 LSTM 网络架构相关参数
            numHiddenUnits = 200;
            numClasses = 3;
            % 选择小批量大小 25 以均匀划分训练数据
            miniBatchSize = 128;
            maxEpochs = 50;
            % 指定训练选项
            options = trainingOptions('adam', ...
                'ExecutionEnvironment','gpu', ...
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
            fprintf('***训练加噪数据无RM和ICA处理的协方差特征作为输入的LSTM网络***\n')
            
            train_samp = samp(:,:,train_index);
            train_label = samp_label(train_index);
            test_samp = samp(:,:,test_index);
            test_label = samp_label(test_index);
            step0 = floor(0.5*200);
            overlap0 = floor(0.25*200);
            num = floor((2000-0.5*200)/((0.5-0.25)*200))+1;
            train_cov = CovComb(train_samp,step0,overlap0);
            test_cov = CovComb(test_samp,step0,overlap0);
            Strain = spd2vec(train_cov);
            Stest = spd2vec(test_cov);
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
            
            % 2层LSTM
            fprintf('******** 两层LSTM层 ********\n')
            inputSize = size(XTrain{1},1);
            layers_2 = [sequenceInputLayer(inputSize)
%                 lstmLayer(numHiddenUnits,'OutputMode','sequence')
                lstmLayer(numHiddenUnits,'OutputMode','sequence')
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
            net_2 = trainNetwork(XTrain,YTrain,layers_2,options);
            % 测试 LSTM 网络
            % 对测试数据进行分类
            YPred = classify(net_2,XTest, ...
                'MiniBatchSize',miniBatchSize, ...
                'SequenceLength','longest');
            % 计算预测值的分类准确度
            acc_2(k) = sum(YPred == YTest)./numel(YTest)
            
            % 3层LSTM
            fprintf('******** 三层LSTM层 ********\n')
            inputSize = size(XTrain{1},1);
            layers_3 = [sequenceInputLayer(inputSize)
                lstmLayer(numHiddenUnits,'OutputMode','sequence')
                lstmLayer(numHiddenUnits,'OutputMode','sequence')
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
            net_3 = trainNetwork(XTrain,YTrain,layers_3,options);
            % 测试 LSTM 网络
            % 对测试数据进行分类
            YPred = classify(net_3,XTest, ...
                'MiniBatchSize',miniBatchSize, ...
                'SequenceLength','longest');
            % 计算预测值的分类准确度
            acc_3(k) = sum(YPred == YTest)./numel(YTest)
            
            clear train_samp test_samp train_cov test_cov XTrain XTest Strain Stest          
        end
        
        ACC_1(sub_no,i) = mean(acc_1);
        ACC_2(sub_no,i) = mean(acc_2); 
        ACC_3(sub_no,i) = mean(acc_3);
        
        ACC.lstm1 = ACC_1;
        ACC.lstm2 = ACC_2;
        ACC.lstm3= ACC_3;

        save('G:\MAHNOB\MATLAB程序\ACC_onlylstm','-struct','ACC');
        clear samp samp_postica acc acc_prerm acc_postica
        clear net_1 net_2 net_3 
    end
end