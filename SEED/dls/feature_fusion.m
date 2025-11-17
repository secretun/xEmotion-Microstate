function data = feature_fusion(coverage, duration, occurence, TP_all)
% coverage标准化
coverage_positive = [coverage{1,:}; coverage{12,:}; coverage{15,:}; coverage{2,:}; coverage{6,:}];
coverage_neutral = [coverage{8,:}; coverage{11,:}; coverage{14,:}; coverage{3,:}; coverage{5,:}];
coverage_negative = [coverage{9,:}; coverage{10,:}; coverage{13,:}; coverage{4,:}; coverage{7,:}];
nc1 = size(coverage_positive,1);nc2 = size(coverage_neutral,1);nc3 = size(coverage_negative,1);
coverage_all = [coverage_positive(1:nc1,:); coverage_neutral(1:nc2,:); coverage_negative(1:nc3,:)];
%% duration标准化
duration_positive = [duration{1,:}; duration{12,:}; duration{15,:}; duration{2,:}; duration{6,:}];
duration_neutral = [duration{8,:}; duration{11,:}; duration{14,:}; duration{3,:}; duration{5,:}];
duration_negative = [duration{9,:}; duration{10,:}; duration{13,:}; duration{4,:}; duration{7,:}];
nd1 = size(duration_positive,1);nd2= size(duration_neutral,1);nd3= size(duration_negative,1);
duration_all = [duration_positive(1:nd1,:); duration_neutral(1:nd2,:); duration_negative(1:nd3,:)];
%% occurence标准化
occurence_positive = [occurence{1,:}; occurence{12,:}; occurence{15,:}; occurence{2,:}; occurence{6,:}];
occurence_neutral = [occurence{8,:}; occurence{11,:}; occurence{14,:}; occurence{3,:}; occurence{5,:}];
occurence_negative = [occurence{9,:}; occurence{10,:}; occurence{13,:}; occurence{4,:}; occurence{7,:}];
no1 = size(occurence_positive,1);no2 = size(occurence_neutral,1);no3= size(occurence_negative,1);
occurence_all = [occurence_positive(1:no1,:); occurence_neutral(1:no2,:); occurence_negative(1:no3,:)];
%% 跃迁概率
TP = cell(15,1);
for i = 1:1:15
    tp = TP_all{i,1};
%     m = size(tp,1);
%     tpcut = zeros(m,25);
    for j = 1%:1:m
        a = reshape(tp,1,25);
        tpcut(j,:) = a;
    end

    TP{i,1} = tpcut;
end
tp_positive = [TP{1,1}; TP{12,1}; TP{15,1}; TP{2,1}; TP{6,1}];
tp_neutral = [TP{8,1}; TP{11,1}; TP{14,1}; TP{3,1}; TP{5,1}];
tp_negative = [TP{9,1}; TP{10,1}; TP{13,1}; TP{4,1}; TP{7,1}];
nt1 = size(tp_positive,1);nt2 = size(tp_neutral,1);nt3 = size(tp_negative,1);
tp_all = [tp_positive(1:nt1,:); tp_neutral(1:nt2,:); tp_negative(1:nt3,:)];
 data = [coverage_all,duration_all, occurence_all,tp_all];
end
