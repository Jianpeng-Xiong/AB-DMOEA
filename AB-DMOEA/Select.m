% Static optimization boosting mechanism
function flag=Select(Global,delta,Z,nr) 
   % Score each static optimizer
    randPP = randperm(Global.N);
    sizeNSGAII = floor(Global.N/3);
    sizeRMMEDA = floor(Global.N/3);
    sizeMOEAD = Global.N - sizeNSGAII - sizeRMMEDA;
    POP1 = Global.Population(randPP(1:sizeNSGAII));
    POP2 = Global.Population(randPP(sizeNSGAII+1:2*sizeRMMEDA));
    POP3 = Global.Population(randPP(2*sizeRMMEDA+1:Global.N));

 % Static optimization
  for t=1:Global.problem.tauT
        % Static optimization by NSGA-II-DE
         [~,FrontNo,CrowdDis] = NSGA_II_EnvironmentalSelection(POP1,sizeNSGAII);
         MatingPool = TournamentSelection(2,sizeNSGAII,FrontNo,-CrowdDis);
         Offspring = [];
         for i=1:sizeNSGAII
             if i==sizeNSGAII
                 j=1;
             else
                 j=i+1;
             end
                 Offspring = [Offspring DE(POP1(i),POP1(MatingPool(i)),POP1(MatingPool(j)))];
         end
         [POP1,~,~] = NSGA_II_EnvironmentalSelection([POP1,Offspring],sizeNSGAII);

        % Static optimization by RM-MEDA
        Offspring  = Operator(POP2);
        POP2 = RMMEDAEnvironmentalSelection([POP2,Offspring],sizeRMMEDA);

        %% Generate the weight vectors
         [W,sizeMOEAD] = UniformPoint(sizeMOEAD,Global.M);
         T = floor(20/3);     

        %% Detect the neighbours of each solution
         B = pdist2(W,W);
         [~,B] = sort(B,2);
         B = B(:,1:T);

        % Static optimization by MOEAD-DE
        for i = 1 : sizeMOEAD
            if rand < delta
                PN = B(i,randperm(end));
            else
                PN = randperm(sizeMOEAD-1);
            end
            % Generate an offspring
            Offspring = DE(POP3(i),POP3(PN(1)),POP3(PN(2)));
            % Update the ideal point
            Z = min(Z,Offspring.obj);
            % Update the solutions in P by Tchebycheff approach
            if length(PN)>34
            aaa;
            end
            g_old = max(abs(POP3(PN).objs-repmat(Z,length(PN),1)).*W(PN,:),[],2);
            g_new = max(repmat(abs(Offspring.obj-Z),length(PN),1).*W(PN,:),[],2);
            POP3(PN(find(g_old>=g_new,nr))) = Offspring;
        end
  end
  
    flag = Dominates([POP1 POP2 POP3],Global);

end