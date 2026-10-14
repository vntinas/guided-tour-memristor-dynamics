function I_mem = Imem(V_m, x)
    import WeiLu_model_lib.const;
    
    % I_mem = const.I0.*exp(-x./const.g0).*sinh(V_m./const.V0);
    I_mem = (1-x).*const.alpha.*(1-exp(-const.beta.*V_m)) + x.*const.gamma.*sinh(const.delta.*V_m);
end