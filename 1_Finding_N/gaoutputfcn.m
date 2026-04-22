% A.8: gaoutputfcn.m
function [state, options,optchanged] = gaoutputfcn(options,state,flag)
optchanged = false;
switch flag
    case 'init'
disp('Starting the algorithm');
% case {'iter','interrupt'}
% disp('Iterating ...')
    case 'iter'
genpop=state.Population
genscore=state.Score
gennum=state.Generation
%genbest=state.Best
save('genscore.mat','genscore')
save('gennum.mat','gennum')
save('genpop.mat','genpop')
%save('genbest.mat','genbest')
    case 'done'
disp('Performing final task');
end