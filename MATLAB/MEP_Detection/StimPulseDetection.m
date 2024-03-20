function [not_found, time]= StimPulseDetection(emg_data,interpulse_duration,sf)
    
    % Calculate the standard deviation for each channel
    channel_std = std(emg_data);
    
    % Find the channel index with the minimum standard deviation
    [~, best_channel_idx] = min(channel_std);

    threshold_factor = 6; % Adjust this factor based on noise level
    
    % Find peaks in the signal
    [peaks, locations] = findpeaks(emg_data(:,best_channel_idx));
    
    %total length of window
    n_samples = length(emg_data(:,best_channel_idx));

    % Calculate the noise level (adjust this based on your signal characteristics)
    noise_level = channel_std(best_channel_idx);
    
    % Set the threshold for peak detection
    threshold = threshold_factor * noise_level;
    
    % Define the error margin for interpulse_duration
    error_margin = 2; % 

    % Sort peaks in descending order and take the top two
    [~, sorted_indices] = sort(peaks, 'descend');
    top_two_peaks = peaks(sorted_indices(1:2));
    top_two_locations = locations(sorted_indices(1:2));


    % Find peaks above the threshold within the interframe_duration
    % disp(abs(abs(diff(top_two_locations)/sf*1000) - interpulse_duration));
    % disp(top_two_peaks);
    % disp(top_two_peaks > threshold)

    valid_peaks = (top_two_peaks > threshold) & (abs(abs(diff(top_two_locations)/sf*1000) - interpulse_duration) <= error_margin);
    % disp("VALID PEAKS")
    % disp(valid_peaks)
    % disp(abs(abs(diff(top_two_locations)/sf*1000) - interpulse_duration));
    % 
    % Check if there are exactly 2 valid peaks
    if sum(valid_peaks) == 2
        not_found = false;
        disp("2 peaks found")
        t_0 = min(top_two_locations);
    else
        disp("no peaks found");
        not_found = true;
        t_0=0;
    end
    % disp("TOP TWO LOCATION, N SAMPLES")
    % disp(top_two_locations)
    % disp(n_samples);

  
    time = (5-(n_samples-t_0)/sf);
    
    disp("T 0");
    disp(t_0);

   
end

