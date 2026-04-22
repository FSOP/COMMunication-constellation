function ra=lan2raan(la)        
    global diff;
    
    ra = mod(la + diff,360);    
end

