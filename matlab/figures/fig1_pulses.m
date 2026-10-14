function fig1_pulses()
% FIG1_PULSES  Regenerates Fig. 1(b) potentiation and Fig. 1(c) depression of
% the HP model under trains of current pulses.
%
% Correction with respect to DynAMem/sim_hp_pulses.m, which produced the
% submitted panels: the stiff solver was left at its default maximum step,
% which spans a whole pulse period (50 ms), so it stepped over the
% off-intervals and returned the response to a constant current. The
% submitted panel (b) therefore ended at 0.083 and 0.124 mS instead of the
% resolved 0.071 and 0.083 mS. Here ode15s runs with MaxStep = T/200, which
% resolves every pulse. The submitted script also did not contain the
% depression case of panel (c), which is included here, and panel (b) was
% labelled in uS while the values are in mS.
%
% Pulse train and model settings are those of the submitted figure: period
% T = 50 ms, duty cycle 0.5, ten periods, amplitudes 50 and 100 uA, window
% exponent p = 10. Potentiation starts from the HRS and depression from the
% LRS.

here = fileparts(mfilename('fullpath'));
roots = {fullfile(here,'..','..','..','DynAMem'), fullfile(here,'..')};
addpath(roots{find(cellfun(@(r) isfolder(fullfile(r,'+HP_model_lib')), roots), 1)});
outdir = fullfile(here, '..', '..', 'manuscript', 'Figures');
if ~isfolder(outdir), outdir = fullfile(here, 'panels'); mkdir(outdir); end

set(groot, 'defaultAxesFontSize', 18, 'defaultTextFontSize', 18, ...
           'defaultLegendFontSize', 18);

D = 10e-9;
T = 2*(1/80 + 1/80);                       % 50 ms period
pulse = @(t) double(mod(t, T) < 0.5*T);    % duty cycle 0.5

cases = struct('name', {'potentiation_HP', 'depression_HP'}, ...
               'amps', {[50e-6 100e-6], -[50e-6 100e-6]}, ...
               'x0',   {1e-7, 1 - 1e-7}, ...
               'ylim', {[-5 105], [-105 5]});
styles = {'-', '--'};

for c = cases
    fig = figure('Visible', 'off', 'Color', 'w');
    fig.Position = [10 10 545 453];
    tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    for k = 1:2
        A = c.amps(k);
        F = ode(ODEFcn = @(t, y) HP_model_lib.dwdt([], A*pulse(t), D*y, 10)/D, ...
                InitialValue = c.x0, Solver = "ode15s");
        F.RelativeTolerance = 1e-10;
        F.SolverOptions.MaxStep = T/200;
        S = solve(F, 0, 10*T, Refine = 4);
        I = A*pulse(S.Time);
        G = 1 ./ arrayfun(@(x) HP_model_lib.Mem([], 0, D*x), S.Solution(1,:));

        nexttile(tl, 1); hold on;
        plot(S.Time*1e3, I*1e6, styles{k}, 'LineWidth', 1.5 + 0.5*(k-1));
        nexttile(tl, 2); hold on;
        plot(S.Time*1e3, G*1e3, styles{k}, 'LineWidth', 1.5 + 0.5*(k-1), ...
             'DisplayName', sprintf('%g$\\mu A$', A*1e6));
        fprintf('%-16s A = %+5.0f uA   G: %.4f -> %.4f mS\n', c.name, A*1e6, G(1)*1e3, G(end)*1e3);
    end
    ax1 = nexttile(tl, 1);
    grid(ax1, 'on'); box(ax1, 'on'); ylim(ax1, c.ylim); xticklabels(ax1, '');
    ylabel(ax1, '$i_{\rm in}$ ($\rm \mu A$)', 'Interpreter', 'latex');
    ax2 = nexttile(tl, 2);
    grid(ax2, 'on'); box(ax2, 'on');
    xlabel(ax2, 'Time (ms)', 'Interpreter', 'latex');
    ylabel(ax2, '$G_{\rm HP}$ (mS)', 'Interpreter', 'latex');
    lgd = legend(ax2, 'Location', 'best', 'Interpreter', 'latex');
    lgd.Title.String = '\rm Pulse Amplitude';
    exportgraphics(fig, fullfile(outdir, c.name + ".pdf"), 'ContentType', 'vector');
    close(fig);
end
end
