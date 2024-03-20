function plot_response(responses, current)

        % Create a figure
        figure;

        % Convert to logical array
        bool_resp = strcmp(responses, 'reflex response');

        % Define colors based on responses
        colors = cell(size(bool_resp));
        colors(bool_resp) = {'g'}; % Green for true
        colors(~bool_resp) = {'r'}; % Red for false

        % Define number of dots
        num_dots = numel(bool_resp);

        % Create dots
        x = linspace(0.1, 0.9, num_dots); % Evenly spaced x coordinates
        y = repmat(0.3, 1, num_dots); % y coordinates for dots (all at y = 0.3)

        % Plot colored dots
        for i = 1:num_dots
            scatter(x(i), y(i), 1500, colors{i}, 'filled');
            hold on;
        end

        % Create legend entries
        legend_entries = cell(1, num_dots);
        for i = 1:num_dots
            if bool_resp(i)
                legend_entries{i} = ['Dot ' num2str(i) ': True'];
            else
                legend_entries{i} = ['Dot ' num2str(i) ': False'];
            end
        end

        % Add legend
        %legend(legend_entries, 'Location', 'north', 'FontSize', 14);

        % Add free text
        str = ['RESPONSE FOR CURRENT', num2str(current)];
        text(0.5, 0.7, str, 'FontSize', 12, 'HorizontalAlignment', 'center');

        % Set axis limits
        xlim([0 1]);
        ylim([0 1]);

        % Hide axis ticks and labels
        axis off;


end

