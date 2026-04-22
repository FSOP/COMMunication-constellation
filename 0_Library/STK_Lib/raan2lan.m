function lan=raan2lan(raan)
    global diff;

    lan = mod(raan-diff, 360);
end