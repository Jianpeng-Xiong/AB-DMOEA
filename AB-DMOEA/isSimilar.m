% The isSimilar strategy in the memory boosting strategy.
% Assess the similarity between the current environment and the historic environment

function [index ,flag] = isSimilar(DArchive, nArchive, F, epsilon)
% Environmental similarity flag£º0 is not similar, 1 is similar, 2 is very similar
flag = 0;
index = 0;              
M = size(DArchive, 2);  
if nArchive == 0    % Not similar  
    index = 0;
    return;
end
for i=1:nArchive
    counts = 0;
    countw = 0;
    for j=1:M
        if abs(DArchive(i,j) - F(j))< epsilon*1.5 && epsilon*0.5<abs(DArchive(i,j) - F(j))
            countw = countw + 1;
        end
        if abs(DArchive(i,j) - F(j)) < epsilon*0.5
            counts = counts + 1;
        end
    end
    if counts == M
        index = i  ;          % Number of similar historical records in D
        flag = 1;
        break;
    end   
    if countw == M
        index = i  ;          % Number of similar historical records in D
        flag = 2;
        break;
    end
end
end
