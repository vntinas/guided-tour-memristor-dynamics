classdef const
   properties (Constant)
        % Bounds used by your window:
        Ron  = 2000;
        Roff = 10000;

        % 2nd-order model params (Fig. 4 defaults):
        gamma = 1e5;      % [C^-1]
        tau   = 1e-3;     % [s]
        Vt    = 0.9;      % [V]
        yt    = 15e-3;    % [V]

        % Switches:
        useRelaxation  = 1;
        useSmoothTheta = 0;
        thetaK         = 20000;
   end
end
