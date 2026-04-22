function log_stk(fname, data)
    
    fid = fopen(fname, 'a', 'n', 'utf-8');
    fprintf(fid,'%s %s\n',datetime(), data);
    fclose(fid);


end

