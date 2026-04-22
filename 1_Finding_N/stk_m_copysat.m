function sat_name=stk_m_copysat(p, j, raan, anomaly, root)
    ref_sat_name = strrep("REF_<tname>_","<tname>", int2str(p));
    sat_name = strrep("SAT_<p>_<j>", "<p>", int2str(p));
    sat_name = strrep(sat_name, "<j>", int2str(j));

    root.ExecuteCommand(strcat("Copy / */Satellite/", ref_sat_name," Name ", sat_name));
    root.ExecuteCommand(strcat("Rename */Satellite/",sat_name,"/Sensor/Ant1 Ant"));
        
    % 3) adjust children satellites True Anomaly & LAN
    sat = root.CurrentScenario.Children.Item(sat_name);
    keplerian = sat.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical');
    keplerian.Orientation.AscNodeType = 'eAscNodeRAAN';
    keplerian.Orientation.AscNode.Value = raan; 
    % keplerian.Location.Value = 60;
    keplerian.Location.Value = anomaly;    
    sat.Propagator.InitialState.Representation.Assign(keplerian);
    sat.Propagator.Propagate();
end