function f = create_figure(bool_recording)
    %CREATE_FIGURE Summary of this function goes here
    %   Detailed explanation goes here
    
    
    % Draw the figure off-screen to prevent display
    %f = figure('Visible', 'off'); % Adjust width and height as needed
    % f = figure;
    % pos1 = f.Position(1) - f.Position(1) / 2;
    % pos2 = f.Position(2) - f.Position(2) /1.1;
    % f.Position(1:4) = [pos1, pos2, 1200, 1200];

    f = figure;

    % Get screen size
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);

    % Calculate the figure size as a fraction of the screen size
    figureWidthFraction = 0.6;  % 60% of screen width
    figureHeightFraction = 0.8; % 80% of screen height

    figureWidthFraction = 1;  % 60% of screen width
    figureHeightFraction = 0.85; % 80% of screen height

    figWidth = screenWidth * figureWidthFraction;
    figHeight = screenHeight * figureHeightFraction;

    % Calculate the position of the figure at the center of the screen
    posX = (screenWidth - figWidth) / 2;
    posY = (screenHeight - figHeight) / 2;

    % Set figure position and size
    f.Position = [posX, posY, figWidth, figHeight];

    if bool_recording
        %Add text annotation for recording message
        recordingMsg = 'Recording in Progress...';
        annotation('textbox', [0.4, 0.4, 0.2, 0.1], 'String', recordingMsg, ...
            'FontSize', 16, 'FontWeight', 'bold', 'LineStyle', '-', ...
            'EdgeColor', 'k', 'LineWidth', 1.5, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'Color', 'r', 'BackgroundColor', 'w');
    end

    
    % % Make the figure visible
    % f.Visible = 'on';
end
