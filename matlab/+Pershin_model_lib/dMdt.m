function dM_dt = dMdt(V_m, I_m, M)
    import Pershin_model_lib.const;

    % f_window = 1 - (2*x-1).^(2*p);
    % j = 1;
    % f_window = j*(1 - ((x - 0.5).^2 + 0.75).^p);
    
    if isempty(V_m)
        V_m = I_m.*M;
        f_window = 1*(V_m>0)*(const.Ron<M) + 1*(V_m<0)*(M<const.Roff); 
        dM_dt = -(const.beta.*V_m + 0.5*(const.alpha-const.beta).*(abs(V_m+const.Vt)-abs(V_m-const.Vt))).*f_window;
    else
        f_window = 1*(V_m>0)*(const.Ron<M) + 1*(V_m<0)*(M<const.Roff); 
        dM_dt = -(const.beta.*V_m + 0.5*(const.alpha-const.beta).*(abs(V_m+const.Vt)-abs(V_m-const.Vt))).*f_window;
    end
end