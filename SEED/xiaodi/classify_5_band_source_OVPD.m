clear;  clc;
%delta
load('I:\OVPD-II\source\VS\HH\delta\coveragecut.mat')
load('I:\OVPD-II\source\VS\HH\delta\durationcut.mat')
load('I:\OVPD-II\source\VS\HH\delta\occurrencecut.mat')
load('I:\OVPD-II\source\VS\HH\delta\matrixcut.mat')
data_delta = feature_fusion_OVPD(coveragecut, durationcut, occurrencecut, matrixcut);
%theta
load('I:\OVPD-II\source\VS\HH\theta\coveragecut.mat')
load('I:\OVPD-II\source\VS\HH\theta\durationcut.mat')
load('I:\OVPD-II\source\VS\HH\theta\occurrencecut.mat')
load('I:\OVPD-II\source\VS\HH\theta\matrixcut.mat')
data_theta = feature_fusion_OVPD(coveragecut, durationcut, occurrencecut, matrixcut);
%alpha
load('I:\OVPD-II\source\VS\HH\alpha\coveragecut.mat')
load('I:\OVPD-II\source\VS\HH\alpha\durationcut.mat')
load('I:\OVPD-II\source\VS\HH\alpha\occurrencecut.mat')
load('I:\OVPD-II\source\VS\HH\alpha\matrixcut.mat')
data_alpha = feature_fusion_OVPD(coveragecut, durationcut, occurrencecut, matrixcut);
%beta
load('I:\OVPD-II\source\VS\HH\beta\coveragecut.mat')
load('I:\OVPD-II\source\VS\HH\beta\durationcut.mat')
load('I:\OVPD-II\source\VS\HH\beta\occurrencecut.mat')
load('I:\OVPD-II\source\VS\HH\beta\matrixcut.mat')
data_beta = feature_fusion_OVPD(coveragecut, durationcut, occurrencecut, matrixcut);
% gamma
load('I:\OVPD-II\source\VS\HH\gamma\coveragecut.mat')
load('I:\OVPD-II\source\VS\HH\gamma\durationcut.mat')
load('I:\OVPD-II\source\VS\HH\gamma\occurrencecut.mat')
load('I:\OVPD-II\source\VS\HH\gamma\matrixcut.mat')
data_gamma = feature_fusion_OVPD(coveragecut, durationcut, occurrencecut, matrixcut);
% load('I:\microstate_feature\OVPD2\VS\WJQ_labelVS')
% label = WJQ_labelVS;
%% 数据整合
data = [data_delta, data_theta, data_alpha, data_beta, data_gamma];
% data = data_alpha;
% data = [data_alpha, data_beta, data_gamma];
data(isnan(data)) = 0;
[data_sta, ps] = mapminmax(data',-1,1);
data = data_sta';
len = size(data,1);
label = zeros(len,1);
label(1:1100,:) = 1;
label(1101:1425,:) = 2;
label(1426:2250,:) = 3;

data = data(:,any(data));
%%
% [ranks,weights] = relieff(data,label,10,'method','classification');
% bar(weights(ranks))
% xlabel('Predictor rank')
% ylabel('Predictor importance weight')
%% 整体数据分成训练集和测试集
indices = crossvalind('Kfold', max(size(data,1)), 10);%将数据样本随机分割为10部分，将数据集划分为10个大小相同的互斥子集
svmpredictlable = cell(10,1);%SVM
knnpredictlabel = cell(10,1);%KNN
accuracy_svm = zeros(10,3);
accuracy_knn = zeros(10,1);
for i = 1:1:10
test        = (indices == i);
train       = ~test;%1：表示该组数据被选中，0：未被选中
traindata   = data(train, :);
testdata    = data(test, :);
train_label = label(train,:);%label数组存放情感的三种分类情况
test_label  =label(test,:);
 %%
newtrainX=[];newtrainY=[];newtestX=[];newtestY=[];
perm1=randperm(length(traindata(:,1)));
newtrainX(:,:)=traindata(perm1,:);
newtrainY(:,:)=train_label(perm1,:);
perm2=randperm(length(testdata(:,1)));
newtestX(:,:)=testdata(perm2,:);
newtestY(:,:)=test_label(perm2,:);
%%
model = svmtrain(newtrainY, newtrainX, '-s 0 -t 2');
[svmpredict_label, accuracys, ~] = svmpredict(newtestY, newtestX, model);
accuracy_svm(i,:) = accuracys;
svmpredictlable{i,1} = svmpredict_label;
    %% KNN测试
[knnpredict_label] = KNN(newtrainX,newtrainY,newtestX, 3);
[corrPredictions, accuracyk] =  Misclassification_accuracy(newtestY, knnpredict_label);
accuracy_knn(i,:) = accuracyk;
knnpredictlabel{i,1} = knnpredict_label;
end
mean_accuracys =mean(accuracy_svm(:,1));
mean_accuracyk = mean(accuracy_knn);