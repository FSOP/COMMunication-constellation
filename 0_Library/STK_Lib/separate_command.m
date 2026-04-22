function [pre_comm, main_comm, post_comm]=separate_command(comm)
    pre_comm = {};
    main_comm = {};
    post_comm = {};
    
    for i=1:length(comm)
        % display(char(comm(i)));
        %if char(comm(i)) == '## PRE STEP END ##'
        idx_main_step = -1;
        if strcmp(char(comm(i)), '## PRE STEP END ##')
            pre_comm = comm(2:i-1);
            idx_pre_step = i+1;
        end
        if strcmp(char(comm(i)), '## MAIN STEP END ##')
            main_comm = comm(idx_pre_step:i-1);
            idx_main_step = i+1;
        end
        if idx_main_step ~= -1
            post_comm = comm(idx_main_step:length(comm));
            break;
        end
    end

end
