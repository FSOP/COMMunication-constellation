% =========================================================
% ga_main.m
% 목적: 전지구(Global) Coverage 최대화 & 위성 수 최소화를 위한
%       Walker Custom 위성군 다목적 최적화 (MATLAB gamultiobj)
%
% 최적화 변수 (3개, 실수):
%   x(1): RAAN 간격 [deg]  -> 궤도면 수       = ceil((360/x(1))/2)
%   x(2): MA 간격   [deg]  -> 궤도면당 위성 수 = ceil(360/x(2))
%   x(3): 궤도면 간 위상차 [deg]
%
% 목적함수 (동시 최소화):
%   f1 = test0706(x) : 전지구 Coverage(%) 음수 반환 -> 최대화 효과
%   f2 = test0707(x) : 전체 위성 수 -> 최소화
%
% 위성 설정: SSO 880km, 센서 반각 51도
% 분석 기간: 1일 (Python evaluator.py 동일)
%
% 대응 Python: run_optimization.py + optimizer.py (NSGA-II)
% =========================================================

nvars      = 3;
generations    = 5;
populationsize = 20;

FitnessFunction = @(x)[test0706(x), test0707(x)];

% 설계 변수 범위 — Python optimizer.py (xl/xu) 와 동일
%   RAAN 간격: 10 ~ 35 deg
%   MA 간격:   15 ~ 30 deg
%   위상차:     0 ~ 45 deg
lb = [10, 15,  0];
ub = [35, 30, 45];

options = optimoptions('gamultiobj', ...
    'PlotFcn',             {@gaplotpareto, @gaplotscorediversity}, ...
    'InitialPopulationRange', [lb; ub], ...
    'PopulationSize',      populationsize, ...
    'MaxGenerations',      generations);

[x, fval, exitflag, output] = gamultiobj(FitnessFunction, nvars, [], [], [], [], lb, ub, [], options);

disp('=== Pareto 해 (설계 변수: RAAN간격, MA간격, 위상차) ===');
disp(x);
disp('=== Pareto 목적함수값 (-Coverage%, 위성수) ===');
disp(fval);
