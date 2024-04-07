function [response] = ActionPotDetectDoublePulse(muscle_loc,emg_data,sf,interpulse_duration,values_before_stim,norm_factor_afterfilter,bool_plot_MEP,bool_colour_response)

clf;
numberOfValues = length(emg_data);
noise_std = std((emg_data(numberOfValues-600:numberOfValues))); %take the noise on the last 600 number of values.
noise_std_2 = std((emg_data(numberOfValues-600:numberOfValues)));


if muscle_loc == "proximal"
    muscle_reflex_delay = 10*sf/1000;
else
    muscle_reflex_delay = 20*sf/1000;
end

% Search AP only around the stimulation instants
% create the search_pos boundaries for first response and second response
search_pos_begin_1 = muscle_reflex_delay+values_before_stim-10;    % start at the stimulation time (t = 0) + muscle delay -10 empirical value to get signal a bit before muscle response
search_pos_end_1 = search_pos_begin_1+35;   % range around stim pulse 1
search_pos_begin_1 = max(1, min(search_pos_begin_1, numel(emg_data)));
search_pos_end_1 = max(1, min(search_pos_end_1, numel(emg_data)));
disp(interpulse_duration);
search_pos_begin_2 = search_pos_begin_1+interpulse_duration; %in theory this should start a bit before the second response
search_pos_end_2 = search_pos_begin_2+35;   % range around stim pulse 2
search_pos_begin_2 = max(1, min(search_pos_begin_2, numel(emg_data)));
search_pos_end_2 = max(1, min(search_pos_end_2, numel(emg_data)));

%NOTE : the window may overlap for now if the interpule_duration is smaller
%than 40ms; RECHECK : PAS SUR APRES MODIF

p2p_amplitude_1 = peak2peak(emg_data(search_pos_begin_1:search_pos_end_1));

p2p_amplitude_2 = peak2peak(emg_data(search_pos_begin_2:search_pos_end_2));


suppression_level = 1-p2p_amplitude_2/p2p_amplitude_1;


%classification based on the paper automated response
threshold_amp = 50/norm_factor_afterfilter;
%threshold_amp = 5*noise_std;

threshold_supp_level = 0.6;
noise_threshold = 10*noise_std;

if p2p_amplitude_1 <= threshold_amp || p2p_amplitude_1 <= noise_threshold %to be changed in microvolts
    response = 'no response';
elseif p2p_amplitude_1 >= threshold_amp && p2p_amplitude_1 >= noise_threshold && suppression_level > threshold_supp_level
    response = 'reflex response';
elseif p2p_amplitude_1 >= threshold_amp && p2p_amplitude_1 >=noise_threshold && suppression_level < threshold_supp_level
    response = 'presumed M-wave';
else
    response = 'invalid response';
end

%PLOTTING
if bool_plot_MEP

    % Plot the signal
    figure;
    %h1 = plot(emg_data(1:1000,:), 'm', 'LineWidth', 1);
    h1 = plot(emg_data(:,:), 'm', 'LineWidth', 1);

    hold on;
    patch([search_pos_begin_1, search_pos_end_1, search_pos_end_1, search_pos_begin_1], ...
          [min(emg_data), min(emg_data), max(emg_data), max(emg_data)], 'y', 'FaceAlpha', 0.3);
    patch([search_pos_begin_2, search_pos_end_2, search_pos_end_2, search_pos_begin_2], ...
          [min(emg_data), min(emg_data), max(emg_data), max(emg_data)], 'y', 'FaceAlpha', 0.3);
    disp(search_pos_begin_1);
    disp(search_pos_end_1);

    disp(search_pos_begin_2);
    disp(search_pos_end_2);

    % Add a straight line y = 6*std_noise
    y_line = 10*noise_std; 
    x_line = linspace(1, 1000, 1000); % Adjust the range as needed
    h2 = plot(x_line, ones(size(x_line)) * y_line, 'r--', 'LineWidth', 1);

    % Add a straight line y = 6*std_noise_2
    y_line = 6*noise_std_2; 
    x_line = linspace(1, 1000, 1000); % Adjust the range as needed
    h3 = plot(x_line, ones(size(x_line)) * y_line, 'y--', 'LineWidth', 1);

    % Add a straight line for suppression threshold
    y_line = (1-threshold_supp_level)*p2p_amplitude_1; 
    x_line = linspace(1, 1000, 1000);
    h4 = plot(x_line, ones(size(x_line)) * y_line, 'b--', 'LineWidth', 2);

    % Add a straight line for p2p amplitude threshold
    y_line = threshold_amp;
    x_line = linspace(1, 1000, 1000);
    h5 = plot(x_line, ones(size(x_line)) * y_line, 'g--', 'LineWidth', 2);

    % Add two straight lines at x = 10 and x = 17
    h6 = plot([search_pos_begin_1+10, search_pos_begin_1+10], [p2p_amplitude_1, 0], 'k-', 'LineWidth', 2);
    h7 = plot([search_pos_begin_2+10, search_pos_begin_2+10], [p2p_amplitude_2, 0], 'k-', 'LineWidth', 2);

    grid on;
    
    % Add legend
    legend([h1, h2, h3, h4, h5, h6, h7], 'EMG signal', '10*std noise', '6*std noise', 'suppression level threshold', 'amplitude threshold', 'Line at x=10', 'Line at x=17');
    
    % Customize plot
    title('EMG signal');
    xlabel('Time');
    ylabel('Signal Value');
    hold off;
end




if bool_colour_response
    if strcmp(response, 'reflex response')
        
        % Create a green filled rectangle
        figure;
        rectangle('Position', [0, 0, 1, 1], 'FaceColor', 'g');
        axis equal; % Maintain equal scaling on both axes
        axis off;   % Turn off the axis for a cleaner appearance
    else
        % Create a red filled rectangle
        figure;
        rectangle('Position', [0, 0, 1, 1], 'FaceColor', 'r');
        axis equal;
        axis off;
    
    
    end
end    



%HOW TO MAKE SURE ITS AN AP AND
% NOT JUST 2 ARTIFCATS.