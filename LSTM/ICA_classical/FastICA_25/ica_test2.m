% 本函数为测试使用
% 结果和源信号反过来了
% 源信号S
clc,close all, clear all;
S = demosig;
[M,K] = size(S);
for(i=1:M)
    subplot(M,1,i);
    plot(S(i,:)), title(['原始信号',int2str(i)]);
end

% 混合信号中的每一行都是源信号的一个线性组合，系数随机
Sweight=rand(size(S,1)); 
MixedS=Sweight*S;     % 将混合矩阵重新排列并输出
figure,
for(i=1:M)
    subplot(M,1,i);
    plot(MixedS(i,:)), title(['混合信号',int2str(i)]);
end


MixedS_bak=MixedS;                  
%%%%%%%%%%%%%%%%%%%%%%%%%%  标准化  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MixedS_mean=zeros(3,1);
for i=1:3
    MixedS_mean(i)=mean(MixedS(i,:));
end                                        % 计算MixedS的均值

for i=1:3
    for j=1:size(MixedS,2)
        MixedS(i,j)=MixedS(i,j)-MixedS_mean(i);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%  白化  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MixedS_cov=cov(MixedS');                    % cov为求协方差的函数
[E,D]=eig(MixedS_cov);                      % 对信号矩阵的协方差函数进行特征值分解
Q=inv(sqrt(D))*(E)';                        % Q为白化矩阵
MixedS_white=Q*MixedS;                      % MixedS_white为白化后的信号矩阵
IsI=cov(MixedS_white');                     % IsI应为单位阵            

%%%%%%%%%%%%%%%%%%%%%%%%　FASTICA算法  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=MixedS_white;                            % 以下算法将对X进行操作
[VariableNum,SampleNum]=size(X);
numofIC=VariableNum;                       % 在此应用中，独立元个数等于变量个数
B=zeros(numofIC,VariableNum);              % 初始化列向量w的寄存矩阵,B=[b1  b2  ...   bd]
for r=1:numofIC
    i=1;maxIterationsNum=100;               % 设置最大迭代次数（即对于每个独立分量而言迭代均不超过此次数）
    IterationsNum=0;
    b=rand(numofIC,1)-.5;                  % 随机设置b初值
    b=b/norm(b);                           % 对b标准化 norm(b):向量元素平方和开根号
    while i<=maxIterationsNum+1
        if i == maxIterationsNum           % 循环结束处理
            fprintf('\n第%d分量在%d次迭代内并不收敛。', r,maxIterationsNum);
            break;
        end
        bOld=b;                          
        a2=1;
        u=1;
        t=X'*b;
        g=t.*exp(-a2*t.^2/2);
        dg=(1-a2*t.^2).*exp(-a2*t.^2/2);
        b=((1-u)*t'*g*b+u*X*g)/SampleNum-mean(dg)*b;
                                           % 核心公式，参见理论部分公式2.52
        b=b-B*B'*b;                        % 对b正交化
        b=b/norm(b); 
        if abs(abs(b'*bOld)-1)<1e-9        % 如果收敛，则
             B(:,r)=b;                     % 保存所得向量b
             break;
         end
        i=i+1;        
    end
%    B(:,r)=b;                                % 保存所得向量b
end

%%%%%%%%%%%%%%%%%%%%%%%%%%  ICA计算的数据复原并构图  %%%%%%%%%%%%%%%%%%%%%%%%%
ICAedS=B'*Q*MixedS_bak;                     % 计算ICA后的矩阵
figure,
for(i=1:M)
    subplot(M,1,i);
    plot(ICAedS(i,:)), title(['解混合信号',int2str(i)]);
end
