%% Calculate MED (Maximum Extension Distance)
function NearDist=NearDist_MED(Population,N,temp_one,ins)
 NearDist = inf;
 for i=1:N
     if i~=ins
        Dist = 0;
        c=(Population(i).obj-temp_one.obj).^2;
        Dist = Dist + sqrt(sum(c(:)));
        if Dist < NearDist
              NearDist = Dist;
         end    
     end
 end
end