function dX_dt = dMdt(V_m, I_m, X)
    % 2nd-order Pershin–Di Ventra model (eqs. 6–8) + your 1st-order window on x
    %
    % States:
    %   X(1) = x  (memristance) [Ohm]
    %   X(2) = y  (timing/trace variable) [V]
    %
    % Port equation:
    %   I = V_m / x
    %
    % Inputs (same convention as your 1st order):
    %   V_m : memristor voltage (can be empty)
    %   I_m : memristor current (used if V_m is empty)
    %   X   : [x; y]
    %
    % Output:
    %   dX_dt : [xdot; ydot]

    import Pershin_v2_model_lib.const;

    x = X(1);
    y = X(2);

    % If V_m not provided, infer it like in your 1st-order code
    if isempty(V_m)
        V_m = I_m .* x;
    end

    % -----------------------------
    % Your EXACT window (same logic)
    % -----------------------------
    % Allows x to decrease only when V_m > 0 and x > Ron
    % Allows x to increase only when V_m < 0 and x < Roff
    f_window = 1*(V_m>0)*(const.Ron < x) + 1*(V_m<0)*(x < const.Roff);
    % f_window = 1;
    % -----------------------------
    % Pershin–Di Ventra gating terms
    % -----------------------------
    Vtil = V_m / const.Vt;
    ytil = y   / const.yt;

    th = @(z) theta_fun(z);

    % xdot gate (eq. 7)
    % Gate of Eq. (7) of Pershin and Di Ventra, Proc. IEEE 100, 2071 (2012):
    % the memristance changes only when the input and the previously
    % excited trace y share the same sign, which requires a pair of
    % opposite-polarity pulses (STDP).
    gx = th(Vtil - 1)  * th(ytil - 1) + ...
         th(-Vtil - 1) * th(-ytil - 1);

    % if abs(gx)>0
    %     opa = 3;
    % end

    % Apply your window to xdot so x stays within [Ron, Roff]
    % Sign flipped with respect to the original so that positive inputs drive
    % the device toward the LRS, as in all other models of this work.
    xdot = -const.gamma * gx * y * f_window;

    % ydot (eq. 8)
    term1 = -V_m * th(Vtil - 1)  * th(1 - ytil);
    term2 = -V_m * th(-Vtil - 1) * th(ytil + 1);

    if const.useRelaxation == 1
        ydot = (1/const.tau) * (term1 + term2 - y);
    else
        % Your "no-relaxation first" analysis regime
        ydot = (1/const.tau) * (term1 + term2);
    end

    % if abs(xdot)>0
    %     opa = 3;
    % end

    dX_dt = [xdot; ydot];
end

% ------- local theta helper -------
function val = theta_fun(z)
    import Pershin_v2_model_lib.const;

    if const.useSmoothTheta == 0
        val = double(z >= 0);
    else
        val = 1 ./ (1 + exp(-const.thetaK * z));
    end
end