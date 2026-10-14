function M = Mem(V_m,I_m, w)
    import HP_model_lib.const;
    
    M = const.Ron*w/const.D + const.Roff*(1-w/const.D);
end