% Now create subplots to display them together
figure;

% Subplot 1 for Signal
subplot(2, 2, 1);  % 2 rows, 1 column, 1st subplot
plot_signal();

% Subplot 2 for Response
subplot(2, 1, 2);  % 2 rows, 1 column, 2nd subplot
plot_response_test();
%%
[x,z,ma] = create_figure(2);
%%
figure;
numberOfchannels = 2;
for k = 1:numberOfchannels  % Loop over channels

    % Subplot 1 for Signal
    subplot(2, 2, (k-1)*2 + 1);  % Adjust the index for subplot 1
    plot_signal();

    % Subplot 2 for Response
    subplot(2, 2, (k-1)*2 + 2);  % Adjust the index for subplot 2
    plot_response_test();
end
%%

% Create a figure
f = figure; % Adjust width and height as needed
pos1 = f.Position(1)-f.Position(1)/2;
pos2 = f.Position(2)-f.Position(2)/2;
f.Position(1:4) = [pos1,pos2,1600,800];


% Define the number of channels
numberOfchannels = 5;

% Define the margins and gaps
leftMargin = 0.1;
rightMargin = 0.1;
topMargin = 0.1;
bottomMargin = 0.1;
horizontalGap = 0.05;
verticalGap = 0.1;

% Calculate the total width and height available for subplots
totalWidth = 1 - leftMargin - rightMargin - (numberOfchannels - 1) * horizontalGap;
totalHeight = 1 - topMargin - bottomMargin - verticalGap;

% Calculate the width and height of each subplot
subplotWidth = totalWidth / numberOfchannels;
subplotHeight = totalHeight / 2; % Two rows

for k = 1:numberOfchannels  % Loop over channels

    % Calculate the position for subplot 1 (Signal)
    xPos1 = leftMargin + (k-1) * (subplotWidth + horizontalGap);
    yPos1 = 1 - topMargin - subplotHeight;
    signalPosition = [xPos1, yPos1, subplotWidth, subplotHeight];

    % Calculate the position for subplot 2 (Response)
    xPos2 = leftMargin + (k-1) * (subplotWidth + horizontalGap);
    yPos2 = bottomMargin;
    responsePosition = [xPos2, yPos2, subplotWidth, subplotHeight];

    % Subplot 1 for Signal
    subplot('Position', signalPosition);
    plot_signal();
    title('Signal');  % Add title for clarity

    % Subplot 2 for Response
    subplot('Position', responsePosition);
    plot_response_test();
    title('Response');  % Add title for clarity
end



%%
numberOfrepetitions = 3; %i value
numberOfcurrents = 2; %j value
numberOfchannels =2;

all_responses = cell(numberOfcurrents, numberOfrepetitions,numberOfchannels); % jxixn array of responses

for j = 1: numberOfcurrents    % Need to be increased

    for i = 1: numberOfrepetitions  % Number of repetitions
        f = figure; % Adjust width and height as needed
        pos1 = f.Position(1)-f.Position(1)/2;
        pos2 = f.Position(2)-f.Position(2)/2;
        f.Position(1:4) = [pos1,pos2,1600,800];


        % Define the number of channels
        numberOfchannels = 5;

        % Define the margins and gaps
        leftMargin = 0.1;
        rightMargin = 0.1;
        topMargin = 0.1;
        bottomMargin = 0.1;
        horizontalGap = 0.05;
        verticalGap = 0.1;

        % Calculate the total width and height available for subplots
        totalWidth = 1 - leftMargin - rightMargin - (numberOfchannels - 1) * horizontalGap;
        totalHeight = 1 - topMargin - bottomMargin - verticalGap;

        % Calculate the width and height of each subplot
        subplotWidth = totalWidth / numberOfchannels;
        subplotHeight = totalHeight / 2; % Two rows

        for k = 1:numberOfchannels  % Loop over channels

            % Calculate the position for subplot 1 (Signal)
            xPos1 = leftMargin + (k-1) * (subplotWidth + horizontalGap);
            yPos1 = 1 - topMargin - subplotHeight;
            signalPosition = [xPos1, yPos1, subplotWidth, subplotHeight];

            % Calculate the position for subplot 2 (Response)
            xPos2 = leftMargin + (k-1) * (subplotWidth + horizontalGap);
            yPos2 = bottomMargin;
            responsePosition = [xPos2, yPos2, subplotWidth, subplotHeight];

 
            subplot('Position', responsePosition);
            plot_response(all_responses(j, :,k),current);
            title(['Response of ', channelNames{k}]);
        end

    end
end

% figure;
%         for k = 1:numberOfchannels  % Loop over channels
% 
% 
%             % Subplot 1 for Signal
%             subplot(2, 2, (k-1)*2 + 1);
%             all_responses{j, i,k} = response;
%             plot_response(all_responses(j, :,k),current);
% 
% 
%         end