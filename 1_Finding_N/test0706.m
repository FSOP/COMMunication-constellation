function f_val=test0706(x)
    addpath(genpath('..\0_Library'));
    
    analysis_epoch = "1 Jan 2022 03:00:00"; % Reference time in UTCG
    analysis_period = "+6 hrs";
    
    global diff;
    lan = 8;
    raan = 153.75; % Coordination System TrueOfDate
    diff = raan - lan;
    
    %ma_list = [10 29 45 59 70 81 100 110 121.5 134.5 151 170 190 209 225 239 250 260 280 290 302 315 331 350];
    
%     i = 45;
%     ra_space = 5;
%     ma_interval = 14; % deg
%     ma_shift = 14;

    ra_space = x(1);
    ma_interval = x(2);
    % ma_shift = x(3); % Inter plane Shift
    
    lan = 0;    
    root = init_stk();    
    root.ExecuteCommand(strcat('SetAnalysisTimePeriod * "',analysis_epoch,'" "+6 hrs"'));    
    stk_m_remove(root);
    
    root.ExecuteCommand("New / */CoverageDefinition Targets");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Access AutoRecompute off");
    
    % root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid AreaOfInterest Custom AreaTarget AreaTarget/Targets");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid AreaOfInterest Global");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid PointGranularity LatLon 15");
    
    ref_name = stk_m_refsat_SSO(1,root);
    NumPlanes = ceil((360 / ra_space)/2);
    NumSatPerPlane = ceil(360 / ma_interval);
    InterPlanePhaseAngle = x(3);
    RAANSpace= ra_space;

    walker_command = generate_custom_walker(ref_name, NumPlanes, NumSatPerPlane, InterPlanePhaseAngle, RAANSpace);
    disp(walker_command)
    root.ExecuteCommand(walker_command);
    % root.ExecuteCommand("Walker */Satellite/REF_1_ Type Delta NumPlanes 2 NumSatsPerPlane 4 InterPlanePhaseIncrement 1 ColorByPlane Yes");

    for p=1:length(la_list)
    %for p=1:3
        %ra = lan + (plane_interval * (p-1));    
        la = la_list(p);
        ra = lan2raan(la);
        %ra = lan2raan(ra);
        
        % ref_name = stk_m_refsat(int2str(p),la,i,rev_to_repeat,root);        
        

        for j=1:length(ma_list)
            ma = ma_list(j);
            ma = ma + ma_shift * (p-1);
            t_ra = ra - (ma/gamma);
            t_ra = mod(t_ra,360);
            ma = mod(ma, 360);
            name_sat = stk_m_copysat(p,j,t_ra, ma, root);        
            root.ExecuteCommand("Cov */CoverageDefinition/Targets Asset */Satellite/"+name_sat+"/Sensor/Ant Assign");
        end
        root.ExecuteCommand("Unload / */Satellite/"+ref_name);
    end
    
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Asset */Satellite/"+name_sat+"/Sensor/Ant Assign");
            
    root.ExecuteCommand("New / */CoverageDefinition/Targets/FigureOfMerit Revisit");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets/FigureOfMerit/Revisit FOMDefine Definition CoverageTime Compute Percent");
    root.ExecuteCommand("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Animation off");
    root.ExecuteCommand("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Static off");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Access Compute");
    
    res = root.ExecuteCommand('Report_RM */CoverageDefinition/Targets/FigureOfMerit/Revisit Style "New Report"');
    data = res.Item(1);
    avg = split(data,',');
    avg = avg(1);
    f_val = str2double(avg);
    disp(f_val);
    f_val = f_val * -1;
end

function walker_command=generate_custom_walker(RefSatName, NumPlanes, NumSatPerPlane, InterPlanePhaseAngle, RAANSpace)
    walker_command = sprintf("Walker */Satellite/%s Type Custom NumPlanes %d NumSatsPerPlane %d InterPlaneTrueAnomalyIncrement %.1f RAANIncrement %.1f ColorByPlane No ConstellationName MyConst",RefSatName,NumPlanes, NumSatPerPlane, InterPlanePhaseAngle, RAANSpace);                             
    % walker_command = "Walker */Satellite/REF_1_ Type Custom NumPlanes 2 NumSatsPerPlane 2 InterPlanePhaseAngle 30.0 RAANSpacing 180.0 ColorByPlane No ConstellationName MyConst";                             
    % Walker */Satellite/Sat1 Type Custom NumPlanes 2 NumSatsPerPlane 2 InterPlaneTrueAnomalyIncrement 30.0 RAANIncrement 180.0 ColorByPlane No ConstellationName MyConst
end