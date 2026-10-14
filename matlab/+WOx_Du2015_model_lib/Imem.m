function I_mem = Imem(V_m, X, p)
%IMEM  WOx memristor port equation (Eq. S1).
%
% Inputs:
%   V_m : memristor voltage
%   X   : [wm; wc]
%   p   : parameter struct (optional). If omitted, uses const.params().
%
% Output:
%   I_mem : memristor current
    import WOx_Du2015_model_lib.const;
    if nargin < 3 || isempty(p)
        p = const.params("Fig3b");
    end

    wc = X(2);

    % Eq. S1:
    % I = (1-wc)*alpha*(1-exp(-beta*V)) + wc*gamma*sinh(kappa*V)
    I_mem = (1-wc) * p.alpha * (1 - exp(-p.beta * V_m)) + ...
            (wc)   * p.gamma * sinh( clip(p.kappa * V_m, -p.sinhClip, p.sinhClip) );
end

% ---- local clip helper ----
function y = clip(x, lo, hi)
    y = min(max(x, lo), hi);
end
