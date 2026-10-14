function I_mem = Imem(V_m, x)
    import Stanford_model_lib.const;
    
    I_mem = const.I0.*exp(-x./const.g0).*sinh(V_m./const.V0);
end