% Dominated solution reinforcement strategy
function NewPop =DSRS(Global, Population)
    pop1 = [];
    Offspring2 = [];
    [FrontNo,~] = NDSort(Population.objs,Population.cons,Global.N);
    First = find(FrontNo==1);   %Non-dominated solutions
    Other =setdiff(1:Global.N, First); %Dominated solutions
    Pop_Decs2 = [];
    if length(First) ==1
        First_Decs = Population(First).dec;
        first_decs = Population(First).dec; 
    elseif length(First) >1
        First_Decs = mean(Population(First).decs);
        first_decs = Population(First).decs;
    end
    Other_Decs = mean(Population(Other).decs);
    other_decs = Population(Other).decs;
    DF = First_Decs - Other_Decs;   
    Pop_Decs1 = first_decs ;
    if length(First) < Global.N
        Pop_Decs2 = other_decs + DF;
    end
    Pop_Decs = [Pop_Decs1;Pop_Decs2];
    Pop_Decs = Boundary_Repair(Pop_Decs,Global.lower,Global.upper);
    pop2 = INDIVIDUAL(Pop_Decs);
    for i = 1: Global.N-2
        if mod(i,2)==0
         pop1 = [pop1; GA( [Pop_Decs(i,:);Pop_Decs(i+1,:);Pop_Decs(i+2,:)])];
        else
         Offspring2 = [Offspring2 DE( pop2(1,i),pop2(1,i+1) ,pop2(1,i+2))];
        end
    end
    Offspring1 = INDIVIDUAL(pop1);
    Offspring2 = pop2;
    NewPop = diversity_Adjustment_Strategy(Offspring1,Offspring2,Global);
end
