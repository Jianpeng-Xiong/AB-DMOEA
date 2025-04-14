function [p,q] = RateDECPM(method,prePop_var,p,pop_var,q)
alpha = 0.8;
Pmin = 0.1;
K = numel(p);
nPopSize = size(pop_var, 1);
% 对kalma预测和随机生成记分
PredictionScore = 0;
MemoryScore = 0;
DiversityScore = 0;
% 记录子代采用KF生成的个体和随机生成的个体数目
PredictionCount = 0;
MemoryCount = 0;
DiversityCount = 0;
if method(1) == 0
    return;
end
%distance = sqrt(sum((pop_var - prePop_var).^2,2));
distance =  min(pdist2(prePop_var,pop_var),[],2);
average = mean(distance);
for i = 1:nPopSize
    if method(i) == 1
        MemoryCount = MemoryCount + 1;
        if distance(i) < average
            MemoryScore = MemoryScore + 1;
        end
    elseif method(i) == 2
        PredictionCount = PredictionCount + 1;
        if distance(i) < average
            PredictionScore = PredictionScore + 1;
        end
    elseif method(i) == 3
        DiversityCount = DiversityCount + 1;
        if distance(i) < average
            DiversityScore = DiversityScore + 1;
        end
    end
end
if MemoryCount == 0
    r(1) = 0;
else
    r(1) = MemoryScore/MemoryCount;
end
if PredictionCount == 0
    r(2) = 0;
else
    r(2) = PredictionScore/PredictionCount;
end
if DiversityCount == 0
    r(3) = 0;
else
    r(3) = DiversityScore/DiversityCount;
end
q = (1-alpha)*q +alpha.*r; 
p = Pmin + (1-K*Pmin)*q./sum(q);
end
