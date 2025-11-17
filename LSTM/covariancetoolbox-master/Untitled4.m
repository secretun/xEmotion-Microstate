clc;clear all
addpath E:\MAHNOB-HCI_database\自行处理数据
filename = 'E:\MAHNOB-HCI_database\valence\participant\1\valence\pleasant\Part_1_S_Trial10_emotion.bdf';
[~,data] = edfread(filename);
data = data(1:32,1001:2000);
nw = 2.5;
fs = 256;
fmax = 50;
fmin = 0.1;
[Pxy, f, nss] = xspt(data,nw,fs,fmax,fmin);
Pxy_abs = abs(Pxy);
Pxx = zeros(size(Pxy_abs,1),size(Pxy_abs,3));
for i = 1:size(Pxy_abs,3)
   p = Pxy_abs(:,:,i);
   diag_p = diag(p);
   Pxx(:,i) = diag_p';
end

Cov = covariances(log10(Pxx));
rank(Cov)

PPcxy = abs(Pxy);


figure(2)
for i = 1:32
    plot(log10(Pxx(i,:)))
    hold on
end