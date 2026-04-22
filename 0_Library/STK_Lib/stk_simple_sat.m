function name=stk_simple_sat(t_num, ra, incli, altitude, root)
    name = strrep("REF_<tnum>_", "<tnum>", t_num);
    comms = ["New / */Satellite <name>",
             "New / */Satellite/<name>/Sensor Ant",
             "Define */Satellite/<name>/Sensor/Ant SimpleCone 44",
             "OrbitWizard */Satellite/<name> Circular Inclination <INCLINATION> Altitude <ALTITUDE> RAAN <RAAN>"
            ];
    
    for p=1:length(comms)
        command = strrep(comms(p), "<name>", name);
        command = strrep(command, '<INCLINATION>', num2str(incli));
        command = strrep(command, '<ALTITUDE>', int2str(altitude));
        command = strrep(command, '<RAAN>', num2str(ra));
        
        %disp(command);
        root.ExecuteCommand(char(command));
    end
end