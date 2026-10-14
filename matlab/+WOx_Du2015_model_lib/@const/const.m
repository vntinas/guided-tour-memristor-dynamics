classdef const
    properties (Constant)
        % -------------------------
        % Table S1 (fixed defaults)
        % -------------------------
        alpha   = 1.5e-6;
        beta    = 4;
        gamma   = 3.2e-6;
        kappa   = 5;

        lambda_m = 1e-6;
        lambda_c = 1e-6;

        tau_s   = 0.0025;
        tau_l   = 298;

        epsilon = 15;
        sigma   = 0.25;

        % Bounds for states
        wmin = 0;
        wmax = 1;

        % Window sharpness (Eq. S6 uses 0.0001)
        w_eps = 1e-4;

        % Initial wm0 (paper states fixed near 0)
        wm0 = 0.001;

        % -------------------------
        % Numeric safety switches
        % -------------------------
        useSmoothSign = 0;   % 0: hard sign/step, 1: smooth
        smoothK       = 2e4; % slope for smooth step/sign

        expClip  = 60;       % clip arguments to exp()
        sinhClip = 60;       % clip arguments to sinh()

        % If you allow V inference from I when V is empty:
        allowInferVFromI = 1;
        inferV_Bracket   = 2.0;   % initial bracket half-width (V)
        inferV_MaxExpand = 10;    % how many times to expand bracket
    end

    methods (Static)
        function p = params(caseName)
            %PARAMS Return parameter struct, including Table S2 selections.

            if nargin < 1 || strlength(string(caseName))==0
                caseName = "Fig3b";
            end
            caseName = string(caseName);

            % Start from constants
            p.alpha    = WOx_Du2015_model_lib.const.alpha;
            p.beta     = WOx_Du2015_model_lib.const.beta;
            p.gamma    = WOx_Du2015_model_lib.const.gamma;
            p.kappa    = WOx_Du2015_model_lib.const.kappa;

            p.lambda_m = WOx_Du2015_model_lib.const.lambda_m;
            p.lambda_c = WOx_Du2015_model_lib.const.lambda_c;

            p.tau_s    = WOx_Du2015_model_lib.const.tau_s;
            p.tau_l    = WOx_Du2015_model_lib.const.tau_l;

            p.epsilon  = WOx_Du2015_model_lib.const.epsilon;
            p.sigma    = WOx_Du2015_model_lib.const.sigma;

            p.wmin     = WOx_Du2015_model_lib.const.wmin;
            p.wmax     = WOx_Du2015_model_lib.const.wmax;
            p.w_eps    = WOx_Du2015_model_lib.const.w_eps;
            p.wm0      = WOx_Du2015_model_lib.const.wm0;

            p.useSmoothSign = WOx_Du2015_model_lib.const.useSmoothSign;
            p.smoothK       = WOx_Du2015_model_lib.const.smoothK;

            p.expClip  = WOx_Du2015_model_lib.const.expClip;
            p.sinhClip = WOx_Du2015_model_lib.const.sinhClip;

            p.allowInferVFromI = WOx_Du2015_model_lib.const.allowInferVFromI;
            p.inferV_Bracket   = WOx_Du2015_model_lib.const.inferV_Bracket;
            p.inferV_MaxExpand = WOx_Du2015_model_lib.const.inferV_MaxExpand;

            % -------------------------
            % Table S2 selections
            % -------------------------
            switch lower(caseName)
                case {"fig2c","2c"}
                    p.rho_m = 15.8; p.rho_c = 14.2; p.wc0 = 0;
                case {"fig2d","2d"}
                    p.rho_m = 13;   p.rho_c = 13;   p.wc0 = 0.05;
                case {"fig3b","3b"}
                    p.rho_m = 17;   p.rho_c = 14.5; p.wc0 = 0.001;
                case {"fig3c","3c"}
                    p.rho_m = 15;   p.rho_c = 12.5; p.wc0 = 0.02;
                case {"fig3d","3d"}
                    p.rho_m = 14.5; p.rho_c = 12;   p.wc0 = 0.1;
                case {"fig4a","4a"}
                    p.rho_m = 16.4; p.rho_c = 14.4; p.wc0 = 0.001;
                case {"fig5b","5b"}
                    p.rho_m = 17.9; p.rho_c = 15.8; p.wc0 = 0.3;
                otherwise
                    error("Unknown caseName '%s'. Use e.g. 'Fig3b', 'Fig2c', ...", caseName);
            end

            % Initial condition vector
            p.X0 = [p.wm0; p.wc0];
        end
    end
end
