% Prediction boosting strategy in the adaptive boosting response mechanism.
function  SubPop = predict(Dir,ind,Global)   
d = norm(Dir)/Global.D;

Pos1=ind+0.5*Dir;    %预测三条Pos
Pos2=ind+Dir + normrnd(0,d,1,Global.D);
Pos3=ind+1.5*Dir;

subpopdec = Boundary_Repair([Pos1;Pos2;Pos3],Global.lower,Global.upper);
SubPop = INDIVIDUAL(subpopdec(randperm(3,1)));
 
end