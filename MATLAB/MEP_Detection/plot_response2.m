function plot_response2(responses, current, subplotWidth, subplotHeight)
    % Define number of dots
    num_dots = numel(responses);
    
    scaling_factor = min(subplotWidth, subplotHeight)*2;
    % Define dot size based on subplot dimensions
    dotSize = scaling_factor * 1500;
    disp("SCALING BBY")
    disp(scaling_factor)

    if isempty(responses)
        % If responses is empty, fill dots in gray
        scatter(linspace(0.1, 0.9, num_dots), repmat(0.3, 1, num_dots), dotSize, 'k', 'filled'); % Fill dots in gray
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
            scatter(x(i), y(i), dotSize, colors{i}, 'filled');
            hold on;
        end
    end

    % Add free text
    str = ['CURRENT ', num2str(current)];

    % Calculate font size based on subplot height
    fontSize = scaling_factor * 40;

    text(0.5, 0.7, str, 'FontSize', fontSize, 'HorizontalAlignment', 'center');

    % Set axis limits
    xlim([0 1]);
    ylim([0 1]);

    % Hide axis ticks and labels
    axis off;
end
