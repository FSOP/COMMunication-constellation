function stk_m_remove(root)
    for j=1:1
        root.ExecuteCommand('UnloadMulti / */Facility/*');
        root.ExecuteCommand('UnloadMulti / */Satellite/*');
        root.ExecuteCommand('UnloadMulti / */Constellation/*');
        root.ExecuteCommand("UnloadMulti / */AreaTarget/*");
        root.ExecuteCommand("UnloadMulti / */CoverageDefinition/*");
    end
end