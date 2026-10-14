function [plot_handles] = plot_drm1_general(dX1dt_grid, X1_grid, color_current)
    % PLOT_DRM1_COMP - Plot dX1/dt vs. X1
    %
    % Inputs:
    %   dX1dt_grid          - Grid of dX1/dt values.
    %                         Dimensions: M x k
    %                                     M: Number of points per SDR
    %                                     k: Number of different SDRs
    %   X1_grid             - Grid of X1 values.
    %                         Dimensions: M x 1
    %   color_current      - Color for the current parameter sweep.
    %                         Dimensions: k x 3
    %
    % Outputs:
    %   plot_handles       - Structure containing handles to the plotted lines.

    % Initialize plot handles structure
    plot_handles = struct('SDR', [], 'Equilibrium', []);

    M = size(dX1dt_grid,1);
    k = size(dX1dt_grid,2);

    if size(dX1dt_grid,1)~=M
        error('Dimensions error! dX1dt_grid should be M x k and X1_grid should be M x 1.');
    end

    
    h = plot(X1_grid, dX1dt_grid, 'LineWidth', 1.0);
    % colormap(color_current);
    plot_handles.SDR = [plot_handles.SDR; h];

    % % Plot equilibrium points
    % for idx = 1:length(state_to_plot)
    %     state_current = state_to_plot(idx);
    %     [~, state_idx] = min(abs(state_variable_vals - state_current));
    %     dX1dt = dX1dt_grid(state_idx, :);
    %     X1_vals = X1_grid(1, :);
    % 
    %     [X1_eq, stability] = find_equilibrium_points_drm1(dX1dt, X1_vals);
    %     for k = 1:length(X1_eq)
    %         if stability(k) < 0
    %             h = plot(X1_eq(k), 0, 'o', 'MarkerFaceColor', color_current, 'MarkerEdgeColor', 'k', 'MarkerSize', 6, 'HandleVisibility', 'off');
    %         else
    %             h = plot(X1_eq(k), 0, 'o', 'MarkerEdgeColor', 'k', 'MarkerSize', 6, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    %         end
    %         plot_handles.Equilibrium = [plot_handles.Equilibrium; h];
    %     end
    % end

    % Add xline and yline for axes without showing in the legend
    xline(0, 'k', 'LineWidth', 0.5, 'HandleVisibility', 'off');
    yline(0, 'k', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

% % Helper function remains the same
% function [X1_eq, stability] = find_equilibrium_points_drm1(dX1dt, X1_vals)
%     X1_eq = [];
%     stability = [];
% 
%     % Compute the product of consecutive dX1/dt values
%     X1_product = dX1dt(1:end-1) .* dX1dt(2:end);
%     for j = 1:length(X1_product)
%         if X1_product(j) <= 0
%             % Zero-crossing point
%             X1_cross = (X1_vals(j) + X1_vals(j+1)) / 2;
%             X1_eq = [X1_eq; X1_cross];
% 
%             % Determine stability
%             if dX1dt(j) < 0
%                 stability = [stability; 1]; % Unstable
%             else
%                 stability = [stability; -1]; % Stable
%             end
%         end
%     end
% end