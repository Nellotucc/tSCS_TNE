% USE THIS FUNCTION FOR THE OLD DATA, I CREATE A NEW FILE THAT WILL WORK
% ONLY WITH THE NEW DATA best_electrode_finder_nd


%needs manual adjustements based on the data file since we recorded with
%different names at the beginning
%other problem is the t_0 plugged in assumes that no other artifact is
%bigger than the t_0. We need to save the t_0 in the file name.

function [best_electrode] = best_electrode_finder(directories,current_i, current_f,interpulse_duration, num_repetitions,muscle, bool_plot,control)
% This function return the best electrode (file path for now) for
% activating the muscles. It can be either muscle specific or conventional.
%
% INPUTS :
% directories : input directories of data
% current_i : initial current
% current_f : final current
% num_repetitinos : number of repetitions
% muscle : 'conventional','ipsilateral','rostrocaudal', 'RF', 'RF_L',
% 'RF_R'... 
% bool_plot : to plot the recruitement curve
%
% OUTPUTS :
% best_electrode : directory name of the best found electrode
%
% For now this code will only go in the cases conventional, ipsilateral and
% rostrocaudal but to have muscle specific only needs a bit more if statements.


% Assert that the muscle input is valid
assert(strcmp(muscle, 'conventional') || strcmp(muscle, 'ipsilateral') || strcmp(muscle, 'rostrocaudal'), 'Invalid muscle input. Valid options are ''conventional'', ''ipsilateral'', or ''rostrocaudal''.');

% initial parameters
sf = 1000;
if interpulse_duration>1000
    interpulse_duration = interpulse_duration/1000;
end
% EMG preprocessing
selected_filters = 3;
paper_nb = 1;
if control == true
    bool_plot_MEP = true;
else
    bool_plot_MEP = false;
end
num_currents = (current_f - current_i) / 5 + 1;

% Initialize a cell array to store all the EMG data properties : amplitude,
% std, response, 4 conditions:
% 1.
% At least two reflex responses in the muscles
% 2.
% Largest number of reflex responses;
% 3.
% Smallest current level difference between stimulation amplitude I and
% 𝐼′, at which the first green label was obtained (amplitude threshold);
% 4.
% Lowest stimulation amplitude I.

amplitudes_all_dir = cell(numel(directories),num_currents);
amplitude_std_all_dir = cell(numel(directories),num_currents);
responses_all_dir = cell(numel(directories),num_currents);
% Iterate over directories
for dir_index = 1:numel(directories)
    directory = directories{dir_index};

    % Iterate over different current values
    for current_index = 1:num_currents
        current = current_i + (current_index - 1) * 5; % Compute current value
        amplitudes_all_reps = zeros(1, num_repetitions);
        responses_all_reps = zeros(1, num_repetitions);

        % Iterate over repetitions
        for repetition = 1:num_repetitions
            % Construct the filename based on the current value and repetition number
            muscle='RF'; %not used in this file but just to make the function find emg work
            file_path = find_emg_filename(directory,muscle,current, repetition,interpulse_duration);
            
            % Load the file
            emg_struct = load(file_path);

            % Get the list of variable names inside the structure array
            variable_names = fieldnames(emg_struct);

            % Access the first variable
            emg = emg_struct.(variable_names{1});
            numberOfValues = length(emg);

            % When possible extract the t_0 directly from the file name

            % Find the index of '_t0'
            t0_index = strfind(file_path, '_t0');

            % Extract the t0 part
            if ~isempty(t0_index)
                t0_str = file_path(t0_index+3:end-4); % Extract from after '_t0' to before '.mat'
                t_0 = str2double(t0_str); % Convert the extracted string to a numeric value
            else
                %disp('The file name does not contain "_t0" substring.');
                [~, t_0] = max(abs(emg));

            end

            if bool_plot_MEP == true
                figure;
            end
            [response, p2p_amplitude] = Signal_analysis(t_0, double(emg), sf, selected_filters, false, false, 1, false, paper_nb, interpulse_duration*1000,bool_plot_MEP, numberOfValues);
            amplitudes_all_reps(repetition) = p2p_amplitude;
            responses_all_reps(repetition) = response2binary({response});


        end
        % Calculate mean and standard deviation
        amplitudes_all_dir{dir_index, current_index} = mean(amplitudes_all_reps);
        amplitude_std_all_dir{dir_index, current_index} = std(amplitudes_all_reps);
        %responses_all_dir{dir_index, current_index} = binary2response(round(mean(responses_all_reps))); % it will save reflex response or not reflex response based on the average responses
        responses_all_dir{dir_index, current_index} = round(mean(responses_all_reps)); % it will save 1 : reflex response or 0 : not reflex response based on the average responses

    end

    %HERE WE SHOULD STOCK THE INFORMATION TO COMPARE FOR EACH DIRECTORY :
    
end
best_electrode = 1;

if bool_plot == true
    show_std = false;
    plot_recruitement_curve(directories,amplitudes_all_dir,amplitude_std_all_dir,show_std,current_i,current_f)
end
responses_all_dir
amplitudes_all_dir
end

