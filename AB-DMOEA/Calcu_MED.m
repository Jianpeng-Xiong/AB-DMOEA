%% Calculate MED (Maximum Extension Distance)
function result=Calcu_MED(Population,N,temp_one,ins)
 TotalDist = 0;
 NearDist = inf;
 for i=1:N
     if i~=ins
        Dist = 0;
        c=(Population(i).obj-temp_one.obj).^2;
        Dist = Dist + sqrt(sum(c(:)));
        TotalDist = TotalDist + Dist;
        if Dist < NearDist
              NearDist = Dist;
         end    
     end
 end
 result = NearDist * TotalDist;
end