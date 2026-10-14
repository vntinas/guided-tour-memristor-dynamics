# A Guided Tour into the Dynamical Analysis of Resistive Switching Systems: Memristor Models

Model files, figure scripts and parameter sets for

> V. Ntinas, *A Guided Tour into the Dynamical Analysis of Resistive Switching
> Systems: Memristor Models*, Memories – Materials, Devices, Circuits and Systems.

Tag **`v1.0-part1`** is the exact revision used to produce the figures of the
article. A snapshot of this tag accompanies the article as supplementary material.

## Requirements

- MATLAB, tested with R2025b. R2023b or later is needed for the `ode` object
  used in `sim_hp.m`.
- Optimization Toolbox, for `fsolve`, which inverts the conduction law under
  current excitation.

## Layout

```
matlab/
├─ +HP_model_lib/           HP model (Strukov et al.)
├─ +Pershin_model_lib/      first-order Pershin–Di Ventra threshold model
├─ +Stanford_model_lib/     Stanford–PKU filamentary ReRAM model
├─ +WeiLu_model_lib/        Wei Lu group volatile WOx model
├─ +Pershin_v2_model_lib/   second-order Pershin–Di Ventra model (PD2)
├─ +WOx_Du2015_model_lib/   second-order WOx model (Du et al.)
├─ func/                    plotting helpers and colour map
└─ figures/                 one script per figure
```

Each model package holds `@const/const.m` (the parameter set used in the
article, listed in Appendix C), `Imem.m` (conduction law) and the state
equation (`dwdt.m`, `dMdt.m`, `dxdt.m` or `dXdt.m`).

## Reproducing the figures

From `matlab/`:

```matlab
addpath(pwd, fullfile(pwd,'func'), fullfile(pwd,'figures'));
```

| Figure | Script | Output |
|---|---|---|
| 1 | `sim_hp.m` (a), `fig1_pulses.m` (b, c) | (a) pinched hysteresis loops, displayed on screen. (b), (c) `potentiation_HP.pdf`, `depression_HP.pdf` |
| 3 | `test_hp_paper.m` | `HP_{vol,cur}_{state,cond}.svg` |
| 4 | `test_Pershin_paper.m` | `PD_{vol,cur}_{state,cond}.svg` |
| 5 | `test_Stanford_paper.m` | `St_{vol,cur}_{state,cond}.svg` |
| 6 | `test_WeiLu_paper.m` | `WL_{vol,cur}_{state,cond}.svg` |
| 8 | `fig8_pd2_phase_plane.m` | `panels/PD2_{a..e}_*.svg`, all five panels in one run |
| 9, 10 | `Dynamem2D_WOx_Du2015.m` | phase plane and memristance map for the excitation set at the top of the script (`mode = "V"` or `"I"` and the input value) |

Figures 2 and 7 are schematics. The panels written by the scripts were
assembled into the published multi-panel figures in draw.io.

For Fig. 9 the `saveas` calls for the phase-plane panels are commented out in
`Dynamem2D_WOx_Du2015.m`. Uncomment them to write each panel to file.

## Numerical method in brief

The DRMs, dynamics maps, phase-plane portraits and memristance maps evaluate
the analytic state equations on a grid. No trajectory is integrated for these
figures, so the grid resolution sets the sampling density of the plots rather
than their accuracy. Fig. 1 is the only figure obtained by time integration.
Appendix D of the article gives the details.
