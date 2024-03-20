%%
all_responses = {};

for i = 1:2
    response = {};  % Initialize response cell array for each i
    for j = 1:4
        response = [response,'reflex response'];  % Use comma and {} to horizontally concatenate
    end
    all_responses = [all_responses; response];  % Wrap the entire response in {}
end

disp(all_responses(1,:))
length(all_responses(1,:))

bool_resp = strcmp(all_responses(1,:), 'reflex response');

disp(bool_resp)

%%

% Create a figure
figure;

% Define the initial array
reflex_array = {'reflex response', 'reflex response', 'no reflex', 'reflex response'};

% Convert to logical array
responses = strcmp(all_responses(1,:), 'reflex response');

% Define colors based on responses
colors = cell(size(responses));
colors(responses) = {'g'}; % Green for true
colors(~responses) = {'r'}; % Red for false

% Define number of dots
num_dots = numel(responses);

% Create dots
x = linspace(0.1, 0.9, num_dots); % Evenly spaced x coordinates
y = repmat(0.3, 1, num_dots); % y coordinates for dots (all at y = 0.3)

% Plot colored dots
for i = 1:num_dots
    scatter(x(i), y(i), 2000, colors{i}, 'filled');
    hold on;
end

% Create legend entries
legend_entries = cell(1, num_dots);
for i = 1:num_dots
    if responses(i)
        legend_entries{i} = ['Dot ' num2str(i) ': True'];
    else
        legend_entries{i} = ['Dot ' num2str(i) ': False'];
    end
end

% Add legend
%legend(legend_entries, 'Location', 'north', 'FontSize', 14);

% Add free text
%text(0.5, 0.7, 'Free Text Here', 'FontSize', 12, 'HorizontalAlignment', 'center');

% Set axis limits
xlim([0 1]);
ylim([0 1]);

% Hide axis ticks and labels
axis off;

