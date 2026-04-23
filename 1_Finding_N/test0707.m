% =========================================================
% test0707.m
% 목적: 현재 STK 시나리오의 전체 위성 수 반환
%       gamultiobj 두 번째 목적함수 (최소화)
%
% 동작: test0706 실행 후 STK에 Walker로 생성된 위성 수를 카운트.
%       STK AllInstanceNames 결과에서 "Satellite" 문자열 개수 / 2.
%       (STK 오브젝트 경로에 "Satellite"가 두 번 등장하므로 /2 보정)
%
% 대응 Python: evaluator.py 의 satellite_count = num_planes * sats_per_plane
%              (Python은 STK 조회 없이 수식으로 직접 계산)
% =========================================================
function f_val = test0707(x)
    addpath(genpath('..\.\0_Library'));

    root = init_stk();

    % STK 시나리오 내 전체 오브젝트 이름 목록 조회
    data = root.ExecuteCommand("AllInstanceNames /");
    res  = data.Item(0);

    % "Satellite" 등장 횟수 / 2 = 실제 위성 수
    f_val = count(res, 'Satellite') / 2;
    disp(f_val);
end