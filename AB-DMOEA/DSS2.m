%% A static multi-objective optimizer DSS2
function Cur_Population=DSS2(Global,Prev_C)
     [NonRank,~] = NDSort( Global.Population.objs,Global.N);
     Cur_Population = INDIVIDUAL(Global.Population.decs);
     NonDonmin_Pop=Cur_Population(NonRank==1);
     Curr_C = mean(NonDonmin_Pop.decs);
     D=Curr_C-Prev_C;
     S=sign(D);
     for i=1:5
         r1= randperm(Global.N,1);
         newOneDec=Cur_Population(r1).dec+D+randn()*S;
         PopOne=Boundary_Repair(newOneDec,Global.lower,Global.upper);
         Cur_Population(r1)= PopOne;
     end
end