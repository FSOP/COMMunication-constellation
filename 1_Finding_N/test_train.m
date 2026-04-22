function f_val=test_train(x)
    addpath(genpath('..\0_Library'));
    
    analysis_epoch = "1 Jan 2022 03:00:00"; % Reference time in UTCG
    analysis_period = "+1 days";
    
    global diff;
    lan = 8;
    raan = 153.75; % Coordination System TrueOfDate
    diff = raan - lan;
    
    %ma_list = [10 29 45 59 70 81 100 110 121.5 134.5 151 170 190 209 225 239 250 260 280 290 302 315 331 350];
    ma_list = 0:15:360-15
    
    i = 35;
    ra_space = 360/14;
    %ma_interval = 14; % deg
    ma_shift = 10;

%     i = x(1);
%     ra_space = x(2);
%     ma_interval = x(3);
%     ma_shift = x(4);
    
    lan = 0;
    la_list = lan:ra_space:lan+360;
    
    %raan = lan2raan(lan);
    ma_init = 0;
    
    rev_to_repeat = 14;
    
    
    %ra_interval = (360 / rev_to_repeat) * ra_space;
    
    %raan_list = raan:ra_space:raan+360;
    %la_list = lan:ra_interval:lan+360;
    %ma_list = ma_init:ma_interval:ma_init+360;
    
    
    
    root = init_stk();
    
    root.ExecuteCommand(strcat('SetAnalysisTimePeriod * "',analysis_epoch,'" "+1 day"'));
    
    stk_m_remove(root);
    
    root.ExecuteCommand("New / */AreaTarget Targets");
    root.ExecuteCommand("SetPosition */AreaTarget/Targets Geodetic 37.6 127.0 0");
    root.ExecuteCommand("SetBoundary */AreaTarget/Targets Ellipse 2000000 2000000 0");
    
    root.ExecuteCommand("New / */CoverageDefinition Targets");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Access AutoRecompute off");
    
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid AreaOfInterest Custom AreaTarget AreaTarget/Targets");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid PointGranularity LatLon 5");
    
    %for p=1:length(la_list)-1
    for p=1:1
        %ra = lan + (plane_interval * (p-1));    
        la = la_list(p);
        ra = lan2raan(la);
        %ra = lan2raan(ra);
        
        ref_name = stk_m_refsat(int2str(p),la,i,rev_to_repeat,root);
    
        for j=1:length(ma_list)
            ma = ma_list(j);
            ma = ma + ma_shift * (p-1);
            t_ra = ra - (ma/14);
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

