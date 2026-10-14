clear;
clc;
close all;

% Save the current default font sizes
originalAxesFontSize = get(groot, 'defaultAxesFontSize');
originalTextFontSize = get(groot, 'defaultTextFontSize');
originalLegendFontSize = get(groot, 'defaultLegendFontSize');
originalColorbarFontSize = get(groot, 'defaultColorbarFontSize');

% Set temporary default font sizes for this script
set(groot, 'defaultAxesFontSize', 18);    % Font size for axes
set(groot, 'defaultTextFontSize', 18);    % Font size for text
set(groot, 'defaultLegendFontSize', 18);  % Font size for legends
set(groot, 'defaultColorbarFontSize', 18);% Font size for colorbars

flag_dyn_vol = 1;
flag_dyn_cur = 1;
flag_mem_vol = 1;
flag_mem_cur = 1;


D = 10e-9;
w_min = 0;
w_max = D;

Delta_w = w_max-w_min;

w_actual = @(x) w_min + Delta_w*x;
x_transform = @(w) (w - w_min)/Delta_w;


V_m = linspace(-1, 1,51);
I_m = linspace(-1e-3, 1e-3,51);

V_m_DRM = linspace(-1, 1,9);
I_m_DRM = linspace(-1e-3, 1e-3,9);
x = linspace(0, 1,1001);


[Vm_grid,x_grid] = meshgrid(V_m,x);
[Vm_grid_DRM,x_grid_DRM] = meshgrid(V_m_DRM,x);

[Im_grid,x_grid_cur] = meshgrid(I_m,x);
[Im_grid_DRM,x_grid_cur_DRM] = meshgrid(I_m_DRM,x);

dxdt_DRM = arrayfun(@(Vm,x) HP_model_lib.dwdt(Vm,[],w_actual(x),100),Vm_grid_DRM,x_grid_DRM);
dxdt_DRM = dxdt_DRM/D;
dxdt = arrayfun(@(Vm,x) HP_model_lib.dwdt(Vm,[],w_actual(x),100),Vm_grid,x_grid);
dxdt = dxdt/D;

dxdt_cur_DRM = arrayfun(@(Im,x) HP_model_lib.dwdt([],Im,w_actual(x),100),Im_grid_DRM,x_grid_cur_DRM);
dxdt_cur_DRM = dxdt_cur_DRM/D;
dxdt_cur = arrayfun(@(Im,x) HP_model_lib.dwdt([],Im,w_actual(x),100),Im_grid,x_grid_cur);
dxdt_cur = dxdt_cur/D;

log_scale_coef = 0.1;
log_scale_coef_cur = 10;
my_ticks = [-2e1 -1e1 -5e0 -1e0 0 1e0 5e0 1e1 2e1];
my_ticks_cur = [-1e1 -5e0 -1e0 0 1e0 5e0 1e1];
my_ticks_transf = simlog10(my_ticks,log_scale_coef);
my_ticks_transf_cur = simlog10(my_ticks_cur,log_scale_coef_cur);
cols = turbo(length(V_m_DRM)+2);
cols = cols(2:end-1,:);
cols_cur = turbo(length(I_m_DRM)+2);
cols_cur = cols_cur(2:end-1,:);
col_turbo_no_dark = turbo;
col_turbo_no_dark = col_turbo_no_dark(20:end-5,:);

dxdt_transformed_DRM = simlog10(dxdt_DRM,log_scale_coef);
dxdt_transformed = simlog10(dxdt,log_scale_coef);
dxdt_cur_transformed_DRM = simlog10(dxdt_cur_DRM,log_scale_coef_cur);
dxdt_cur_transformed = simlog10(dxdt_cur,log_scale_coef_cur);

%% Plot DRM and Parametric countour plot for V_m sweep
options.model_name = 'HP model';
options.input_type = 'Voltage input';
options.labels.mem_state = 'State Variable $x_{\mathrm{HP}}$ (a.u.)';
options.labels.mem_deriv = 'Switching Speed $\dot{x}_{\mathrm{HP}}~\mathrm{(s^{-1})}$';
options.labels.input = 'Input Voltage $v_{\mathrm{in}}$ (V)';
options.labels.input_legend = '$v_{\mathrm{in}}$ (V)';
options.my_ticks_transf = my_ticks_transf;
options.my_ticks = my_ticks;
options.log_scale_coef = log_scale_coef;
options.contour_levels = [-10 -5 -2 -1 -0.5 -0.2 -0.1 0 0.1 0.2 0.5 1 2 5 10];

data.x = x;
data.in = V_m;
data.in_DRM = V_m_DRM;
data.in_grid = Vm_grid;
data.x_grid = x_grid;
data.dxdt_transformed_DRM = dxdt_transformed_DRM;
data.dxdt_transformed = dxdt_transformed;

if flag_dyn_vol
    fig_1 = dynamics_plot(data,options);
    exportgraphics(gcf,"HP_vol_state.svg","Resolution",1200,'BackgroundColor','none','ContentType','vector');
end

%% Plot DRM and Parametric countour plot for I_m sweep
options_cur.model_name = 'HP model';
options_cur.input_type = 'Current input';
options_cur.labels.mem_state = 'State Variable $x_{\mathrm{HP}}$ (a.u.)';
options_cur.labels.mem_deriv = 'Switching Speed $\dot{x}_{\mathrm{HP}}$ ($\mathrm{s^{-1}}$)';
options_cur.labels.input = 'Input Current $i_{\mathrm{in}}$ (mA)';
options_cur.labels.input_legend = '$i_{\mathrm{in}}$ (mA)';
options_cur.my_ticks_transf = my_ticks_transf_cur;
options_cur.my_ticks = my_ticks_cur;
options_cur.log_scale_coef = log_scale_coef_cur;
options_cur.contour_levels = [-10 -5 -2 -1 0 1 2 5 10];

data_cur.x = x;
data_cur.in = I_m*1e3;
data_cur.in_DRM = I_m_DRM*1e3;
data_cur.in_grid = Im_grid*1e3;
data_cur.x_grid = x_grid;
data_cur.dxdt_transformed_DRM = dxdt_cur_transformed_DRM;
data_cur.dxdt_transformed = dxdt_cur_transformed;

if flag_dyn_cur
    fig_2 = dynamics_plot(data_cur,options_cur);
    exportgraphics(gcf,"HP_cur_state.svg","Resolution",1200,'BackgroundColor','none','ContentType','vector');
end



%% Plot Memristance lines and Memristance Map V_m sweep
V_m_DRM = linspace(-1, 1,201);
x_coarse = linspace(0, 1,9);
x_fine = linspace(0, 1,101);
[x_coarse_grid,Vm_coarse_grid] = meshgrid(x_coarse,V_m_DRM);
[x_fine_grid,Vm_fine_grid] = meshgrid(x_fine,V_m_DRM);
Mem_V = arrayfun(@(Vm,x) HP_model_lib.Mem(Vm,[],w_actual(x)),Vm_coarse_grid,x_coarse_grid);
Mem_V = Mem_V/1000;
Mem_V_fine = arrayfun(@(Vm,x) HP_model_lib.Mem(Vm,[],w_actual(x)),Vm_fine_grid,x_fine_grid);
Mem_V_fine = Mem_V_fine/1000;


options_mem.model_name = 'HP model';
options_mem.input_type = 'Voltage input';
options_mem.labels.mem_state = 'State Variable $x_{\mathrm{HP}}$ (a.u.)';
options_mem.labels.mem_state_legend = '$x_{\mathrm{HP}}$ (a.u.)';
options_mem.labels.input = 'Input Voltage $v_{\mathrm{in}}$ (V)';
options_mem.my_ticks = [0.1 0.2 0.5 1 2 5 10 15];
options_mem.contour_levels = [1 2 5 10 12 15];

data_mem.x_coarse = x_coarse;
data_mem.x = x;
data_mem.in = V_m;
data_mem.in_DRM = V_m_DRM;
data_mem.in_fine_grid = Vm_fine_grid;
data_mem.x_fine_grid = x_fine_grid;
data_mem.Mem_in = Mem_V;
data_mem.Mem_in_fine = Mem_V_fine;

if flag_mem_vol
    fig_3 = memristance_plot(data_mem,options_mem);
    exportgraphics(gcf,"HP_vol_cond.svg","Resolution",1200,'BackgroundColor','none','ContentType','vector');
end


%% Plot Memristance lines and Memristance Map I_m sweep
I_m_DRM = linspace(-1e-3, 1e-3,201);

x_coarse = linspace(0, 1,9);
x_fine = linspace(0, 1,101);
[x_coarse_grid,Im_coarse_grid] = meshgrid(x_coarse,I_m_DRM);
[x_fine_grid,Im_fine_grid] = meshgrid(x_fine,I_m_DRM);
Mem_I = arrayfun(@(Im,x) HP_model_lib.Mem([],Im,w_actual(x)),Im_coarse_grid,x_coarse_grid);
Mem_I = Mem_I/1000;
Mem_I_fine = arrayfun(@(Im,x) HP_model_lib.Mem([],Im,w_actual(x)),Im_fine_grid,x_fine_grid);
Mem_I_fine = Mem_I_fine/1000;


options_mem_cur.model_name = 'HP model';
options_mem_cur.input_type = 'Current input';
options_mem_cur.labels.mem_state = 'State Variable $x_{\mathrm{HP}}$ (a.u.)';
options_mem_cur.labels.mem_state_legend = '$x_{\mathrm{HP}}$ (a.u.)';
options_mem_cur.labels.input = 'Input Current $i_{\mathrm{in}}$ (mA)';
options_mem_cur.my_ticks = [0.1 0.2 0.5 1 2 5 10 15];

options_mem_cur.contour_levels = [1 2 5 10 12 15];

data_mem_cur.Mem_in = Mem_I;
data_mem_cur.in_DRM = I_m_DRM*1e3;
data_mem_cur.x_coarse = x_coarse;
data_mem_cur.x = x;
data_mem_cur.in = I_m*1e3;
data_mem_cur.Mem_in_fine = Mem_I_fine;
data_mem_cur.in_fine_grid = Im_fine_grid*1e3;
data_mem_cur.x_fine_grid = x_fine_grid;

if flag_mem_cur
    fig_4 = memristance_plot(data_mem_cur,options_mem_cur);
    exportgraphics(gcf,"HP_cur_cond.svg","Resolution",1200,'BackgroundColor','none','ContentType','vector');
end


% After the script is done, reset the default font sizes to their original values
set(groot, 'defaultAxesFontSize', originalAxesFontSize);
set(groot, 'defaultTextFontSize', originalTextFontSize);
set(groot, 'defaultLegendFontSize', originalLegendFontSize);
set(groot, 'defaultColorbarFontSize', originalColorbarFontSize);



% Symmetric log10 transformation function
function transformed_data = simlog10(data, cutoff)
    % Applies symmetric log10 transformation with a cutoff
    % cutoff: values below this (absolute) are scaled linearly
    transformed_data = sign(data) .* log10(1 + abs(data) / cutoff);
end

% Inverse of symmetric log10 transformation
function original_data = inv_simlog10(transformed_data, cutoff)
    % Applies the inverse of the symmetric log10 transformation
    original_data = sign(transformed_data) .* (10.^abs(transformed_data) - 1) * cutoff;
    % sign(v) * (10^abs(v) * (10^log_scale_coef) - 1)
end

function fig = dynamics_plot(data,options)
    fontsize_labels = 20;
    fontsize_axis = 16;
    cols = turbo(length(data.in_DRM)+2);
    cols = cols(2:end-1,:);
    col_turbo_no_dark = turbo;
    col_turbo_no_dark = col_turbo_no_dark(20:end-5,:);
    %% Plot DRM and Parametric countour plot for sweep
    fig = figure;
    fig.NumberTitle = "off";
    fig.Name = [options.model_name ' | ' options.input_type ' | Dynamics'];
    fig.Color = 'w';
    fig.Position(1:2) = [50 800];
    fig.Position(3:4) = 520*[1.7 0.9];
    tl = tiledlayout(fig,1,2);
    tl.Padding = "compact";
    tl.TileSpacing = "tight";
    tl_inside = tiledlayout(tl,100,1);
    
    nexttile(tl_inside,11,[90 1]);
    plot_drm1_general(data.dxdt_transformed_DRM,data.x,[]);
    ax=gca;
    ax.FontSize = fontsize_axis;
    ax.ColorOrder = cols;
    ax.YTick = options.my_ticks_transf;
    ax.YTickLabel = arrayfun(@(v) sprintf('%.3g', v), options.my_ticks, 'UniformOutput', false);
    ax.YLim = [min(options.my_ticks_transf(1),min(data.dxdt_transformed_DRM(:))*1.05) max(options.my_ticks_transf(end),max(data.dxdt_transformed_DRM(:))*1.05)];
    
    ax.XTick = 0:.25:1;
    ax.XTickLabelRotation = 0;
    ax.XMinorGrid = "on";
    ax.YLabel.String = options.labels.mem_deriv;
    ax.YLabel.Interpreter = "latex";
    ax.YLabel.FontSize = fontsize_labels;
    ax.XLabel.String = options.labels.mem_state;
    ax.XLabel.Interpreter = "latex";
    ax.XLabel.FontSize = fontsize_labels;
    grid on;
    
    
    SDR_arrows(findobj(ax, 'Type', 'line'));

    lgd = legend();
    for i=1:length(data.in_DRM)
        lgd.String{i} = sprintf('%.3g', data.in_DRM(i));
        ax.Children(i).LineWidth = 1.5;
    end
    lgd.NumColumns = 5;
    lgd.Orientation = "horizontal";
    lgd.ItemTokenSize(1) = 20;
    lgd.Box = "off";
    lgd.Position = [0.14    0.85    .62    0.1];
    
    anno = annotation('textbox');
    anno.EdgeColor = 'none';
    anno.FitBoxToText = "on";
    anno.Position = [-0.01,0.9,0.094,0.062];
    anno.Interpreter = "latex";
    anno.String = options.labels.input_legend;
    anno.HorizontalAlignment = "center";
    anno.VerticalAlignment = "middle";
    anno.FontSize = 14;
    
    
    nexttile(tl,2);
    imagesc([min(data.in) max(data.in)],[min(data.x) max(data.x)],data.dxdt_transformed);
    colormap(col_turbo_no_dark);
    hold on;
    [C,h] = contour(data.in_grid,data.x_grid,data.dxdt_transformed,simlog10(options.contour_levels,options.log_scale_coef),'EdgeColor',[0 0 0]);
    hold off;
    clabel(C,h,'Interpreter','latex','LabelSpacing',1000,'FontSize',16);
    h.LabelFormat = @(x) compose('%.2g', inv_simlog10(x,options.log_scale_coef));
    grid on;
    ax=gca;
    ax.FontSize = fontsize_axis;
    ax.XMinorGrid = "on";
    ax.YMinorGrid = "on";
    ax.XTick = -1:.5:1;
    ax.YTick = 0:.2:1;
    ax.YLabel.String = options.labels.mem_state;
    ax.YLabel.Interpreter = "latex";
    ax.YLabel.FontSize = fontsize_labels;
    ax.XLabel.String = options.labels.input;
    ax.XLabel.Interpreter = "latex";
    ax.XLabel.FontSize = fontsize_labels;
    ax.YDir = "normal";
    clb = colorbar();
    clb.Label.Interpreter = "latex";
    clb.Label.FontSize = fontsize_axis;
    clb.Label.String = options.labels.mem_deriv;
    Lim_tmp = clb.Limits;
    clb.Limits = [min(options.my_ticks_transf(1),Lim_tmp(1)) max(options.my_ticks_transf(end),Lim_tmp(2))];
    clb.Ticks = options.my_ticks_transf;
    clb.TickLabels = arrayfun(@(v) sprintf('%.3g', v), options.my_ticks, 'UniformOutput', false);
end




function fig = memristance_plot(data,options)
    fontsize_labels = 20;
    fontsize_axis = 16;
    cols = turbo(length(data.x_coarse)+2);
    cols = cols(2:end-1,:);
    col_turbo_no_dark = turbo;
    col_turbo_no_dark = col_turbo_no_dark(20:end-5,:);

    %% Plot Memristance lines and Memristance Map sweep
    fig = figure;
    fig.NumberTitle = "off";
    fig.Name = [options.model_name ' | ' options.input_type ' | Memristance'];
    fig.Color = 'w';
    fig.Position(1:2) = [50 800];
    fig.Position(3:4) = 520*[1.7 0.9];
    tl = tiledlayout(fig,1,2);
    tl.Padding = "compact";
    tl.TileSpacing = "tight";
    tl_inside = tiledlayout(tl,100,1);
    
    nexttile(tl_inside,11,[90 1]);
    plot_drm1_general(data.Mem_in,data.in_DRM,[]);
    ax=gca;
    ax.FontSize = fontsize_axis;
    ax.ColorOrder = cols(end:-1:1,:);
    ax.YScale = "log";
    ax.YLim = [min(data.Mem_in(:))*0.9 max(data.Mem_in(:))*1.1];
    ax.YLabel.FontSize = fontsize_labels;
    ax.YTick = options.my_ticks;
    
    ax.XTick = linspace(min(data.in_DRM), max(data.in_DRM),5);
    ax.XTickLabelRotation = 0;
    ax.XMinorGrid = "on";
    ax.YLabel.String = 'Memristance (k$\Omega$)';
    ax.YLabel.Interpreter = "latex";
    ax.XLabel.String = options.labels.input;
    ax.XLabel.Interpreter = "latex";
    ax.XLabel.FontSize = fontsize_labels;
    grid on;
    
    lgd = legend();
    for i=1:length(data.x_coarse)
        lgd.String{i} = sprintf('%.3g', data.x_coarse(i));
        ax.Children(i).LineWidth = 1.5;
    end
    lgd.NumColumns = 3;
    lgd.Orientation = "horizontal";
    lgd.ItemTokenSize(1) = 15;
    lgd.Box = "off";
    lgd.Position = [0.18    0.85    .65    0.1];
    
    anno = annotation('textbox');
    anno.EdgeColor = 'none';
    anno.FitBoxToText = "on";
    anno.Position = [-0.00,0.9,0.094,0.062];
    anno.Interpreter = "latex";
    anno.String = options.labels.mem_state_legend;
    anno.HorizontalAlignment = "center";
    anno.VerticalAlignment = "middle";
    anno.FontSize = 14;
    
    
    nexttile(tl,2);
    imagesc([min(data.in) max(data.in)],[min(data.x) max(data.x)],log10(data.Mem_in_fine'));
    colormap(col_turbo_no_dark);
    hold on;
    [C,h] = contour(data.in_fine_grid,data.x_fine_grid,log10(data.Mem_in_fine),log10(options.contour_levels),'EdgeColor',[0 0 0]);
    hold off;
    clabel(C,h,'Interpreter','latex','LabelSpacing',1000,'FontSize',16);
    h.LabelFormat = @(x) compose('%.2g k$\\Omega$', 10.^x);
    grid on;

    ax=gca;
    ax.FontSize = fontsize_axis;
    ax.XMinorGrid = "on";
    ax.YMinorGrid = "on";
    ax.XTick = linspace(min(data.in_DRM), max(data.in_DRM),5);
    ax.YTick = 0:.2:1;
    ax.YLabel.String = options.labels.mem_state;
    ax.YLabel.Interpreter = "latex";
    ax.YLabel.FontSize = fontsize_labels;
    ax.XLabel.String = options.labels.input;
    ax.XLabel.Interpreter = "latex";
    ax.XLabel.FontSize = fontsize_labels;
    ax.YDir = "normal";
    clb = colorbar();
    clb.Label.Interpreter = "latex";
    clb.Label.String = 'Memristance (k$\Omega$)';
    clb.Label.FontSize = fontsize_axis;
    tickies = log10(options.my_ticks);
    clb.Ticks = tickies;
    clb.TickLabels = arrayfun(@(v) sprintf('%.3g', 10.^v), tickies, 'UniformOutput', false);
end

function add_single_SDR_arrows(line_hdl)
    X = line_hdl.XData;
    Y = line_hdl.YData;
    num_of_arrows = 3;

    arrow_centers = linspace(1,length(X),num_of_arrows+2);
    arrow_centers([1 end]) = [];

    for i_arrow = 1:length(arrow_centers)
        if Y(arrow_centers(i_arrow))>0
            % anno = annotation("arrow");
            % anno.Parent = gca;
            % anno.X = [X(arrow_centers(i_arrow)-25) X(arrow_centers(i_arrow)+25)];
            % anno.Y = [Y(arrow_centers(i_arrow)-25) Y(arrow_centers(i_arrow)+25)];
            % anno.Color = line_hdl.Color;
            % anno.HeadStyle = "vback3";
            h = arrow([X(arrow_centers(i_arrow)-5) Y(arrow_centers(i_arrow)-5)],...
                        [X(arrow_centers(i_arrow)+5) Y(arrow_centers(i_arrow)+5)],...
                        'Color',line_hdl.Color,'BaseAngle',25);
            h.HandleVisibility = "off";
        elseif Y(arrow_centers(i_arrow))<0
            % anno = annotation("arrow");
            % anno.Parent = gca;
            % anno.X = [X(arrow_centers(i_arrow)+25) X(arrow_centers(i_arrow)-25)];
            % anno.Y = [Y(arrow_centers(i_arrow)+25) Y(arrow_centers(i_arrow)-25)];
            % anno.Color = line_hdl.Color;
            % anno.HeadStyle = "vback3";
            h = arrow([X(arrow_centers(i_arrow)+5) Y(arrow_centers(i_arrow)+5)],...
                        [X(arrow_centers(i_arrow)-5) Y(arrow_centers(i_arrow)-5)],...
                        'Color',line_hdl.Color,'BaseAngle',25);
            h.HandleVisibility = "off";
        end
    end

end
function SDR_arrows(hdl_lines)
    for i_ln = 1:length(hdl_lines)
        add_single_SDR_arrows(hdl_lines(i_ln));
    end
end