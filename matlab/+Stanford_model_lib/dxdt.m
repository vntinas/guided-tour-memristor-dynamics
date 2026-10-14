function dx_dt = dxdt(V_m, I_m, x)
    import Stanford_model_lib.const;


    if ~isempty(V_m)
        % Calculate I_mem
        I_mem = Stanford_model_lib.Imem(V_m, x);
    else
        options = optimoptions('fsolve','FunctionTolerance',1e-16,'OptimalityTolerance',1e-16,'StepTolerance',1e-16,'MaxIterations',2000,'Display','off');
        V_m = fsolve(@(V) I_m - Stanford_model_lib.Imem(V, x),sign(I_m)*2,options);
        I_mem = I_m;
    end

    gamma0 = (V_m>=0).* const.gamma0_SET + (V_m<0).* const.gamma0_RESET;
    beta = (V_m>=0).* const.beta_SET + (V_m<0).* const.beta_RESET;

    T = const.T0 + V_m .* I_mem * const.Rth;
    gamma = gamma0 - beta.* (x/1e-9) .^const.alpha;

    dx_dt = -const.u0 .* exp(-const.q.*const.Ea/const.kb./T) .* sinh(gamma.*const.a0./const.tOX.*const.q.*V_m./const.kb./T);
end