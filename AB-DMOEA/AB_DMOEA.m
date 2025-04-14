function AB_DMOEA(Global)
% <algorithm> <A>
% Dynamic multi-objective optimization evolutionary algorithm
% delta --- 0.9 --- The probability of choosing parents locally
% nr    ---   2 --- Maximum number of solutions replaced by each offspring
% nSizeArchive --- 50 ---    The size of archive DArchive and archive CArchive
% epsilon    --- 10^-4 ---   The threshold for determining environmental similarity

% This is a simple demo of AB_DMOEA
%-------------------------------------------------------------------------------------------------------------
% If you find this code useful in your work, please cite the following paper " Hu Peng, Jianpeng Xiong, Chen Pi,
% Xinyu Zhou, Zhijian Wu. A dynamic multi-objective optimization evolutionary algorithm with adaptive boosting. 
% Swarm and Evolutionary Computation, 2024, 101621". https://doi.org/10.1016/j.swevo.2024.101621
%-------------------------------------------------------------------------------------------------------------
% This function is implmented by Jianpeng Xiong.
%------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------
% More information can be found on the homepage of my tutor Hu Peng: https://whuph.github.io/index.html
%------------------------------------------------------------------------------------------------------
%------------------------------- DMO---------------------------------------

%% Parameter setting
[delta,nr,nSizeArchive,epsilon] = Global.ParameterSet(0.9,2,50,10^-4);

%% Generate the weight vectors
[W,Global.N] = UniformPoint(Global.N,Global.M);
T = 20;     

 %% Detect the neighbours of each solution
B = pdist2(W,W);
[~,B] = sort(B,2);
B = B(:,1:T);

%% Generate random population
Global.Initialization();

%% Parameter setting
prePop_var = Global.Population.objs;
Z = min(Global.Population.objs,[],1);
T=0;  %        % Number of environmental changes
flagS = 3; %The initial SMOA is MOEA/D-DE.
DArchive = zeros(nSizeArchive,Global.M);  % The DArchive archive stores the mean values of objecrive variables in each dimension for all detectors
CArchive = zeros(nSizeArchive,Global.D);  % The CArchive archive stores the mean values of decision variables in each dimension for all detectors
iSizeArch = 0;                          % The current archive size
similarIndex = 0;                       % The similar environmental indicators in isSimilar strategy


K = 3;               % The number of strategies in adaptive boosting response mechanism
q = 1/K*ones(1, K);  % Parameter in scoring scheme
p = 1/K*ones(1, K);  % Parameter in scoring scheme
method = zeros(1, Global.N);  % Initialize the number of policy optimizations for each strategy

%% Evolutionary optimization
while Global.NotTermination
    % Detecting changes in the environment using re-evaluation methods
    if Global.hasChanged 
        T=T+1;
        % Record the population
        static_Pop =Global.Population.objs;
        [FrontNo,~] = NDSort(Global.Population.objs,Global.N);
        First = find(FrontNo==1);
        lengfirst = length(First);

        % Dominated solution reinforcement strategy
        if lengfirst < Global.N*0.7
            Global.Population = DSRS(Global, Global.Population);
        end
       
         % Adaptive boosting of various strategies before dynamic response
        if Global.gen-50>Global.problem.tauT       
               [p,q] = RateDECPM(method,prePop_var,p,static_Pop,q);
        end
        
        if Global.gen-50==Global.problem.tauT       
           F = mean(Global.Population.objs);         
           C = mean(Global.Population.decs);      
           DArchive(iSizeArch+1,:) = F;             
           iSizeArch = iSizeArch + 1; 
           Dir = C - C;                          % Direction 0 set when first changing
           for i = 1:Global.N
                indPredict = rouletteWheelSelectionByProb(p);
                if indPredict == 1 
                    Global.Population(i) = diversity(Global.Population(i).dec,Global);
                elseif indPredict == 2 || indPredict == 3
                      Global.Population(i)  = predict(Dir,Global.Population(i).dec,Global);                  
                end
           end
             %Static optimization boosting mechanism
             %Comparison between single strategy and proposed strategy
             p = 1/K*ones(1, K);				
             flagS = 2;
             % flagS = 3; 
             % flagS = Select(Global,delta,Z,nr); 
        else
            F = mean(Global.Population.objs);      
            C = mean(Global.Population.decs);       
            if (similarIndex ~= 0)
                CArchive(similarIndex,:) = C;
            else
                CArchive(iSizeArch,:) = C;
            end

            % Assess the similarity between the current environment and the historic environment
            [similarIndex,flag] = isSimilar(DArchive, iSizeArch, F, epsilon); 
            if similarIndex
                DArchive(iSizeArch,:) = F;
            else
                if iSizeArch >= nSizeArchive
                    DArchive = DArchive(2:end,:);  % Manage archives according to the principle of FIFO
                    CArchive = CArchive(2:end,:);  % Environmental identification archives are related to population identification archives。
                    iSizeArch = iSizeArch - 1;
                end
                DArchive(iSizeArch+1,:) = F;
                iSizeArch = iSizeArch + 1;
            end
            for i=1:Global.N
                indPredict = rouletteWheelSelectionByProb(p);
                Dir = C - Curr_C;
                if indPredict == 1
                  % The new solutions generated by diversity boosting strategy
                    Global.Population(i) = diversity(Global.Population(i).dec,Global);
                    method(i) = 1;    
                elseif indPredict == 2
                   % The new solutions generated by predict boosting strategy
                      Global.Population(i)  = predict(Dir,Global.Population(i).dec,Global);                  
                      method(i) = 2;              
                elseif indPredict == 3
                    % The new solutions generated by memory boosting strategy
                    if  flag == 2
                        Offspring = Global.Population(i).dec + CArchive(similarIndex,:) - C;
                        Global.Population(i) = INDIVIDUAL(Offspring);
                    elseif flag == 1
                       Global.Population(i) = Global.Population(i).dec + C - pre_C;
                    else
                        d = norm(Dir)/Global.D;
                        Global.Population(i) = Global.Population(i).dec + C - pre_C + normrnd(0,d,1,Global.D);
                    end
                    method(i) = 3; 
                end
            end

        end
        
        Curr_C = C;
        pre_C  = C;
        Z = min(Global.Population.objs,[],1);
        prePop_var = Global.Population.objs;
    else
      %% Static multi-objective optimization
        if flagS == 1  % NSGA-II-DE
         [~,FrontNo,CrowdDis] = NSGA_II_EnvironmentalSelection(Global.Population,Global.N);
         MatingPool = TournamentSelection(2,Global.N,FrontNo,-CrowdDis);
         Offspring = [];
         for i=1:Global.N
              if i==Global.N
                 j=1;
             else
                 j=i+1;
             end
             Offspring = [Offspring DE(Global.Population(i),Global.Population(MatingPool(i)),Global.Population(MatingPool(j)))];
         end
         [Global.Population,~,~] = NSGA_II_EnvironmentalSelection([Global.Population,Offspring],Global.N);

        elseif flagS == 2 %RMMEDA
            Offspring  = Operator(Global.Population);
            Global.Population = RMMEDAEnvironmentalSelection([Global.Population,Offspring],Global.N);
        elseif flagS==3   %MOEAD-DE
            for i = 1 : Global.N
                if rand < delta
                    PN = B(i,randperm(end));
                else
                    PN = randperm(Global.N);
                end
                % Generate an offspring
                Offspring = DE(Global.Population(i),Global.Population(PN(1)),Global.Population(PN(2)));
                % Update the ideal point
                Z = min(Z,Offspring.obj);
                % Update the solutions in P by Tchebycheff approach
                g_old = max(abs(Global.Population(PN).objs-repmat(Z,length(PN),1)).*W(PN,:),[],2);
                g_new = max(repmat(abs(Offspring.obj-Z),length(PN),1).*W(PN,:),[],2);
                Global.Population(PN(find(g_old>=g_new,nr))) = Offspring;
            end
        end
    end
end