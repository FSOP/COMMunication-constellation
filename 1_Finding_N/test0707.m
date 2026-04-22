function f_val = test0707(x)
    addpath(genpath('..\0_Library'));    
    
    root = init_stk();    
    
    data = root.ExecuteCommand("AllInstanceNames /");
    
    res = data.Item(0);
    
    f_val = count(res,'Satellite');
    f_val = f_val / 2;
    disp(f_val);
end