function plot_response(responses, current)
    % Define number of dots
    num_dots = numel(responses);

    if isempty(responses)
        % If responses is empty, fill dots in gray
        scatter(linspace(0.1, 0.9, num_dots), repmat(0.3, 1, num_dots), 1500, 'k', 'filled'); % Fill dots in gray
    else
        % Define colors based on responses
        colors = cell(size(responses));
        for i = 1:num_dots
            if isempty(responses{i})
                colors{i} = 'k'; % Gray for empty response
            elseif strcmp(responses{i}, 'reflex response')
                colors{i} = 'g'; % Green for reflex response
            else 
                colors{i} = 'r'; % Red for not reflex response
            end
        end

        % Create dots
        x = linspace(0.1, 0.9, num_dots); % Evenly spaced x coordinates
        y = repmat(0.3, 1, num_dots); % y coordinates for dots (all at y = 0.3)

        % Plot colored dots
        for i = 1:num_dots
            scatter(x(i), y(i), 1500, colors{i}, 'filled');
            hold on;
        end
    end

    % Add free text
    str = ['RESPONSE FOR CURRENT', num2str(current)];
    text(0.5, 0.7, str, 'FontSize', 12, 'HorizontalAlignment', 'center');

    % Set axis limits
    xlim([0 1]);
    ylim([0 1]);

    % Hide axis ticks and labels
    axis off;

end
