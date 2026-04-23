% =========================================================
% test0706.m
% 목적: Walker Custom 위성군의 전지구 Coverage(%) 계산
%       gamultiobj 첫 번째 목적함수 (최소화 → 반환값 = -Coverage%)
%
% 입력 x:
%   x(1): RAAN 간격 [deg]  -> 궤도면 수       = ceil((360/x(1))/2)
%   x(2): MA 간격   [deg]  -> 궤도면당 위성 수 = ceil(360/x(2))
%   x(3): 궤도면 간 위상차 [deg]
%
% 출력 f_val: -Coverage(%)  (gamultiobj 최소화 → Coverage 최대화 효과)
%
% 위성 설정: SSO 880km, 센서 반각 51도 (stk_m_refsat_SSO 동일)
% 분석 기간: 1일 (Python evaluator.py 동일)
% Coverage : 전지구, 15도 grid (Python config.py grid_granularity_deg=15 동일)
% =========================================================
function f_val = test0706(x)
    addpath(genpath('..\0_Library'));

    % --- 분석 파라미터 (Python config.py 동일) ---
    analysis_epoch  = "1 Jan 2022 03:00:00";
    analysis_period = "+1 day";

    % --- 설계 변수 파싱 ---
    ra_space    = x(1);  % RAAN 간격 [deg]
    ma_interval = x(2);  % MA 간격   [deg]
    inter_plane = x(3);  % 궤도면 간 위상차 [deg]

    % 위성군 구성 계산 (Python evaluator.py 동일 수식)
    NumPlanes      = ceil((360 / ra_space) / 2);
    NumSatPerPlane = ceil(360 / ma_interval);

    % --- STK 초기화 및 시나리오 클리어 ---
    root = init_stk();
    root.ExecuteCommand(strcat('SetAnalysisTimePeriod * "', analysis_epoch, '" "', analysis_period, '"'));
    stk_m_remove(root);
    
    % --- Coverage Definition 설정: 전지구, 15도 grid ---
    root.ExecuteCommand("New / */CoverageDefinition Targets");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Access AutoRecompute off");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid AreaOfInterest Global");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid PointGranularity LatLon 15");

    % --- 기준 위성 생성 (SSO 880km, 센서 반각 51도) ---
    ref_name = stk_m_refsat_SSO(1, root);

    % --- Walker Custom 커맨드 생성 및 실행 ---
    % Python constellation.py create_walker_constellation() 동일 로직
    walker_command = sprintf( ...
        "Walker */Satellite/%s Type Custom NumPlanes %d NumSatsPerPlane %d " + ...
        "InterPlaneTrueAnomalyIncrement %.2f RAANIncrement %.2f ColorByPlane No ConstellationName WalkerConst", ...
        ref_name, NumPlanes, NumSatPerPlane, inter_plane, ra_space);
    disp(walker_command);
    root.ExecuteCommand(walker_command);

    % --- Walker 생성 위성 전체를 Coverage에 할당 ---
    % STK Walker 위성 이름 패턴: <ref_name><plane(zero-padded)><sat(zero-padded)>
    % Python constellation.py 의 sat_names 생성 로직과 동일
    plane_digits = floor(log10(max(NumPlanes, 1))) + 1;
    sat_digits   = floor(log10(max(NumSatPerPlane, 1))) + 1;
    plane_fmt    = sprintf('%%0%dd', plane_digits);
    sat_fmt      = sprintf('%%0%dd', sat_digits);

    for p = 1:NumPlanes
        for s = 1:NumSatPerPlane
            sat_name = sprintf("%s%s%s", ref_name, ...
                sprintf(plane_fmt, p), sprintf(sat_fmt, s));
            root.ExecuteCommand("Cov */CoverageDefinition/Targets Asset */Satellite/" + sat_name + "/Sensor/Ant Assign");
        end
    end

    % --- FOM 설정: Coverage Time (%) ---
    root.ExecuteCommand("New / */CoverageDefinition/Targets/FigureOfMerit Revisit");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets/FigureOfMerit/Revisit FOMDefine Definition CoverageTime Compute Percent");
    root.ExecuteCommand("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Animation off");
    root.ExecuteCommand("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Static off");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Access Compute");

    % --- Coverage 결과 파싱 ---
    res  = root.ExecuteCommand('Report_RM */CoverageDefinition/Targets/FigureOfMerit/Revisit Style "New Report"');
    data = res.Item(1);
    avg  = split(data, ',');
    coverage_pct = str2double(avg{1});
    disp(coverage_pct);

    % gamultiobj 최소화 -> Coverage 최대화를 위해 부호 반전
    f_val = -coverage_pct;
end