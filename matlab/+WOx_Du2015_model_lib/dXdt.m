function dX_dt = dXdt(V_m, I_m, X, p)
%DXDT  WOx memristor dynamics (Eqs. S2-S6).
%
% States:
%   X(1) = wm
%   X(2) = wc
%
% Inputs:
%   V_m : memristor voltage (can be empty)
%   I_m : memristor current (used if V_m is empty)
%   X   : [wm; wc]
%   p   : parameter struct (optional)
%
% Output:
%   dX_dt : [dwm/dt; dwc/dt]
    import WOx_Du2015_model_lib.const;
    if nargin < 4 || isempty(p)
        p = const.params("Fig3b");
    end

    wm = X(1);
    wc = X(2);

    % Infer V if not provided (nonlinear solve)
    if isempty(V_m)
        if isempty(I_m) || ~p.allowInferVFromI
            error("Provide V_m or enable allowInferVFromI with I_m.");
        end
        V_m = inferVfromI(I_m, X, p);
    end

    if isnan(V_m)
        dX_dt = [NaN; NaN];
        return
    end

    % -------------------------
    % Window functions W(w,V) (Eq. S6)
    % -------------------------
    Wm = windowW(wm, V_m, p);
    Wc = windowW(wc, V_m, p);

    % if wm==0 && wc==0
    %     Wm = 0;
    %     Wc = 0;
    % end

    % -------------------------
    % Effective decay time constants (Eqs. S4-S5)
    % 1/tau_m*(wm) = wm/tau_s
    % 1/tau_c*(wm) = 1/tau_l + sigma*wm/tau_s
    % -------------------------
    inv_tau_m = wm / p.tau_s;
    inv_tau_c = (1/p.tau_l) + (p.sigma * wm / p.tau_s);

    % -------------------------
    % Programming / stimulation terms (Eqs. S2-S3)
    % -------------------------
    arg_m = clip(p.rho_m * abs(V_m), -p.sinhClip, p.sinhClip);
    arg_c = clip(p.rho_c * V_m,       -p.sinhClip, p.sinhClip);

    stim_m = p.lambda_m * Wm * sinh(arg_m);

    % exp(epsilon*wm) factor (clip exponent for stability)
    exp_arg = clip(p.epsilon * wm, -p.expClip, p.expClip);
    stim_c  = p.lambda_c * Wc * exp(exp_arg) * sinh(arg_c);

    % -------------------------
    % Decay terms (Eqs. S2-S3)
    % -------------------------
    decay_m = (wm - p.wm0) * inv_tau_m;
    decay_c = (wc - p.wc0) * inv_tau_c;

    % Final dynamics
    dwm = stim_m - decay_m;
    dwc = stim_c - decay_c;

    dX_dt = [dwm; dwc];
end

% =========================================================
% Window function W(w,V) (Eq. S6) — matches LTspice trunc1/2
% =========================================================
function W = windowW(w, V, p)
    % Hard/smooth sign-based selection:
    if p.useSmoothSign == 0
        s_posV = double(V >= 0);
        s_negV = double(V <  0);
        s_wmax = double((p.wmax - w) >= 0);
        s_wmin = double((w - p.wmin) >= 0);
    else
        % smooth approximations
        s_posV = smoothStep(V, p.smoothK);
        s_negV = 1 - s_posV;
        s_wmax = smoothStep(p.wmax - w, p.smoothK);
        s_wmin = smoothStep(w - p.wmin, p.smoothK);
    end

    if V >= 0
        % 1 - exp(-(wmax - w)/eps)
        Wcore = 1 - exp(-(p.wmax - w)/p.w_eps);
        W = s_posV * s_wmax * Wcore;
    else
        % 1 - exp(-(w - wmin)/eps)
        Wcore = 1 - exp(-(w - p.wmin)/p.w_eps);
        W = s_negV * s_wmin * Wcore;
    end

    % Guard numeric range
    W = min(max(W, 0), 1);
end

function y = smoothStep(z, k)
    % logistic smooth Heaviside
    y = 1 ./ (1 + exp(-k * z));
end

function y = clip(x, lo, hi)
    y = min(max(x, lo), hi);
end

% =========================================================
% Nonlinear inversion V from I (if V_m is empty)
% Solve: Imem(V,X) - I = 0
% =========================================================
function V = inferVfromI(I_target, X, p)
    f = @(V) WOx_Du2015_model_lib.Imem(V, X, p) - I_target;

    % Bracket search (expand until sign change)
    a = -p.inferV_Bracket;
    b =  p.inferV_Bracket;

    fa = f(a);
    fb = f(b);

    expand = 0;
    while sign(fa) == sign(fb) && expand < p.inferV_MaxExpand
        a = 2*a; b = 2*b;
        fa = f(a); fb = f(b);
        expand = expand + 1;
    end

    if sign(fa) == sign(fb)
        % Fallback: try fzero with initial guess 0
        V = fzero(f, 0);
        return;
    end

    % Root in [a,b]
    V = fzero(f, [a b]);
end
