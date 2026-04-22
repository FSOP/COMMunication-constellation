function comm=func_read_file(filepath)
    comm = {};
    fid = fopen(filepath, 'r', 'n', 'utf-8');

    %data = fread(fid);

    data = fgetl(fid);

    while ischar(data)
        if isempty(data)
            data = fgetl(fid);
            continue;
        end

        if data(1:1) == '%'
            data = fgetl(fid);
            continue;
        end


        comm = [comm, data];
        data = fgetl(fid);
    end

    fclose(fid);

end