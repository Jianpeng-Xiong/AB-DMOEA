%% 多样性调整策略
function ResponsePop=diversity_Adjustment_Strategy(Offspring1,Offspring2,Global)
     Combine_Pop=[Offspring1,Offspring2];

     [NonDominRank,~] = NDSort(Combine_Pop.objs,Combine_Pop.cons,10);
%      disp(length(NonDominRank));
%      NonDonmin_Pop=Combine_Pop(NonDominRank==1);
     for i=1:Global.N
         for j=i+1
            if NonDominRank(i)<NonDominRank(j)
                ResponsePop(i)=Combine_Pop(i); 
            elseif NonDominRank(i)>NonDominRank(j)
                ResponsePop(i)=Combine_Pop(j);  
            else
                MED1=Calcu_MED(Combine_Pop,length(Combine_Pop),Combine_Pop(i),i);
                MED2=Calcu_MED(Combine_Pop,length(Combine_Pop),Combine_Pop(j),j);
                if(MED1>MED2)
                     ResponsePop(i)=Combine_Pop(i);
                else
                     ResponsePop(i)=Combine_Pop(j);
                end
            end 
         end
     end
end