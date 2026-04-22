% ga_main.m
%

nvars = 3; % inclination, raan, gamma, n
generations = 5;
populationsize = 20;

Function=@test0706;
FitnessFunction = @(x)[test0706(x) test0707(x)];

%     i = 45;
%     ra_space = 5;
%     ma_interval = 14; % deg
%     ma_shift = 14;

vec = [16, 16, 0;
       20, 20, 5];

lb = vec(1,:);
ub = vec(2,:);
IntCon = 3:3;

%options=optimoptions('ga','FunctionTolerance',600,'PopulationSize', populationsize, 'MaxGenerations', generations,'Display','iter','PlotFcn',@gaplotbestf);
options=optimoptions('gamultiobj', 'PlotFcn',{@gaplotpareto,@gaplotscorediversity},'InitialPopulationRange',[lb;ub],'PopulationSize',populationsize,'Generations',generations);

%[x,fval, exitflag, output, population, scores] = ga(Function, nvars,[],[],[],[],lb,ub,[],IntCon,options);
[x,fval,exitflag,output]=gamultiobj(FitnessFunction,nvars,[],[],[],[],lb,ub,[],IntCon,options);

x
fval
