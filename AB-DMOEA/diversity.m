% Diversity boosting strategy in the adaptive boosting response mechanism.
function  Subpop = diversity(ind,Global)      
  a = randperm(3,1);
   [FrontNo,~] = NDSort(Global.Population.objs,Global.N);
    First = find(FrontNo==1);             
  if a==1
      Pop = Polynomial_mutation([Global.Population( First).decs ;ind],1,Global.D,1,20,Global.lower,Global.upper);
      Subpop = Pop(1);
  elseif a==2
      pop_decs = GA([Global.Population( First).decs ;ind]);
      Pop = INDIVIDUAL(pop_decs );
      Subpop = Pop(1);
  else
      Subpop = ind + normrnd(0,1);
  end

end
