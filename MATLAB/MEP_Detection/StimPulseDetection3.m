% possible problems :
% 1) If interpulse interval is bigger and the 2 MEP appear they might be
% detected as stim artifact. Need to find what distinguishes them. the
% second non causal derivation leads0 to 10x higher MEP values than stim
% art. Could also use the width of peaks maybe. same thing happens if the
% MEP is well timed its considered as artifact.
%
% 2) The (abs(diff(top_two_peaks))<=noise_level) might need to be fine tuned 
% to see which value gives the sense of "approximately same height" no matter
% the scale. Could maybe do 2nd peak should be between 3/4 and 5/4 amplitude 
% of first one so we keep the scale.

function [not_found, time,t_0]= StimPulseDetection3(emg_data,interpulse_duration,sf)
    % This function calculates the time of the first peak of the
    % stimulation artifact t_0.

    % Calculate the standard deviation for each channel
    channel_std = std(emg_data);
    
    % Find the channel index with the minimum standard deviation
    [~, best_channel_idx] = min(channel_std);
    noise_level = channel_std(best_channel_idx);
    emg= emg_data(:,best_channel_idx);

    % Set the threshold for peak detection
    threshold_factor = 4; % Adjust this factor based on noise level
    threshold = threshold_factor * noise_level;
    

    %total length of window
    n_samples = length(emg);
    
    %find peaks in the singal that have almost the same value since
    %artifacts are constant in values.
    [peaks, locs] = findpeaks(emg,"MinPeakHeight",threshold,"NPeaks",4,"SortStr","descend",'MinPeakDistance', 10); %4 tallest peak that are above a threshold

    % Sort the peaks and locations by increasing time
    [locs_sorted, order] = sort(locs);
    
    % Use the order to rearrange the peaks accordingly
    peaks_sorted = peaks(order);
    
    % Initialize arrays to store valid peak locations and heights
    valid_peak_locs = [];

    % Iterate through each peak location
    for i = 1:length(locs_sorted)-1
        
        % Check if the distance is interpulse_duration samples and peak
        % heights are equal (interval of +/- noise)

        for j = i+1:length(locs_sorted)
            peak_distance = locs_sorted(j) - locs_sorted(i);
            if abs(peak_distance-(interpulse_duration/1000)) <= 2 && abs(peaks_sorted(i) - peaks_sorted(j)) <= 3*noise_level % 3 is manually adjusted
                % Store the peak location and height if conditions are met
                valid_peak_locs = [valid_peak_locs, locs_sorted(i)];
                disp("VALID")
                disp(i)
                % disp("CONDITION")
                % disp(abs(peak_distance-(interpulse_duration/1000)) <= 2)
            end
        % disp(["FOUND FIRST STIMULATION ARTIFACT AT : ", num2str(locs_sorted(i))]);
        % disp(["FOUND SECOND STIMULATION ARTIFACT AT : ", num2str(locs_sorted(j))]);
        % 
        % disp(["FOUND FOR VALUE  : ", num2str(peaks_sorted(i))]);
        % disp(["FOUND FOR VALUE  : ", num2str(peaks_sorted(j))]);
        disp(["NOISE LEVEL : ", num2str(3*noise_level)]);
        disp(abs(peaks_sorted(i) - peaks_sorted(j)));
        % 
        % disp(["INTERPULSE / 1000  : ", num2str(interpulse_duration/1000)])
        % disp(["PEAK DISTANCE  : ", num2str(peak_distance)])
        disp("CONDITION DIS - IP  : ")
        disp(abs(peak_distance-interpulse_duration/1000))
        
        end
        
    end





    if length(valid_peak_locs)==1
        t_0 = valid_peak_locs(1);
        not_found = false;
        disp(["FOUND STIMULATION ARTIFACT AT : ", num2str(t_0)]);

    else
        t_0 = 0;
        not_found = true;
        disp("NO STIMULATION ARTIFACT FOUND");
    end

    time = (5-(n_samples-t_0)/sf);

end

