% possible problems :
% 1) Might not find right peaks if there is a higher peak than the artifacts
% since it sort of makes the assumption that the 2 highest peaks in the
% signal are artifacts. If the patient moves it will make it impossible to
% detect.
% 2) The (abs(diff(top_two_peaks))<=noise_level) might need to be fine tuned 
% to see which value gives the sense of "approximately same height" no matter
% the scale. Could maybe do 2nd peak should be between 3/4 and 5/4 amplitude 
% of first one so we keep the scale.

function [not_found, time,t_0]= StimPulseDetection2(emg_data,interpulse_duration,sf)
    % This function calculates the time of the first peak of the
    % stimulation artifact t_0.

    % Calculate the standard deviation for each channel
    channel_std = std(emg_data);
    
    % Find the channel index with the minimum standard deviation
    [~, best_channel_idx] = min(channel_std);

    

    %total length of window
    n_samples = length(emg_data(:,best_channel_idx));

    % Calculate the noise level (adjust this based on your signal characteristics)
    noise_level = channel_std(best_channel_idx);
    

    % Set the threshold for peak detection
    threshold_factor = 6; % Adjust this factor based on noise level
    threshold = threshold_factor * noise_level;
    
    % Define the error margin for interpulse_duration
    error_margin = 2; % 
    
    % Find peaks in the signal
    [peaks, locations] = findpeaks(emg_data(:,best_channel_idx));
    
    % Sort peaks in descending order and take the top two
    [~, sorted_indices] = sort(peaks, 'descend');
    top_two_peaks = peaks(sorted_indices(1:2));
    top_two_locations = locations(sorted_indices(1:2));

    % Find peaks with approximately the same height, above the threshold and within the interframe_duration
    valid_peaks = (abs(diff(top_two_peaks))<=noise_level) & (top_two_peaks > threshold) & (abs(abs(diff(top_two_locations)/sf*1000) - interpulse_duration) <= error_margin);

    time_threshold = n_samples-200;
    t_0 = min(top_two_locations);

    disp(["stim artifact found at t : ", num2str(t_0)]);
    
    % Check if there are exactly 2 valid peaks
    if sum(valid_peaks) == 2 && t_0 <time_threshold
        not_found = false;
        disp("2 peaks found")
    else
        disp("no peaks found");
        not_found = true;
    end
  
    time = (5-(n_samples-t_0)/sf);

end

