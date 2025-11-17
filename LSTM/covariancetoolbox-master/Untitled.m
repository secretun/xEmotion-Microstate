clc;clear all
addpath E:\MAHNOB-HCI_database\自行处理数据
filename = 'E:\MAHNOB-HCI_database\valence\participant\1\valence\pleasant\Part_1_S_Trial10_emotion.bdf';
[~,data] = edfread(filename);
X = data(1:32,1:256);
% [~,ica] = Infomax_ICA_teacher(data,100,0.01);

% figure(1)
% for i = 1:32
%    subplot(32,1,i)
%    plot(ica(i,:))
% end

X_iva = ivabss(X,256,1000);
figure(3)
for i = 1:32
   subplot(32,1,i)
   plot(X(i,:))
end
% figure(2)
% for i = 1:32
%     subplot(32,1,i)
%     plot(X_iva(i,:))
% end
% X_filt = ft_preproc_bandpassfilter(X_iva,256,[0.1,50],4);
% figure(3)
% for i = 1:32
%     subplot(32,1,i)
%     plot(X_filt(i,:))
% end
