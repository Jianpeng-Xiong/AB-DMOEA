function flag=Dominates(POP,Global)
      first1 = 0;
      first2 = 0;
      first3 = 0;
     [FrontNo,~] = NDSort(POP.objs,Global.N);
     First = find(FrontNo==1);  

     for i=1:length(First)
         if First(i) <= floor(Global.N/3)  
            first1 = first1+1;
         elseif First(i) > floor(Global.N/3)*2
            first3 = first3+1;
         else
             first2 = first2+1;
         end
     end

     first = [first1,first2,first3];
     Sum = sum(first);
     Score1 = first./Sum;

       %Calculate the MED for each sub-population
        totaldist = 0;
       for i = 1:Global.N
           totaldist = totaldist + NearDist_MED(POP,Global.N,POP(i),i);
           if i == floor(Global.N/3)
               T1 = totaldist;
           elseif i==2*floor(Global.N/3)
               T2 = totaldist - T1;
           elseif i== Global.N
               T3 = totaldist - T1 - T2;
           end
       end
       Total = [T1;T2;T3];
    
    Sceond = Total./totaldist;
    Score2  = Sceond';
    Total = Score1 + Score2;
    flag = find(Total == max(Total));
   
end