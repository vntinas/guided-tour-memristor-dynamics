function I_mem = Imem(V_m, w)
    import HP_model_lib.const;
    
    Mem = const.Ron*w/const.D + const.Roff*(1-w/const.D);
    I_mem = V_m/Mem;
end