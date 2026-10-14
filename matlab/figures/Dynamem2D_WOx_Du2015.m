clear;
clc;
close all;

% Temporary default font sizes for this script
set(groot, 'defaultAxesFontSize', 18);
set(groot, 'defaultTextFontSize', 18);
set(groot, 'defaultLegendFontSize', 18);
set(groot, 'defaultColorbarFontSize', 18);

import WOx_Du2015_model_lib.const;

%% ================================
%  SETTINGS
% ================================
mode = "V";
% mode = "I";
V_m = -1000e-3;                 % fixed bias for vector field
I_m = -.45e-3;                 % fixed bias for vector field
% V_m = 0;
caseName = "Fig3b";       % Table S2 selection: Fig2c, Fig2d, Fig3b, Fig3c, Fig3d, Fig4a, Fig5b

points_x_y = 101;         % grid density (101/201/301 typical)

p = const.params(caseName);

% State ranges (both are nominally in [0,1])
wm = linspace(p.wmin, p.wmax, points_x_y);
wc = linspace(p.wmin, p.wmax, points_x_y);

[WM_grid, WC_grid] = meshgrid(wm, wc);

dwm_grid = zeros(size(WM_grid));
dwc_grid = zeros(size(WC_grid));

%% ================================
%  COMPUTE VECTOR FIELD ON GRID
% ================================
for i = 1:numel(WM_grid)
    X = [WM_grid(i); WC_grid(i)];
    % dX = WOx_Du2015_model_lib.dXdt(V_m, [], X, p);
    dX = rhs_WOx(1, X, mode, V_m, I_m, p); % Note: 1st argument is "t"
    dwm_grid(i) = dX(1);
    dwc_grid(i) = dX(2);
end

magnitude = sqrt(dwm_grid.^2 + dwc_grid.^2);
magnitude = log10(magnitude);

%% ================================
%  FIGURE SETUP (similar style)
% ================================
fig = figure();
fig.NumberTitle = "off";
fig.Name = 'WOx Du2015 | Dynamics';
fig.Color = 'w';
fig.Position(1:2) = [50 800];
fig.Position(3:4) = 520*[1.13 0.9];

% Colormap (same logic as your script)
if exist('colormap_temp.csv', 'file')
    custom_colormap = readmatrix('colormap.csv');
else
    warning('Custom colormap file not found. Using default colormap.');
    custom_colormap = parula(256);
end
lighter_color_range = 92:164;
lighter_colormap = custom_colormap(lighter_color_range, :);
colormap(lighter_colormap);

%% ================================
%  SCALE GRID TO [0,1]x[0,1]
% ================================
min_x = min(wm); max_x = max(wm); x_range = max_x - min_x;
min_y = min(wc); max_y = max(wc); y_range = max_y - min_y;

WM_scaled = (WM_grid - min_x) / x_range;
WC_scaled = (WC_grid - min_y) / y_range;

%% ================================
%  COARSE GRID FOR QUIVER
% ================================
num_coarse_points = 17;

indices_x = round(linspace(1, length(wm), num_coarse_points));
indices_y = round(linspace(1, length(wc), num_coarse_points));
indices_x(1)=1; indices_x(end)=length(wm);
indices_y(1)=1; indices_y(end)=length(wc);

wm_coarse = wm(indices_x);
wc_coarse = wc(indices_y);

wm_scaled_coarse = (wm_coarse - min_x) / x_range;
wc_scaled_coarse = (wc_coarse - min_y) / y_range;

[WM_scaled_coarse_grid, WC_scaled_coarse_grid] = meshgrid(wm_scaled_coarse, wc_scaled_coarse);

du = abs(wm_scaled_coarse(2) - wm_scaled_coarse(1)) / 2;
dv = abs(wc_scaled_coarse(2) - wc_scaled_coarse(1)) / 2;

% Note: meshgrid orientation => rows correspond to wc, cols to wm
dwm_grid_coarse = dwm_grid(indices_y, indices_x);
dwc_grid_coarse = dwc_grid(indices_y, indices_x);

angles_coarse = atan2(dwc_grid_coarse, dwm_grid_coarse);
magnitudes_coarse = sqrt(dwc_grid_coarse.^2 + dwm_grid_coarse.^2);

% Log-scale magnitudes for visualization (avoid inf)
magnitudes_coarse = log10(magnitudes_coarse);
magnitudes_coarse_safe = magnitudes_coarse(isfinite(magnitudes_coarse));
min_magn = min(magnitudes_coarse_safe,[],'all');
max_magn = max(magnitudes_coarse_safe,[],'all');
magnitudes_coarse = (magnitudes_coarse - min_magn) / (max_magn - min_magn);

u = cos(angles_coarse) * du .* magnitudes_coarse;
v = sin(angles_coarse) * dv .* magnitudes_coarse;

%% ================================
%  PLOT BACKGROUND + QUIVER
% ================================
contourf(WM_scaled, WC_scaled, magnitude, 64, ...
    'LineColor', 'none', 'HandleVisibility', 'off');
cb = colorbar; %#ok<NASGU>
hold on;

h = quiver(wm_scaled_coarse, wc_scaled_coarse, u, v, ...
    'LineWidth', 1.5, 'AutoScale', 'off', 'HandleVisibility', 'off');
if exist('arrowhead_extend_angle', 'file')
    arrowhead_extend_angle(h, 2, 16);
else
    warning('Function arrowhead_extend_angle not found. Arrowheads will not be customized.');
end

grid on;
axis square;

%% ================================
%  AXES TICKS/LABELS
% ================================
xticks = linspace(0, 1, 6);
xticklabels = arrayfun(@(x) sprintf('%.2f', x), linspace(min_x, max_x, numel(xticks)), 'UniformOutput', false);
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);

yticks = linspace(0, 1, 6);
yticklabels = arrayfun(@(y) sprintf('%.2f', y), linspace(min_y, max_y, numel(yticks)), 'UniformOutput', false);
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels);

xlabel('$w_m^{2nd}$ (a.u.)', 'Interpreter', 'latex','FontSize',18);
ylabel('$w_c^{2nd}$ (a.u.)', 'Interpreter', 'latex','FontSize',18);
% % % % switch mode
% % % %     case "V"
% % % %         title(sprintf('Dynamics | %s = %.2f V', mode, V_m), 'Interpreter','none');
% % % %     case "I"
% % % %         title(sprintf('Dynamics | %s = %.2f A', mode, I_m), 'Interpreter','none');
% % % % end

%% ================================
%  NULLCLINES
% ================================
ZERO_CONTOUR_LEVEL = -1e-13;
contour(WM_scaled, WC_scaled, dwm_grid, [ZERO_CONTOUR_LEVEL, ZERO_CONTOUR_LEVEL], ...
    '--', 'EdgeColor', '#308030', 'LineWidth', 2, 'HandleVisibility', 'off');
contour(WM_scaled, WC_scaled, dwm_grid, -[ZERO_CONTOUR_LEVEL, ZERO_CONTOUR_LEVEL], ...
    '--', 'EdgeColor', '#308030', 'LineWidth', 2, 'HandleVisibility', 'off');
contour(WM_scaled, WC_scaled, dwc_grid, [ZERO_CONTOUR_LEVEL, ZERO_CONTOUR_LEVEL], ...
    '--', 'EdgeColor', '#606060', 'LineWidth', 2, 'HandleVisibility', 'off');
contour(WM_scaled, WC_scaled, dwc_grid, -[ZERO_CONTOUR_LEVEL, ZERO_CONTOUR_LEVEL], ...
    '--', 'EdgeColor', '#606060', 'LineWidth', 2, 'HandleVisibility', 'off');

xlim([-0.01 1.01]);
ylim([-0.01 1.01]);

ax = gca;
ax.XTickLabelRotation = 0;

%% ================================
%  EQUILIBRIA OVERLAY (your same pipeline)
% ================================
down_size = 2*points_x_y;

newNy = down_size; newNx = down_size;
xq = linspace(WM_scaled(1,1), WM_scaled(1,end), newNx);
yq = linspace(WC_scaled(1,1), WC_scaled(end,1), newNy);
[Xc, Yc] = meshgrid(xq, yq);

Fx_c = interp2(WM_scaled, WC_scaled, dwm_grid, Xc, Yc, "linear");
Fy_c = interp2(WM_scaled, WC_scaled, dwc_grid, Xc, Yc, "linear");

[eq, cls, hEq] = plot_equilibria_general_fixed(gca, Xc, Yc, Fx_c, Fy_c); %#ok<ASGLU>

% Re-apply arrowheads if you want
if exist('arrowhead_extend_angle', 'file')
    arrowhead_extend_angle(h, 2, 16);
end

if (mode=="V" && V_m==0) || (mode=="I" && I_m==0)
    hold on;
    plot(ax,p.wm0,p.wc0,'ko','MarkerFaceColor','k','MarkerSize',6,'LineWidth',1.2,'HandleVisibility','off');
    hold off;
end

% % return;
% % Save
% set(fig,'InvertHardcopy','off');
% set(fig,'Color','none');
% set(ax ,'Color','none');
% switch mode
%     case "V"
%         saveas(fig, sprintf('WOxDu2015_%s_%.2f.svg', mode, V_m));
%     case "I"
%         saveas(fig, sprintf('WOxDu2015_%s_%.2f.svg', mode, I_m*1e6));
% end
% 
% return;







%% ================================
%  MEMRISTANCE MAP (effective M = |V/I|)
%  Works for both voltage-driven and current-driven cases
% ================================
mode = "V";
Vread = -.5;
Iread = -.1e-6;


R_grid = nan(size(WM_grid));
I_grid = nan(size(WM_grid));
V_grid = nan(size(WM_grid));

switch upper(string(mode))
    case "V"
        Vfixed = Vread;   % your fixed bias
        Ifixed = [];    % unused

    case "I"
        Ifixed = Iread;   % your fixed current bias
        Vfixed = [];    % will be inferred per grid point
        if abs(Ifixed) < 1e-15
            error("For current-driven memristance map, choose non-zero I_m (avoid division by 0).");
        end
end

for i = 1:numel(WM_grid)
    X = [WM_grid(i); WC_grid(i)];

    if upper(string(mode)) == "V"
        % Voltage-driven: compute I from V
        V_here = Vfixed;
        I_here = WOx_Du2015_model_lib.Imem(V_here, X, p);

    else
        % Current-driven: infer V from I (needs VfromI helper)
        I_here = Ifixed;
        V_here = VfromI(I_here, X, p);
    end

    V_grid(i) = V_here;
    I_grid(i) = I_here;

    % Memristance magnitude
    if abs(I_here) > 1e-15
        R_grid(i) = abs(V_here / I_here);
    else
        R_grid(i) = NaN;
    end
end

% Optional: compress range
Rplot = log10(R_grid);
% Rplot = R_grid;  % linear Ohms, like you asked

figR = figure();
figR.NumberTitle = "off";
figR.Name = 'WOx Du2015 | Memristance map';
figR.Color = 'w';
figR.Position(1:2) = [600 800];
figR.Position(3:4) = 520*[1.7 0.9];

colormap(lighter_colormap);

contourf(WM_scaled, WC_scaled, Rplot, 64, ...
    'LineColor', 'none', 'HandleVisibility', 'off');
cb = colorbar;

% --- Choose which linear memristance values you want to label ---
% R_ticks_linear = [1e3 3e3 1e4 3e4 1e5 3e5 1e6];   % Ω (edit freely)
R_ticks_linear = linspace(min(R_grid,[],"all"),.98*max(R_grid,[],"all"),7);

% Convert to log10 for positioning
cb.Ticks = log10(R_ticks_linear);

% Format labels nicely (kΩ, MΩ)
cb.TickLabels = arrayfun(@(R) ...
    ternary(R>=1e6, sprintf('%.1f M\\Omega',R/1e6), ...
    ternary(R>=1e3, sprintf('%.0f k\\Omega',R/1e3), ...
                     sprintf('%.0f \\Omega',R))), ...
    R_ticks_linear, 'UniformOutput', false);

% cb.Label.String = 'Memristance';
% cb.Label.Interpreter = 'latex';
% cb.Label.FontSize = 18;

grid on; axis square;
xlim([-0.01 1.01]); ylim([-0.01 1.01]);

set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels);

xlabel('$w_m^{2nd}$ (a.u.)', 'Interpreter', 'latex','FontSize',18);
ylabel('$w_c^{2nd}$ (a.u.)', 'Interpreter', 'latex','FontSize',18);

% switch upper(string(mode))
%     case "V"
%         title(sprintf('Memristance map | V = %.2g V', Vfixed), 'Interpreter','none');
%     case "I"
%         title(sprintf('Memristance map | I = %.2g A', Ifixed), 'Interpreter','none');
% end

% --- Iso-memristance contours (linear values) ---
hold on;

% R_levels = [1e3 1e4 1e5 1e6];   % Ω (choose what matters physically)
R_levels = linspace(1.1*min(R_grid,[],"all"),.95*max(R_grid,[],"all"),7);
% R_levels = R_levels(2:end-1);
R_levels_log = log10(R_levels);

[C,h] = contour(WM_scaled, WC_scaled, Rplot, R_levels_log, ...
    'LineColor','k', 'LineWidth',.5);

clabel(C, h, ...
    'Interpreter','latex', ...
    'LabelSpacing',450, ...
    'FontSize',16);

% Convert log10(M) -> linear Ω in label
h.LabelFormat = @(x) compose('\\,%.0f\\,k$\\Omega$\\,', 10.^x / 1e3);






% return;
% Save
set(figR,'InvertHardcopy','off');
set(figR,'Color','none');
set(gca ,'Color','none');
switch mode
    case "V"
        saveas(figR, sprintf('WOxDu2015_memristance_%s_%.2f.svg', mode, Vread));
    case "I"
        saveas(figR, sprintf('WOxDu2015_memristance_%s_%.2f.svg', mode, Iread*1e6));
end

% return;




%% =======================================================================
%  EQUILIBRIA / CLASSIFICATION (same helpers you used, unchanged)
% =======================================================================
function [eq, cls, hEq] = plot_equilibria_general_fixed(ax, Xg, Yg, Fx, Fy)
    if nargin < 1 || isempty(ax), ax = gca; end
    axes(ax);
    hold(ax,'on');

    Fx = double(Fx); Fy = double(Fy);
    Fx(~isfinite(Fx)) = NaN; Fy(~isfinite(Fy)) = NaN;

    x = Xg(1,:); y = Yg(:,1);
    dx = min(diff(x)); dy = min(diff(y));

    Fx_abs = abs(Fx(:)); Fx_abs = Fx_abs(isfinite(Fx_abs));
    Fy_abs = abs(Fy(:)); Fy_abs = Fy_abs(isfinite(Fy_abs));
    Fx0 = max(1e-15, 1e-3*prctile(Fx_abs,95));
    Fy0 = max(1e-15, 1e-3*prctile(Fy_abs,95));

    nx = numel(x); ny = numel(y);
    cand = false(ny-1,nx-1);

    for iy=1:ny-1
        for ix=1:nx-1
            Fxc = Fx(iy:iy+1,ix:ix+1);
            Fyc = Fy(iy:iy+1,ix:ix+1);
            if any(isnan(Fxc),'all')||any(isnan(Fyc),'all'), continue; end
            fx_can0 = (min(Fxc,[],'all') <=  Fx0 && max(Fxc,[],'all') >= -Fx0);
            fy_can0 = (min(Fyc,[],'all') <=  Fy0 && max(Fyc,[],'all') >= -Fy0);
            cand(iy,ix) = fx_can0 && fy_can0;
        end
    end

    [iyL, ixL] = find(cand);
    if isempty(ixL)
        eq=[]; cls=[]; hEq=[];
        hold(ax,'off'); return;
    end

    opts = optimoptions('fsolve','Display','off',...
        'FunctionTolerance',1e-12,'OptimalityTolerance',1e-12,'StepTolerance',1e-12,...
        'MaxIterations',100);

    eq_list = [];
    for k=1:numel(ixL)
        ix=ixL(k); iy=iyL(k);
        x1=x(ix); x2=x(ix+1); y1=y(iy); y2=y(iy+1);
        Fxc = Fx(iy:iy+1,ix:ix+1);
        Fyc = Fy(iy:iy+1,ix:ix+1);

        fun = @(p) bilinear_F(p,x1,x2,y1,y2,Fxc,Fyc);
        p0 = [(x1+x2)/2; (y1+y2)/2];
        try
            p = fsolve(fun,p0,opts);
        catch
            p = p0;
        end

        if p(1)>=min(x1,x2) && p(1)<=max(x1,x2) && p(2)>=min(y1,y2) && p(2)<=max(y1,y2)
            Fp = fun(p);
            if all(abs(Fp) < 5*[Fx0;Fy0])
                eq_list(end+1,:) = p(:).'; %#ok<AGROW>
            end
        end
    end

    if isempty(eq_list)
        eq=[]; cls=[]; hEq=[];
        hold(ax,'off'); return;
    end

    mergeTol = 0.6*min(dx,dy);
    eq = merge_points(eq_list, mergeTol);

    cls = classify_eq(eq, Xg, Yg, Fx, Fy);

    eq = eq(1:4:end,:);
    cls = cls(1:4:end,:);

    hEq = plot_eq_markers(ax, eq, cls, 6);

    hold(ax,'off');
end

function F = bilinear_F(p,x1,x2,y1,y2,Fxc,Fyc)
    x=p(1); y=p(2);
    u=(x-x1)/(x2-x1); v=(y-y1)/(y2-y1);
    u=min(max(u,0),1); v=min(max(v,0),1);

    Fx11=Fxc(1,1); Fx12=Fxc(1,2); Fx21=Fxc(2,1); Fx22=Fxc(2,2);
    Fy11=Fyc(1,1); Fy12=Fyc(1,2); Fy21=Fyc(2,1); Fy22=Fyc(2,2);

    Fxv=(1-u)*(1-v)*Fx11 + u*(1-v)*Fx12 + (1-u)*v*Fx21 + u*v*Fx22;
    Fyv=(1-u)*(1-v)*Fy11 + u*(1-v)*Fy12 + (1-u)*v*Fy21 + u*v*Fy22;

    F=[Fxv;Fyv];
    if any(~isfinite(F)), F(:)=1e30; end
end

function Pm = merge_points(P,tol)
    Pm=P(1,:);
    for i=2:size(P,1)
        d=hypot(Pm(:,1)-P(i,1), Pm(:,2)-P(i,2));
        if all(d>tol), Pm(end+1,:)=P(i,:); end %#ok<AGROW>
    end
end

function cls = classify_eq(eq,Xg,Yg,Fx,Fy)
    x=Xg(1,:); y=Yg(:,1);
    dx=mean(diff(x)); dy=mean(diff(y));
    cls=2*ones(size(eq,1),1);
    for k=1:size(eq,1)
        [~,ix]=min(abs(x-eq(k,1)));
        [~,iy]=min(abs(y-eq(k,2)));
        if ix<=1||ix>=numel(x)||iy<=1||iy>=numel(y), continue; end
        dFxdx=(Fx(iy,ix+1)-Fx(iy,ix-1))/(2*dx);
        dFxdy=(Fx(iy+1,ix)-Fx(iy-1,ix))/(2*dy);
        dFydx=(Fy(iy,ix+1)-Fy(iy,ix-1))/(2*dx);
        dFydy=(Fy(iy+1,ix)-Fy(iy-1,ix))/(2*dy);
        if ~all(isfinite([dFxdx dFxdy dFydx dFydy])), continue; end
        J=[dFxdx dFxdy; dFydx dFydy];
        re=real(eig(J));
        if all(re<0), cls(k)=-1;
        elseif all(re>0), cls(k)=1;
        elseif min(re)<0 && max(re)>0, cls(k)=0;
        else, cls(k)=2; end
    end
end

function h = plot_eq_markers(ax,eq,cls,ms)
    stable=cls==-1; unstable=cls==1; saddle=cls==0; unknown=cls==2;
    h = gobjects(4,1);
    tmp=plot(ax,eq(stable,1),eq(stable,2),'ko','MarkerFaceColor','k','MarkerSize',ms,'LineWidth',1.2,'HandleVisibility','off');
    if ~isempty(tmp), h(1)=tmp; end
    tmp=plot(ax,eq(unstable,1),eq(unstable,2),'ko','MarkerFaceColor','none','MarkerSize',ms,'LineWidth',1.5,'HandleVisibility','off');
    if ~isempty(tmp), h(2)=tmp; end
    tmp=plot(ax,eq(saddle,1),eq(saddle,2),'^','Color','k','MarkerFaceColor','k','MarkerSize',ms,'LineWidth',1.2,'HandleVisibility','off');
    if ~isempty(tmp), h(3)=tmp; end
    tmp=plot(ax,eq(unknown,1),eq(unknown,2),'xk','MarkerSize',ms+2,'LineWidth',1.5,'HandleVisibility','off');
    if ~isempty(tmp), h(4)=tmp; end
end

% ---------------- local RHS ----------------
function dX = rhs_WOx(t, X, mode, Vsrc, Isrc, p)
    switch upper(string(mode))
        case "V"
            V_m = Vsrc;
            I_m = [];          % not needed
        case "I"
            V_m = [];          % triggers inferVfromI inside dXdt
            I_m = Isrc(t);
        otherwise
            error("mode must be 'V' or 'I'");
    end

    dX = WOx_Du2015_model_lib.dXdt(V_m, I_m, X, p);
end

function V = VfromI(I_target, X, p)
%VFROMI  Solve Imem(V,X,p)=I_target for V using bracketing + fzero.

    f = @(V) WOx_Du2015_model_lib.Imem(V, X, p) - I_target;

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
        V = fzero(f, 0);
        return;
    end

    V = fzero(f, [a b]);
end

function out = ternary(cond,a,b)
    if cond, out=a; else, out=b; end
end
