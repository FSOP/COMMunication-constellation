% ga_main.m
%

nvars = 4; % inclination, raan, gamma, n
generations = 10;
populationsize = 100;

%Function=@test0706;
FitnessFunction = @(x)[test_walker(x) test0707(x)];

%     i = x(1);
%     num_plane = x(2);
%     sat_per_plane = x(3);
%     inter_plane = x(4);

vec = [40, 10, 10, 0;
       50, 20, 50, 4];

lb = vec(1,:);
ub = vec(2,:);
IntCon = 2:4;

%options=optimoptions('ga','FunctionTolerance',600,'PopulationSize', populationsize, 'MaxGenerations', generations,'Display','iter','PlotFcn',@gaplotbestf);
options=optimoptions('gamultiobj', 'OutputFcns',{@gaoutputfcn}, 'PlotFcn',{@gaplotpareto,@gaplotscorediversity},'InitialPopulationRange',[lb;ub],'PopulationSize',populationsize,'Generations',generations);

%[x,fval, exitflag, output, population, scores] = ga(Function, nvars,[],[],[],[],lb,ub,[],IntCon,options);
[x,fval,exitflag,output]=gamultiobj(FitnessFunction,nvars,[],[],[],[],lb,ub,[],IntCon,options);

x
fval
