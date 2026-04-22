function f_val=test_walker(x)
    addpath(genpath('..\0_Library'));
    
    analysis_epoch = "1 Jan 2022 03:00:00"; % Reference time in UTCG
    analysis_period = "+1 days";
    
    i = x(1);
    num_plane = x(2);
    sat_per_plane = x(3);
    inter_plane = x(4);
    altitude = 600000; % meter
    
    root = init_stk();
    
    root.ExecuteCommand(strcat('SetAnalysisTimePeriod * "',analysis_epoch,'" "+1 day"'));
    
    stk_m_remove(root);
    
    root.ExecuteCommand("New / */AreaTarget Targets");
    root.ExecuteCommand("SetPosition */AreaTarget/Targets Geodetic 37.6 127.0 0");
    root.ExecuteCommand("SetBoundary */AreaTarget/Targets Ellipse 1000000 1000000 0");
    
    root.ExecuteCommand("New / */CoverageDefinition Targets");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Access AutoRecompute off");
    
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid AreaOfInterest Custom AreaTarget AreaTarget/Targets");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid PointGranularity LatLon 5");

    ref_name = stk_simple_sat("SAT_",0,i,altitude,root);
    root.ExecuteCommand("Graphics */Satellite/"+ref_name+ " Pass2D GrndLead None");
    root.ExecuteCommand("Graphics */Satellite/"+ref_name+ " Pass2D OrbitLead None");
    root.ExecuteCommand("VO */Satellite/"+ref_name + " Pass3D Inherit On");
    
    command = "Walker */Satellite/"+ref_name+" Type Delta NumPlanes <num_plane> NumSatsPerPlane <sat_per_plane> InterPlanePhaseIncrement <f> ColorByPlane Yes";

    comm = strrep(command, "<num_plane>", int2str(num_plane));
    comm = strrep(comm, "<sat_per_plane>", int2str(sat_per_plane));
    comm = strrep(comm, "<f>", int2str(inter_plane));

    root.ExecuteCommand(char(comm));

    format_plane = floor(log10(num_plane))+1;
    format_plane = "%0"+int2str(format_plane)+"d";
    format_sat = floor(log10(sat_per_plane))+1;
    format_sat = "%0"+int2str(format_sat)+"d";

    for p=1:num_plane
        for j=1:sat_per_plane
            plane_part = num2str(p,format_plane);
            sat_part = num2str(j, format_sat);
            o_name = strcat(ref_name,plane_part,sat_part);            
            root.ExecuteCommand("Cov */CoverageDefinition/Targets Asset */Satellite/"+o_name+"/Sensor/Ant Assign");
        end
    end

        
    root.ExecuteCommand("New / */CoverageDefinition/Targets/FigureOfMerit Revisit");
    root.ExecuteCommand("Cov */CoverageDefinition/Targets/FigureOfMerit/Revisit FOMDefine Definition CoverageTime Compute Percent");
    root.ExecuteCommand("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Animation off");
    root.ExecuteCommand("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Static off");
    %root.ExecuteCommand("Cov */CoverageDefinition/Targets Access Compute");
    
    res = root.ExecuteCommand('Report_RM */CoverageDefinition/Targets/FigureOfMerit/Revisit Style "New Report"');
    data = res.Item(1);
    avg = split(data,',');
    avg = avg(1);
    f_val = str2double(avg);
    disp(f_val);
    f_val = f_val * -1;
end

