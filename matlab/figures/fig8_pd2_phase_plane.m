function fig8_pd2_phase_plane()
% FIG8_PD2_PHASE_PLANE  Regenerates all five panels of Fig. 8 (second-order
% Pershin--Di Ventra phase planes) with the arrow-scaling correction.
%
% Corrections with respect to DynAMem/Dynamem2D_Pershin_v2_test.m, the
% script that produced the submitted figure:
%   1. Arrow direction and length are computed from derivatives normalized
%      by the axis ranges (xdot/x_range, ydot/y_range), consistently with
%      the [0,1]-normalized axes they are drawn on. The submitted figure
%      used atan2 on physical derivatives (Ohm/s against V/s), which tilts
%      every arrow where both components are nonzero.
%   2. The background colour map shows |xdot_PD2| in kOhm/s, the rate of
%      memristance change, on one colour scale shared by all five panels.
%      The submitted figure showed ||(xdot, ydot)||_2, which adds Ohm/s to
%      V/s.
%   3. Coarse-grid sampling is indexed (rows = y, cols = x). The submitted
%      script indexed (x, y), harmless only because both axes had 101 points.
%   4. The equilibrium detector receives normalized derivatives, so its
%      Jacobian-based classification is consistent with the normalized
%      grid coordinates.
%   5. The gate of the memristance follows Eq. (7) of Pershin and Di Ventra,
%      Proc. IEEE 100, 2071 (2012), with the sign of xdot chosen so that
%      positive inputs drive the device toward the LRS (see
%      +Pershin_v2_model_lib/dMdt.m). The submitted figure used a mirrored
%      gate, under which a single pulse changes the memristance.
%   6. Zero crossings that are really jumps are rejected. The PD2 field is
%      discontinuous at the threshold surfaces, and under current drive ydot
%      jumps from -y/tau to (|V|-y)/tau across x = Vt/|I| without vanishing.
%      Contouring and bilinear interpolation across that jump produced a
%      spurious ydot-nullcline segment and a spurious run of equilibrium
%      markers at x = 4.5 kOhm in panels (d) and (e) of the submitted
%      figure. Every ydot-nullcline vertex is now accepted only if bisection
%      of the true model along its grid edge converges to a zero, and every
%      equilibrium only if the true model vanishes there.
%
% Model files are read from the canonical DynAMem/ tree. Nothing there is
% modified. Panels are written to ./panels/ as vector SVG and PNG preview.

here    = fileparts(mfilename('fullpath'));
% The model library sits in DynAMem/ in the workspace (this script lives in
% Revision/code/fig8/) and one level up in the release repo (matlab/figures/).
roots   = {fullfile(here, '..', '..', '..', 'DynAMem'), fullfile(here, '..')};
dynamem = roots{find(cellfun(@(r) isfolder(fullfile(r, '+Pershin_v2_model_lib')), ...
                             roots), 1)};
addpath(dynamem);
addpath(fullfile(roots{find(cellfun(@(r) isfolder(fullfile(r, 'func')), roots), 1)}, 'func'));
outdir  = fullfile(here, 'panels');
if ~exist(outdir, 'dir'), mkdir(outdir); end

% ---- panel definitions (published layout of Fig. 8) ---------------------
% mode 'V' : constant voltage V_m [V]       mode 'I' : constant current I_m [A]
P = struct( ...
  'tag',   {'a_subthreshold', 'b_vol_neg_supra', 'c_vol_pos_supra', ...
            'd_cur_neg_supra', 'e_cur_pos_supra'}, ...
  'mode',  {'V',    'V',  'V',  'I',      'I'}, ...
  'value', {0.5,    -1,   1,    -200e-6,  200e-6});
% Any |V_m| < Vt yields the identical panel (a), since both gating terms
% vanish below threshold.

% ---- grid, identical to the submitted figure ----------------------------
c  = Pershin_v2_model_lib.const;
N  = 101;
x  = linspace(c.Ron, c.Roff, N);            % memristance [Ohm]
y  = linspace(-4*c.yt, 4*c.yt, N);          % trace variable [V]
[X, Y]  = meshgrid(x, y);                   % rows = y, cols = x
x_range = x(end) - x(1);
y_range = y(end) - y(1);
Xs = (X - x(1)) / x_range;
Ys = (Y - y(1)) / y_range;

% ---- evaluate all fields first, so the colour scale can be shared -------
F = cell(numel(P), 1);
cmax = 0;
for k = 1:numel(P)
    [xd, yd] = field(P(k), X, Y);
    F{k} = struct('xdot', xd, 'ydot', yd);
    cmax = max(cmax, max(abs(xd(:))) / 1e3);         % kOhm/s
end
fprintf('shared colour scale: 0 to %.3f kOhm/s\n', cmax);

funcdir = roots{find(cellfun(@(r) isfile(fullfile(r, 'func', 'colormap.csv')), roots), 1)};
cmap = readmatrix(fullfile(funcdir, 'func', 'colormap.csv'));
cmap = cmap(92:164, :);                             % same subrange as submitted

for k = 1:numel(P)
    tf = @(xs, ys) true_field(P(k), x(1) + xs*x_range, y(1) + ys*y_range, ...
                              x_range, y_range);
    render_panel(P(k), F{k}, x, y, Xs, Ys, x_range, y_range, cmax, cmap, ...
                 outdir, tf);
end
disp('all panels written');
end

% =========================================================================
function [xd, yd] = field(p, X, Y)
xd = zeros(size(X)); yd = zeros(size(X));
for i = 1:numel(X)
    if p.mode == 'V'
        d = Pershin_v2_model_lib.dMdt(p.value, [], [X(i); Y(i)]);
    else
        d = Pershin_v2_model_lib.dMdt([], p.value, [X(i); Y(i)]);
    end
    xd(i) = d(1); yd(i) = d(2);
end
end

% =========================================================================
function render_panel(p, F, x, y, Xs, Ys, x_range, y_range, cmax, cmap, outdir, tf)
set(groot, 'defaultAxesFontSize', 18, 'defaultTextFontSize', 18, ...
           'defaultColorbarFontSize', 18);

fig = figure('Visible', 'off', 'Color', 'none');
fig.Position(3:4) = 520*[1.7 0.9];
ax = axes(fig); hold(ax, 'on');
colormap(ax, cmap);

% --- background: |xdot| in kOhm/s on the shared scale -------------------
C = abs(F.xdot) / 1e3;
if max(C(:)) == 0
    patch(ax, [0 1 1 0], [0 0 1 1], cmap(1,:), 'EdgeColor', 'none', ...
          'HandleVisibility', 'off');
else
    contourf(ax, Xs, Ys, C, linspace(0, cmax, 64), 'LineColor', 'none', ...
             'HandleVisibility', 'off');
end
clim(ax, [0 cmax]);
cb = colorbar(ax);
cb.Label.Interpreter = 'latex';
cb.Label.String = '$|\dot{x}_{\mathrm{PD2}}|$ (k$\Omega$/s)';

% --- arrows: direction and length from NORMALIZED derivatives ------------
nc = 17;
ix = round(linspace(1, numel(x), nc));
iy = round(linspace(1, numel(y), nc));
xs_c = (x(ix) - x(1)) / x_range;
ys_c = (y(iy) - y(1)) / y_range;
du = abs(xs_c(2) - xs_c(1)) / 2;
dv = abs(ys_c(2) - ys_c(1)) / 2;

xn = F.xdot(iy, ix) / x_range;               % rows = y, cols = x
yn = F.ydot(iy, ix) / y_range;
ang = atan2(yn, xn);
mag = log10(hypot(xn, yn));
ok  = isfinite(mag);
mag = (mag - min(mag(ok))) / (max(mag(ok)) - min(mag(ok)));
mag(~ok) = 0;
h = quiver(ax, xs_c, ys_c, cos(ang)*du.*mag, sin(ang)*dv.*mag, ...
           'LineWidth', 1.5, 'AutoScale', 'off', 'HandleVisibility', 'off');
arrowhead_extend_angle(h, 2, 16);

% --- nullclines (zero level sets, unaffected by scaling) -----------------
% A field that vanishes identically (xdot in panel (a)) has the whole
% plane as its nullcline, so no curve is drawn for it.
% xdot vanishes on whole regions, so its nullcline is drawn as the boundary
% of the region where |xdot| > 0. Contouring |xdot| works for both signs of
% the input, where a contour of xdot itself at a small positive level only
% finds the boundary when xdot >= 0.
if range(F.xdot(:)) > 0
    contour(ax, Xs, Ys, abs(F.xdot), [1e-13 1e-13], '--', 'EdgeColor', '#308030', ...
            'LineWidth', 2, 'HandleVisibility', 'off');
end
if range(F.ydot(:)) > 0
    draw_true_nullcline(ax, Xs, Ys, F.ydot / y_range, tf, 2, '#606060');
end

% --- equilibria, from normalized derivatives -----------------------------
plot_equilibria_general_fixed(ax, Xs, Ys, F.xdot / x_range, F.ydot / y_range, tf);

% --- axes ----------------------------------------------------------------
grid(ax, 'on'); box(ax, 'on'); axis(ax, 'square');
ax.Layer = 'top';
xlim(ax, [-0.01 1.01]); ylim(ax, [-0.01 1.01]);
set(ax, 'XTick', linspace(0, 1, 5), ...
        'XTickLabel', compose('%g', linspace(x(1), x(end), 5)/1e3));
set(ax, 'YTick', linspace(0, 1, 9), ...
        'YTickLabel', compose('%g', linspace(y(1), y(end), 9)*1e3));
ax.XTickLabelRotation = 0;
xlabel(ax, '$x_{\mathrm{PD2}}$ (k$\Omega$)', 'Interpreter', 'latex');
ylabel(ax, '$y_{\mathrm{PD2}}$ (mV)', 'Interpreter', 'latex');
ax.Color = 'none';

base = fullfile(outdir, "PD2_" + string(p.tag));
exportgraphics(fig, base + ".svg", 'ContentType', 'vector', ...
               'BackgroundColor', 'none');
exportgraphics(fig, base + ".png", 'Resolution', 200, ...
               'BackgroundColor', 'white');
fprintf('  %-18s  %s = %+g   max|xdot| = %.3f kOhm/s\n', p.tag, p.mode, ...
        p.value, max(abs(F.xdot(:)))/1e3);
close(fig);
end

% =========================================================================
function [fx, fy] = true_field(p, xp, yp, x_range, y_range)
% True PD2 state velocity at one physical point, normalized by the axis ranges.
if p.mode == 'V'
    d = Pershin_v2_model_lib.dMdt(p.value, [], [xp; yp]);
else
    d = Pershin_v2_model_lib.dMdt([], p.value, [xp; yp]);
end
fx = d(1) / x_range; fy = d(2) / y_range;
end

% =========================================================================
function draw_true_nullcline(ax, Xs, Ys, Fc, tf, comp, color)
% Draws the zero level set of component COMP (1 = xdot, 2 = ydot) of the
% normalized field Fc, keeping only vertices that are genuine zeros of the
% true model. A vertex sits on a grid edge. Bisection of the true model along
% that edge converges to a zero for a continuous crossing, and to a finite
% one-sided limit for a jump, which is then rejected.
xg = Xs(1,:); yg = Ys(:,1).';
M = contourc(xg, yg, Fc, [0 0]);
k = 1;
while k < size(M, 2)
    n = M(2,k); pts = M(:, k+1:k+n); k = k + n + 1;
    keep = false(1, n);
    for j = 1:n
        keep(j) = is_true_zero(pts(1,j), pts(2,j), xg, yg, tf, comp);
    end
    % plot each consecutive run of accepted vertices as one segment
    d = diff([false keep false]);
    s0 = find(d == 1); s1 = find(d == -1) - 1;
    for r = 1:numel(s0)
        if s1(r) > s0(r)
            plot(ax, pts(1, s0(r):s1(r)), pts(2, s0(r):s1(r)), '--', ...
                 'Color', color, 'LineWidth', 2, 'HandleVisibility', 'off');
        end
    end
end
end

function ok = is_true_zero(px, py, xg, yg, tf, comp)
tol = 1e-10;
onx = min(abs(xg - px)) < tol;          % on a vertical grid line
ony = min(abs(yg - py)) < tol;          % on a horizontal grid line
g = @(xx, yy) pick(tf, xx, yy, comp);
if onx && ony
    ok = abs(g(px, py)) == 0; return
elseif onx                               % vertical edge, bisect in y
    j = find(yg <= py, 1, 'last'); j = min(j, numel(yg) - 1);
    f = @(t) g(px, t); a = yg(j); b = yg(j+1);
else                                     % horizontal edge, bisect in x
    i = find(xg <= px, 1, 'last'); i = min(i, numel(xg) - 1);
    f = @(t) g(t, py); a = xg(i); b = xg(i+1);
end
fa = f(a); fb = f(b); f0 = max(abs([fa fb]));
if fa == 0 || fb == 0, ok = true; return, end
if sign(fa) == sign(fb), ok = false; return, end
for it = 1:60
    m = (a + b)/2; fm = f(m);
    if fm == 0, ok = true; return, end
    if sign(fm) == sign(fa), a = m; fa = fm; else, b = m; fb = fm; end
end
ok = min(abs([fa fb])) < 1e-6 * f0;
end

function v = pick(tf, xx, yy, comp)
[fx, fy] = tf(xx, yy);
if comp == 1, v = fx; else, v = fy; end
end

% =========================================================================
% Equilibrium helpers, taken unchanged from Dynamem2D_Pershin_v2_test.m
% =========================================================================
function [eq, cls, hEq] = plot_equilibria_general_fixed(ax, Xg, Yg, Fx, Fy, tf)
    if nargin < 1 || isempty(ax), ax = gca; end
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
    if isempty(ixL), eq=[]; cls=[]; hEq=[]; return; end
    opts = optimoptions('fsolve','Display','off', 'FunctionTolerance',1e-12, ...
        'OptimalityTolerance',1e-12,'StepTolerance',1e-12,'MaxIterations',100);
    eq_list = [];
    for k=1:numel(ixL)
        ix=ixL(k); iy=iyL(k);
        x1=x(ix); x2=x(ix+1); y1=y(iy); y2=y(iy+1);
        Fxc = Fx(iy:iy+1,ix:ix+1);
        Fyc = Fy(iy:iy+1,ix:ix+1);
        fun = @(p) bilinear_F(p,x1,x2,y1,y2,Fxc,Fyc);
        p0 = [(x1+x2)/2; (y1+y2)/2];
        try, p = fsolve(fun,p0,opts); catch, p = p0; end
        if p(1)>=min(x1,x2) && p(1)<=max(x1,x2) && p(2)>=min(y1,y2) && p(2)<=max(y1,y2)
            Fp = fun(p);
            if all(abs(Fp) < 5*[Fx0;Fy0])
                eq_list(end+1,:) = p(:).'; %#ok<AGROW>
            end
        end
    end
    if isempty(eq_list), eq=[]; cls=[]; hEq=[]; return; end
    mergeTol = 0.6*min(dx,dy);
    eq = merge_points(eq_list, mergeTol);
    % Keep only points where the TRUE model vanishes. Candidates found on the
    % bilinear interpolant across a discontinuity are rejected here.
    if nargin >= 6 && ~isempty(tf)
        fscale = max(hypot(Fx(:), Fy(:)), [], 'omitnan');
        res = zeros(size(eq,1),1);
        for k = 1:size(eq,1)
            [fx, fy] = tf(eq(k,1), eq(k,2));
            res(k) = hypot(fx, fy);
        end
        eq = eq(res <= 1e-6*fscale, :);
        if isempty(eq), cls=[]; hEq=[]; return; end
    end
    cls = classify_eq(eq, Xg, Yg, Fx, Fy);
    eq = eq(1:4:end,:);
    cls = cls(1:4:end,:);
    hEq = plot_eq_markers(ax, eq, cls, 6);
end

function F = bilinear_F(p,x1,x2,y1,y2,Fxc,Fyc)
    x=p(1); y=p(2);
    u=(x-x1)/(x2-x1); v=(y-y1)/(y2-y1);
    u=min(max(u,0),1); v=min(max(v,0),1);
    Fxv=(1-u)*(1-v)*Fxc(1,1) + u*(1-v)*Fxc(1,2) + (1-u)*v*Fxc(2,1) + u*v*Fxc(2,2);
    Fyv=(1-u)*(1-v)*Fyc(1,1) + u*(1-v)*Fyc(1,2) + (1-u)*v*Fyc(2,1) + u*v*Fyc(2,2);
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
        J=[(Fx(iy,ix+1)-Fx(iy,ix-1))/(2*dx), (Fx(iy+1,ix)-Fx(iy-1,ix))/(2*dy);
           (Fy(iy,ix+1)-Fy(iy,ix-1))/(2*dx), (Fy(iy+1,ix)-Fy(iy-1,ix))/(2*dy)];
        if ~all(isfinite(J(:))), continue; end
        re=real(eig(J));
        if all(re<0), cls(k)=-1;
        elseif all(re>0), cls(k)=1;
        elseif min(re)<0 && max(re)>0, cls(k)=0;
        else, cls(k)=2; end
    end
end

function h = plot_eq_markers(ax,eq,cls,ms)
    h = gobjects(4,1);
    s = {cls==-1, 'ko', 'k',    1.2, ms;
         cls==1,  'ko', 'none', 1.5, ms;
         cls==0,  'k^', 'k',    1.2, ms;
         cls==2,  'xk', 'none', 1.5, ms+2};
    for j = 1:4
        m = s{j,1};
        if any(m)
            h(j) = plot(ax, eq(m,1), eq(m,2), s{j,2}, 'MarkerFaceColor', s{j,3}, ...
                'MarkerSize', s{j,5}, 'LineWidth', s{j,4}, 'HandleVisibility', 'off');
        end
    end
end
