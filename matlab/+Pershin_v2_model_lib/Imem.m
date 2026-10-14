function I_mem = Imem(V_m, M)
    import Pershin_v2_model_lib.const;

    % For the 2nd-order model, M is the state x (memristance).
    I_mem = V_m ./ M;
end