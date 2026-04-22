
addpath(genpath('..\0_Library'));

analysis_epoch = "1 Jan 2022 03:00:00"; % Reference time in UTCG
analysis_period = "+11 days";

global diff;
lan = 8;
raan = 153.75; % Coordination System TrueOfDate
diff = raan - lan;


i = 60;
lan = 7.52;
raan = lan2raan(lan);

nodal_day = 33;
rev_to_repeat = 494;

number_of_plane = 4;
sat_per_plane = 5;

plane_interval = 360 / number_of_plane;
raan_array = raan:360/rev_to_repeat:raan+360;

root = init_stk();
root.ExecuteCommand(strcat('SetAnalysisTimePeriod * "',analysis_epoch,'" "+11 day"'));

stk_m_remove(root);
root.ExecuteCommand("New / */CoverageDefinition Targets");
root.ExecuteCommand("Cov */CoverageDefinition/Targets Access AutoRecompute off");

root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid AreaOfInterest LatBounds -60 60");
root.ExecuteCommand("Cov */CoverageDefinition/Targets Grid PointGranularity LatLon 10");


s = "<raan> <anomaly> <plane>:<sat>";

for p=1:number_of_plane
    ra = raan + (plane_interval * (p-1));
    ra = mod(find_raan(raan_array, ra),360);    
    la = raan2lan(ra);
    ma_slot = (0:(nodal_day-1)) * (360 / nodal_day);    
    
    ref_name = stk_m_refsat(int2str(p),la,i,rev_to_repeat,root);

    for j=1:sat_per_plane
        ma = (j-1) * (360/sat_per_plane);
        ma = find_raan(ma_slot, ma);
        d = strrep(s, "<raan>", num2str(ra));
        d = strrep(d, "<anomaly>", num2str(ma));
        d = strrep(d, "<plane>", num2str(p));
        d = strrep(d, "<sat>", num2str(p*j));
        
        disp(d);        
        name_sat = stk_m_copysat(p,j,ra, ma, root);
        root.ExecuteCommand("Cov */CoverageDefinition/Targets Asset */Satellite/"+name_sat+"/Sensor/SAR Assign");
    end
    root.ExecuteCommand("Unload / */Satellite/"+ref_name);
end

root.ExecuteCommand("New / */CoverageDefinition/Targets/FigureOfMerit Revisit");
root.ExecuteCommand("Cov */CoverageDefinition/Targets/FigureOfMerit/Revisit FOMDefine Definition RevisitTime Compute Average");
root.ExecuteCommand("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Animation off");
root.ExecuteCommand("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Static off");
        
root.ExecuteCommand("Cov */CoverageDefinition/Targets Access Compute");
res = root.ExecuteCommand('Report_RM */CoverageDefinition/Targets/FigureOfMerit/Revisit Style "New Report"');
data = res.Item(1);
avg = split(data,',');
avg = avg(1);
f_val = str2double(avg);
disp(f_val);


function r_val = find_raan(array, value)
   idx = find(abs(array-value)==min(abs(array-value)));
   r_val = array(idx(1));
end

