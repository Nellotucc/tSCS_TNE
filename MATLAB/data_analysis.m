%% Variables needed for plotting

selectedChannels = {1};
sf = 1000;
interpulse_duration = 50; % us - ms --- for Double pulse. 
numberOfValues = 5000;
% EMG preprocessing
plot_chs = false;
bool_plot_PSD = false;
selected_filters = 3;
paper_nb = 1;

% MEP detection
bool_plot_MEP = true;
bool_colour_response = false;

%% Single Load
emg_1 = load('/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/black/emg_current35_repetition3_window5s_interpulse50.mat');
emg_1 = emg_1.emg_data;
figure;
plot(emg_1)
figure;
[~, t_0] = max(abs(emg_1));
disp(t_0)
[response,p2p_amplitude] = Signal_analysis(t_0,double(emg_1),sf,selected_filters, 0, plot_chs, selectedChannels{1}, bool_plot_PSD, paper_nb, interpulse_duration*1000, bool_plot_MEP,numberOfValues);
p2p_amplitude
%% Many loads
% Initialize a cell array to store all the loaded EMG data
current_i = 25;
current_f = 65;
num_currents = (current_f - current_i) / 5 + 1;
num_repetitions = 2;
emg_data = cell(num_repetitions, num_currents);
amplitudes = cell(1,num_currents);

% Define the directory where your files are located

directory = '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow2/';
%directory = '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/big_electrode/T12-L1/';

% Iterate over different current values
for current_index = 1:num_currents
    current = current_i + (current_index - 1) * 5; % Compute current value
    amplitude = 0;
    % Iterate over repetitions
    for repetition = 1:num_repetitions
        % Construct the filename based on the current value and repetition number
        filename = sprintf('emg_current%d_repetition%d_window5s_interpulse50.mat', current, repetition+1);
        
        % Load the file
        file_path = fullfile(directory, filename);
        emg_struct = load(file_path);
        
        % Extract the EMG data and store it in the cell array
        emg = emg_struct.emg_data;
        emg_data{repetition, current_index} = emg ;

        [~, t_0] = max(abs(emg));
    
        [response,p2p_amplitude] = Signal_analysis(t_0,double(emg),sf,selected_filters, 0, plot_chs, selectedChannels{1}, bool_plot_PSD, paper_nb, interpulse_duration*1000, false,numberOfValues);
        amplitude = amplitude+p2p_amplitude;
        disp(filename)

       
    end
    amplitudes{1,current_index} = amplitude/num_repetitions;
end

% Now emg_data contains all the loaded EMG data for different current values and repetitions
%% PLOT RECRUITEMENT CURVE
% Define the range of current values
current_values = current_i:5:current_f;

% Extract the amplitudes from the cell array
amplitude_values = cell2mat(amplitudes);

% Plot the amplitudes against current values
plot(current_values, amplitude_values, 'o-');

% Add labels and title
xlabel('Current (mA)');
ylabel('Amplitude');
title('Amplitude vs Current');

% Show grid
grid on;
%%
% Define directories
directories = {
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow1/', '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow2/', '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow3/'
};

% Initialize figure
figure;
hold on;

% Iterate over directories
for dir_index = 1:numel(directories)
    directory = directories{dir_index};
    
    % Initialize a cell array to store all the loaded EMG data
    current_i = 25;
    current_f = 65;
    num_currents = (current_f - current_i) / 5 + 1;
    num_repetitions = 2;
    amplitudes = cell(1, num_currents);

    % Iterate over different current values
    for current_index = 1:num_currents
        current = current_i + (current_index - 1) * 5; % Compute current value
        amplitude = 0;
        % Iterate over repetitions
        for repetition = 1:num_repetitions
            % Construct the filename based on the current value and repetition number
            filename = sprintf('emg_current%d_repetition%d_window5s_interpulse50.mat', current, repetition+1);

            % Load the file
            file_path = fullfile(directory, filename);
            emg_struct = load(file_path);

            % Extract the EMG data and store it in the cell array
            emg = emg_struct.emg_data;

            [~, t_0] = max(abs(emg));

            [response, p2p_amplitude] = Signal_analysis(t_0, double(emg), sf, selected_filters, 0, plot_chs, selectedChannels{1}, bool_plot_PSD, paper_nb, interpulse_duration*1000, false, numberOfValues);
            amplitude = amplitude + p2p_amplitude;
            disp(filename)
        end
        amplitudes{1, current_index} = amplitude / num_repetitions;
    end
    
    % Plotting for current directory
    current_values = 25:5:65;
    amplitude_values = cell2mat(amplitudes);
    plot(current_values, amplitude_values, 'o-', 'DisplayName', sprintf('Directory %d', dir_index));
end

% Add labels and title
xlabel('Current (mA)');
ylabel('Amplitude');
title('Amplitude vs Current');
legend('show');
grid on;
hold off; % Release the hold on the plot

%% FULL PROTOCOL FROM LOADING DIRECTORIES TO PLOTTING RESPONSES
% Define directories
directories = {
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow1/', 
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow2/', 
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow3/',
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/black/'
};
%directories = {'/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow3_ipsilateral/real_time_channel2/','/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow3_ipsilateral/yellow1/'};

% Initialize figure
figure;
hold on;
show_std = true;

% Colors for shading
colors = {'b', 'y','g'}; % You can adjust colors as needed
%colors = { [44, 160, 44] / 255, [148, 103, 189] / 255, [140, 86, 75] / 255, [227, 119, 194] / 255, [127, 127, 127] / 255, [188, 189, 34] / 255, [23, 190, 207] / 255};
colors = {[31, 120, 180] / 255, ...  % Dark blue
          [255, 127, 0] / 255, ...   % Dark orange
          [106, 61, 154] / 255,...   % Dark purple
          [166, 206, 227] / 255, ... % Light blue
          [253, 191, 111] / 255, ... % Light orange
          [202, 178, 214] / 255, ... % Light purple
          [178, 223, 138] / 255, ... % Light green
          [51, 160, 44] / 255, ...   % Dark green
          [251, 154, 153] / 255, ... % Light red
          [227, 26, 28] / 255};   % Dark red

% Iterate over directories
for dir_index = 1:numel(directories)
    directory = directories{dir_index};
    
    % Initialize a cell array to store all the loaded EMG data
    current_i = 20;
    current_f = 65;
    num_currents = (current_f - current_i) / 5 + 1;
    num_repetitions = 2;
    amplitudes = cell(1, num_currents);
    amplitude_std = cell(1, num_currents);

    % Iterate over different current values
    for current_index = 1:num_currents
        current = current_i + (current_index - 1) * 5; % Compute current value
        amplitudes_all_reps = zeros(1, num_repetitions);

        % Iterate over repetitions
        for repetition = 1:num_repetitions
            % Construct the filename based on the current value and repetition number
            filename = sprintf('emg_current%d_repetition%d_window5s_interpulse50.mat', current, repetition+1);

            % Load the file
            file_path = fullfile(directory, filename);
            emg_struct = load(file_path);

            % Extract the EMG data and store it in the cell array
            emg = emg_struct.emg_data;

            [~, t_0] = max(abs(emg));

            [response, p2p_amplitude] = Signal_analysis(t_0, double(emg), sf, selected_filters, 0, plot_chs, selectedChannels{1}, bool_plot_PSD, paper_nb, interpulse_duration*1000, false, numberOfValues);
            amplitudes_all_reps(repetition) = p2p_amplitude;
    

        end
        % Calculate mean and standard deviation

        amplitudes{1, current_index} = mean(amplitudes_all_reps);
        amplitude_std{1, current_index} = std(amplitudes_all_reps);
    end
    
    % Plotting for current directory
    current_values = current_i:5:current_f;
    amplitude_values = cell2mat(amplitudes);
    amplitude_std_values = cell2mat(amplitude_std);
    if show_std
        fill([current_values, fliplr(current_values)], [amplitude_values + amplitude_std_values, fliplr(amplitude_values - amplitude_std_values)], colors{dir_index}, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
    end

   plot(current_values, amplitude_values, '-', 'Color', colors{dir_index}, 'LineWidth', 2, 'DisplayName', sprintf('Directory %d', dir_index));
end

% Add labels and title
xlabel('Current (mA)');
ylabel('Amplitude');
title('Amplitude vs Current');
legend('show');
grid on;
hold off; % Release the hold on the plot
