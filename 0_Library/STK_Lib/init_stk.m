function root =init_stk()
    try
        % Grab an existing instance of STK
        uiapp = actxGetRunningServer('STK12.application');
        root = uiapp.Personality2;
        checkempty = root.Children.Count;
        if checkempty == 0
            %If a Scenario is not open, create a new scenario
            uiapp.visible = 1;
            root.NewScenario('Using_MATLAB_Automation');
            scenario = root.CurrentScenario;
        end

    catch
        % STK is not running, launch new instance
        % Launch a new instance of STK12 and grab it
        uiapp = actxserver('STK12.application');
        root = uiapp.Personality2;
        uiapp.visible = 1;
        root.NewScenario('Using_MATLAB_Automation');
        scenario = root.CurrentScenario;
    end
end