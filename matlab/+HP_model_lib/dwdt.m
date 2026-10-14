function dw_dt = dwdt(V_m, I_m, w, p)
    import HP_model_lib.const;
    x = w/const.D;
    % f_window = 1 - (2*x-1).^(2*p);
    % j = 1;
    % f_window = j*(1 - ((x - 0.5).^2 + 0.75).^p);
    if isempty(V_m)
        stp = 1*(-I_m>=0);
        f_window = 1 - (x-stp).^(2*p);
        dw_dt = const.mu*const.Ron/const.D*I_m.*f_window;
    else
        stp = 1*(-V_m>=0);
        f_window = 1 - (x-stp).^(2*p);
        dw_dt = const.mu*const.Ron/const.D*HP_model_lib.Imem(V_m,w).*f_window;
    end
end