function dx_dt = dxdt(V_m, I_m, x, win)
    import WeiLu_model_lib.const;


    if ~isempty(V_m)
        % Calculate I_mem
        % I_mem = WeiLu_model_lib.Imem(V_m, x);
    else
        options = optimoptions('fsolve','FunctionTolerance',1e-16,'OptimalityTolerance',1e-16,'StepTolerance',1e-16,'MaxIterations',2000,'Display','off');
        V_m = fsolve(@(V) I_m - WeiLu_model_lib.Imem(V, x),sign(I_m)*2,options);
        % I_mem = I_m;
    end

    % gamma0 = (V_m>=0).* const.gamma0_SET + (V_m<0).* const.gamma0_RESET;
    % beta = (V_m>=0).* const.beta_SET + (V_m<0).* const.beta_RESET;
    % 
    % T = const.T0 + V_m .* I_mem * const.Rth;
    % gamma = gamma0 - beta.* (x/1e-9) .^const.alpha;
    % 
    % dx_dt = -const.u0 .* exp(-const.q.*const.Ea/const.kb./T) .* sinh(gamma.*const.a0./const.tOX.*const.q.*V_m./const.kb./T);
    if win
        window = min((V_m>=0).*(x<=1) + (V_m<0).*(x>=0),1);
    else
        window = 1.0;
    end
    dx_dt = window.*const.lambda .* (exp(const.eta1.*V_m)-exp(-const.eta2.*V_m)) - x./const.tau;

    % Add decay term
    if win && x==1 && dx_dt>0
        dx_dt = 0;
    elseif win && x==0 && dx_dt<0
        dx_dt = 0;
    end
end