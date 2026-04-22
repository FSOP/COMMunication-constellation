function f_val = stk_main(x)
    rev_list = [160 161 162 163 164 166 167 168 169 170];
    addpath(genpath('..\0_Library'));
    
    root = init_stk();
    
    lon_ref = 127.0;
    lat_ref = 37.6;
    lat_t = 60.0;
    
    n = x(4);
    
    points = zeros(n,2);
    
    % step1. remove objects
    root.ExecuteCommand('SetAnalysisTimePeriod * "10 Jun 2022 03:00:00" "+11 days"');
    for j=1:1
        root.ExecuteCommand('UnloadMulti / */Facility/*');
        root.ExecuteCommand('UnloadMulti / */Satellite/*');
        root.ExecuteCommand("UnloadMulti / */AreaTarget/*");
        root.ExecuteCommand("UnloadMulti / */CoverageDefinition/*");
    end
    
    % step 2. add reference points as facility object
    int = 360 / n;
    name_ref = "T_";
    for p=1:n
        lon_t = lat_ref + int * (p-1);
        lon_t = mod(lon_t, 360);
        points(p,:) = [lat_t, lon_t];
    
        name_t = strcat(name_ref, int2str(p));
        comm = "SetPosition */Facility/<NAME> Geodetic <LAT> <LON> 0.0";
    
        root.ExecuteCommand("New / */Facility "+name_t);
        command = strrep(comm, "<NAME>", name_t);
        command = strrep(command, "<LAT>", num2str(lat_t,"%.2f"));
        command = strrep(command, "<LON>", num2str(lon_t,"%.2f"));
    
        %disp(command);
    
        root.ExecuteCommand(command);    
    end
    
    % step 3.
    name_sat = "ref_";
    inclination = x(1);
    raan = x(2);
    %gamma = x(3);
    gamma = rev_list(x(3));
    for p=1:1
        root.ExecuteCommand("New / */Satellite " + name_sat);
        root.ExecuteCommand("New / */Satellite/"+name_sat+"/Sensor SAR");
        root.ExecuteCommand("Define */Satellite/"+name_sat+"/Sensor/SAR SAR 55.0 75.0 89.0 89.0 TrackParentAltitude On");
        
        comm = "OrbitWizard */Satellite/"+name_sat+" RepeatingGroundTrace ApproxRevsPerDay 15 " + ...
            "Inclination <INCLINATION> RevsToRepeat <REV_TO_REPEAT> LongitudeFirstAn <LONGITUDE_ASC>";
        command = strrep(comm, "<INCLINATION>", num2str(inclination));
        command = strrep(command, "<REV_TO_REPEAT>", int2str(gamma));
        command = strrep(command, "<LONGITUDE_ASC>", num2str(raan));
        
        %disp(command);
        root.ExecuteCommand(command);
    end
    
    % step 4. Target 설정
    root.ExecuteCommand("New / */AreaTarget Targets");
    command = "SetBoundary */AreaTarget/Targets Pattern LatLon " + int2str(n);
    for p=1:n
        command = command + " " + num2str(points(p,1),"%.1f") +" "+ num2str(points(p,2),"%.1f");
    end
    %disp(command);
    root.ExecuteCommand(command);
    
    % step5. compute revisit time (coverage definition)
    for p=1:1
    
        root.ExecuteCommand("New / */CoverageDefinition Targets");
        root.ExecuteCommand("Cov */CoverageDefinition/Targets Access AutoRecompute off");

        root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid AreaOfInterest LatBounds -60 60");
        root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid PointGranularity LatLon 10");
        %root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid AreaOfInterest CustomBoundary AreaTarget AreaTarget/Targets");
        %root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid PointGranularity LatLon 5");
        
        root.ExecuteCommand("Cov */CoverageDefinition/Targets Asset */Satellite/"+name_sat+"/Sensor/SAR Assign");
        
        root.ExecuteCommand("New / */CoverageDefinition/Targets/FigureOfMerit Revisit");
        root.ExecuteCommand("Cov */CoverageDefinition/Targets/FigureOfMerit/Revisit FOMDefine Definition RevisitTime Compute Average");
        root.ExecuteCommand("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Animation off");
        root.ExecuteCommand("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Static off");
        
        root.ExecuteCommand("Cov */CoverageDefinition/Targets Access Compute");
    end
    
    % step6. calculate average revisit time
    res = root.ExecuteCommand('Report_RM */CoverageDefinition/Targets/FigureOfMerit/Revisit Style "New Report"');
    data = res.Item(1);
    avg = split(data,',');
    avg = avg(1);
    f_val = str2double(avg);
    disp(f_val);


%     command = "Cov_R */CoverageDefinition/Targets/FigureOfMerit/Revisit Inspector Point ";
%     res_val = zeros(1,n);
%     for p=1:n
%         command = command + num2str(points(p,1),"%.2f") + " " + num2str(points(p,2),"%.2f");
%         res = root.ExecuteCommand(command);
%         val = res.Item(0);
%         val = extractAfter(val, "Revisit Time is ");
%         val = extractBefore(val, "sec");
%         res_val(p) = str2double(val); 
%     end
%     f_val = mean(res_val);
%     disp(f_val);

end
