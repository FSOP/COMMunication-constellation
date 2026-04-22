function name=stk_m_refsat(t_num, lan, incli, rev_to_repeat, root)
    name = strrep("REF_<tnum>_", "<tnum>", t_num);
    comms = ["New / */Satellite <name>",
             "New / */Satellite/<name>/Sensor Ant",
             "Define */Satellite/<name>/Sensor/Ant SimpleCone 44",
             "OrbitWizard */Satellite/<name> RepeatingGroundTrace ApproxRevsPerDay 14.6 Inclination <INCLINATION> RevsToRepeat <REV_TO_REPEAT> LongitudeFirstAn <LONGITUDE_ASC>"
            ];
    
    for p=1:length(comms)
        command = strrep(comms(p), "<name>", name);
        command = strrep(command, '<INCLINATION>', num2str(incli));
        command = strrep(command, '<REV_TO_REPEAT>', int2str(rev_to_repeat));
        command = strrep(command, '<LONGITUDE_ASC>', num2str(lan));
        
        %disp(command);
        root.ExecuteCommand(char(command));
    end
end