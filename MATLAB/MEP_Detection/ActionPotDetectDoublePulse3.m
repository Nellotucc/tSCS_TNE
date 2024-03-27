% this version uses the max amplitude peak as start index considering it's the first peak response. 
% Problem is it might not be robust for small currents since artifacts
% might be higher than response. IT SHOULD NOW WORK WITH THE BLANKING
% It does restrict the search range to t_0 +10 to t_0 +interpulse+ 200
% Works for true positive

function [response,p2p_amplitude_1] = ActionPotDetectDoublePulse3(t_0,emg_data,interpulse_duration,norm_factor_afterfilter,bool_plot_MEP,window_size,numberOfchannels)
    disp("INTERPULSE FIRST")
    disp(interpulse_duration);
    %interpulse_duration = interpulse_duration/1000;
    %emg_data should be from one channel and should be [numberOfvalues,1]
    %disp(size(emg_data))
    numberOfValues = length(emg_data);

    if size(emg_data, 1) ~= numberOfValues
        emg_data = emg_data';  % Transpose emg_data
    end

    %clf;
    t_0 = floor(t_0);
    %check that the window size is as expected. If shorter : remove the
    %X to t_0 because it means the emg didnt take the first X ms so the
    %whole window is shifted by X
    % THIS SHOULD NOT HAPPEN ANYMORE BUT KEPT AS PRECAUTION
    if numberOfValues<window_size
        t_0 = t_0-(window_size-numberOfValues);
        disp(['window missing', num2str(window_size-numberOfValues), 'values'])
    end
    
    %noise_std_2 is useless TO BE REMOVED
    if t_0 > numberOfValues/2
        noise_std = std((emg_data(1:floor(numberOfValues/2)))); %take the noise on first half of the signal
        noise_std_2 = std((emg_data(1:floor(numberOfValues/2))));
    else
        noise_std = std((emg_data(floor(numberOfValues/2):numberOfValues))); %take the noise on the last half of the signal.
        noise_std_2 = std((emg_data(floor(numberOfValues/2):numberOfValues)));
    end
    
    %% BLAMK STIM ARTIFACTS
    % not really useful anymore. It blanks MEPs. Maybe if made more complex
    % it can be interesting

    % [not_found, ~,t_artifact] = StimPulseDetection3(emg_data,interpulse_duration*1000,sf);
    % if not_found == false
    %     emg_data(t_artifact-15:t_artifact+15,:) = 0;
    %     emg_data(interpulse_duration+t_artifact-15:interpulse_duration+t_artifact+15,:) = 0; % +/-15 seems like a lot to be blanked... I ll see later if this needs to be changed
    %     disp("BLANKED");
    % end

    % figure;
    % plot(emg_data);

    %% Find peaks in the signal
    abs_emg = abs(emg_data); % Put abs so it finds also peaks in the negative values... not ideal 
    %[peaks, locations] = findpeaks(abs_emg(t_0 +10:t_0 +interpulse_duration+ 200,:));
    % disp("SIZE")
    % disp(size(abs_emg));

    noise_threshold_peak = 4*noise_std;
    disp(noise_threshold_peak)

    % here we augmented the window before and after the t_0 because the
    % stimulator keeps on changing the delay. Hopefully it will be fine
    % with big window.        
    search_range = {t_0-300, t_0 + interpulse_duration + 300};

    %indices must be positive integers
    if search_range{1} <1
        search_range{1} =1;
    end
    %[peaks, locations] = findpeaks(abs_emg(t_0 + 10:t_0 + interpulse_duration + 200), "NPeaks", 4, "MinPeakDistance", 20,"MinPeakHeight",noise_threshold_peak); % take the 4 highest peak that have min distance of 10
    [peaks, locations] = findpeaks(abs_emg(search_range{1}:search_range{2}), "MinPeakDistance", 20,"MinPeakHeight",noise_threshold_peak); % take the peaks that have min distance of 20 and are above threshold


    disp("PEAKS")
    size_peaks = size(peaks);
    disp(size_peaks);
   
    
    
    [sorted_peaks, sorted_indices] = sort(peaks, 'descend');
    
    bool_first_pulse = false; %boolean to assess if the highest peak is the first pulse or not. If not then it shouldn't be a response
    
    disp("lOCS")
    disp(locations)
    
    if size_peaks(1)>1
        disp("ok1")

        % Sort peaks in descending order and take the top two
        top_two_peaks = sorted_peaks(1:2);
        top_two_locations = locations(sorted_indices(1:2)) + search_range{1};

        % Check if there is a peak before the top peak
        % if the top peak is not the first peak then it shouldn't look for MEP
        % since it might just be artifact or at least not an PRM reflex. We use
        % the assumption that the first MEP has to be higher than the first
        % one.
        bool_first_pulse = true;
        if top_two_locations(2) < top_two_locations(1)
            % There is a peak before the top peak
            second_peak = top_two_peaks(2);
            second_peak_location = top_two_locations(2);
            % disp("There is a peak before the top peak.");
            % disp("Second peak value: " + second_peak);
            % disp("Second peak location: " + second_peak_location);
            bool_first_pulse = false;
            disp("not ok 2")
        else
            % There is no peak before the top peak
            % disp("There is no peak before the top peak.");
            disp("ok2")
        end

        % Assign top peak and its location
        top_peak = sorted_peaks(1);
        top_location = top_two_locations(1);

    elseif size_peaks(1) == 1
        bool_first_pulse = true;
        top_peak = sorted_peaks(1);
        top_location = locations(sorted_indices(1)) + search_range{1};
    end


    % Display top peak and its location
    % disp("Top peak value: " + top_peak);
    % disp("Top peak location: " + top_location);
    
    %% Define search window from peak
    
    bool_found = false;

    if bool_first_pulse == true
        % Search AP only around the stimulation instants
        % create the search_pos boundaries for first response and second response
        search_pos_begin_1 = top_location-20;    % start at the stimulation time (t = 0) + muscle delay -10 empirical value to get signal a bit before muscle response
        search_pos_end_1 = top_location+15;   % range around stim pulse 1
        search_pos_begin_1 = max(1, min(search_pos_begin_1, numel(emg_data)));
        search_pos_end_1 = max(1, min(search_pos_end_1, numel(emg_data)));

        search_pos_begin_2 = search_pos_begin_1+interpulse_duration-10; %in theory this should start a bit before the second response
        search_pos_end_2 = search_pos_begin_2+40;   % range around stim pulse 2
        search_pos_begin_2 = max(1, min(search_pos_begin_2, numel(emg_data)));
        search_pos_end_2 = max(1, min(search_pos_end_2, numel(emg_data)));

        % disp("SEARCH")
        % disp(search_pos_begin_1)
        % disp(search_pos_begin_2)

        %NOTE : the window may overlap for now if the interpule_duration is smaller
        %than 40ms; RECHECK : PAS SUR APRES MODIF

        p2p_amplitude_1 = peak2peak(emg_data(search_pos_begin_1:search_pos_end_1));

        p2p_amplitude_2 = peak2peak(emg_data(search_pos_begin_2:search_pos_end_2));


        suppression_level = 1-p2p_amplitude_2/p2p_amplitude_1;


        %classification based on the paper automated response
        threshold_amp = 50/norm_factor_afterfilter;
        %threshold_amp = 5*noise_std;

        threshold_supp_level = 0.4;
        noise_threshold = 10*noise_std;

        if p2p_amplitude_1 <= threshold_amp || p2p_amplitude_1 <= noise_threshold %to be changed in microvolts
            response = 'no response';
        elseif p2p_amplitude_1 >= threshold_amp && p2p_amplitude_1 >= noise_threshold && suppression_level > threshold_supp_level
            response = 'reflex response';
            bool_found = true;

        elseif p2p_amplitude_1 >= threshold_amp && p2p_amplitude_1 >=noise_threshold && suppression_level < threshold_supp_level
            response = 'presumed M-wave';
        else
            response = 'invalid response';
        end
    else
        response = 'no or invalid response';
        p2p_amplitude_1 = 0 ;
    end
    

    %PLOTTING
    % THIS PLOT IS FOR THE WHOLE WINDOW
    % if bool_plot_MEP
    % 
    %     % Plot the signal
    %     figure;
    %     start_window =  max(t_0 - 100, 1);
    %     %h1 = plot(emg_data(start_window:start_window+1000,:), 'm', 'LineWidth', 1); % plots only 1000 values around ROI
    %     h1 = plot(emg_data(:,:), 'm', 'LineWidth', 1); %Plots the whole window
    % 
    %     hold on;
    %     patch([search_pos_begin_1, search_pos_end_1, search_pos_end_1, search_pos_begin_1], ...
    %           [min(emg_data), min(emg_data), max(emg_data), max(emg_data)], 'y', 'FaceAlpha', 0.3);
    %     patch([search_pos_begin_2, search_pos_end_2, search_pos_end_2, search_pos_begin_2], ...
    %           [min(emg_data), min(emg_data), max(emg_data), max(emg_data)], 'y', 'FaceAlpha', 0.3);
    % 
    %     % add a patch for the search range t_0 +10:t_0 +interpulse_duration+ 200;
    %     sp = t_0 +10;
    %     spe = t_0 +interpulse_duration+ 200;
    %     patch([sp, spe,spe ,sp], ...
    %           [1.2*min(emg_data), 1.2*min(emg_data), 1.2*max(emg_data), 1.2*max(emg_data)], 'b', 'FaceAlpha', 0.1);
    % 
    %     % disp(search_pos_begin_1);
    %     % disp(search_pos_end_1);
    %     % 
    %     % disp(search_pos_begin_2);
    %     % disp(search_pos_end_2);
    % 
    %     % Add a straight line y = 6*std_noise
    %     y_line = 10*noise_std; 
    %     x_line = linspace(start_window,start_window+1000, 1000); % Adjust the range as needed
    %     h2 = plot(x_line, ones(size(x_line)) * y_line, 'r--', 'LineWidth', 1);
    % 
    %     % Add a straight line y = 6*std_noise_2
    %     y_line = 6*noise_std_2; 
    %     x_line = linspace(start_window,start_window+1000, 1000); % Adjust the range as needed
    %     h3 = plot(x_line, ones(size(x_line)) * y_line, 'y--', 'LineWidth', 1);
    % 
    %     % Add a straight line for suppression threshold
    %     y_line = (1-threshold_supp_level)*p2p_amplitude_1; 
    %     x_line = linspace(start_window, start_window+1000, 1000);
    %     h4 = plot(x_line, ones(size(x_line)) * y_line, 'b--', 'LineWidth', 2);
    % 
    %     % Add a straight line for p2p amplitude threshold
    %     y_line = threshold_amp;
    %     x_line = linspace(start_window, start_window+1000, 1000);
    %     h5 = plot(x_line, ones(size(x_line)) * y_line, 'g--', 'LineWidth', 2);
    % 
    %     % Add two straight lines for the p2p amplitude of pulse
    %     h6 = plot([search_pos_begin_1+10, search_pos_begin_1+10], [p2p_amplitude_1, 0], 'k-', 'LineWidth', 2);
    %     h7 = plot([search_pos_begin_2+10, search_pos_begin_2+10], [p2p_amplitude_2, 0], 'k-', 'LineWidth', 2);
    % 
    %     [max_amplitude, ~] = max(emg_data);
    %     h8 = plot([t_0, t_0], [max_amplitude, 0], 'p-', 'LineWidth', 2);
    %     grid on;
    % 
    % 
    %     % Add legend
    %     legend([h1, h2, h3, h4, h5, h6, h7, h8], 'EMG signal', '10*std noise', '6*std noise', 'suppression level threshold', 'amplitude threshold', 'P2P peak 1', 'P2P peak 1', 'T 0');
    % 
    %     % Customize plot
    %     title('EMG signal');
    %     xlabel('Time');
    %     ylabel('Signal Value');
    %     hold off;
    % end
    % 
    % PLOTTING
    % THIS PLOT IS FOR A SMALLER WINDOW
    if bool_plot_MEP
        
        start_window =  max(search_range{1}-50, 1);

        h1 = plot(emg_data(start_window:search_range{2},:), 'm', 'LineWidth', 1); % plots only 1000 values around ROI
        hold on;

        [max_amplitude, ~] = max(emg_data);
        t_0 = t_0 - start_window;
        h8 = plot([t_0, t_0], [max_amplitude, 0], 'p-', 'LineWidth', 2);

        % add a patch for the search range of first pulse;
        patch([search_range{1}-start_window, search_range{2}-start_window,search_range{2}-start_window ,search_range{1}-start_window], ...
            [1.2*min(emg_data), 1.2*min(emg_data), 1.2*max(emg_data), 1.2*max(emg_data)], 'b', 'FaceAlpha', 0.1);
        

        
        %bool_found = true; % for testing, can cause bugs if no peaks are detected 
        % it wont have search pos begin 1
       
        if bool_found % only all the lines and legends if MEP detected
            % Add a straight line for noise threshold
            y_line = noise_threshold;
            % disp("CLASS")
            % disp(class(search_range{1}))
            % disp(class(start_window))
            % search_range{1} = int32(search_range{1});
            % start_window= int32(start_window);
            % search_range{2} = int32(search_range{2});
            % disp("CLASS")
            % disp(class(search_range{1}))
            % disp(class(start_window))

            x_line = linspace(double(search_range{1})-double(start_window),double(search_range{2})-double(start_window)); % Adjust the range as needed
            h2 = plot(x_line, ones(size(x_line)) * y_line, 'r--', 'LineWidth', 1);

            search_pos_begin_1 = search_pos_begin_1- start_window;
            search_pos_begin_2 = search_pos_begin_2- start_window;
            search_pos_end_1 = search_pos_end_1- start_window;
            search_pos_end_2 = search_pos_end_2- start_window;
            
            patch([search_pos_begin_1, search_pos_end_1, search_pos_end_1, search_pos_begin_1], ...
                  [min(emg_data), min(emg_data), max(emg_data), max(emg_data)], 'y', 'FaceAlpha', 0.3);
            patch([search_pos_begin_2, search_pos_end_2, search_pos_end_2, search_pos_begin_2], ...
                  [min(emg_data), min(emg_data), max(emg_data), max(emg_data)], 'y', 'FaceAlpha', 0.3);
          
   
            % disp(search_pos_begin_1);
            % disp(search_pos_end_1);
            % 
            % disp(search_pos_begin_2);
            % disp(search_pos_end_2);
        
            % Add a straight line y = 6*std_noise_2
            y_line = 6*noise_std_2; 
            
            x_line = linspace(double(search_range{1})-double(start_window),double(search_range{2})-double(start_window)); % Adjust the range as needed
            h3 = plot(x_line, ones(size(x_line)) * y_line, 'y--', 'LineWidth', 1);
        
            % Add a straight line for suppression threshold
            y_line = (1-threshold_supp_level)*p2p_amplitude_1; 
            x_line = linspace(double(search_range{1})-double(start_window),double(search_range{2})-double(start_window)); % Adjust the range as needed
            h4 = plot(x_line, ones(size(x_line)) * y_line, 'b--', 'LineWidth', 2);
        
            % Add a straight line for p2p amplitude threshold
            y_line = threshold_amp;
            x_line = linspace(double(search_range{1})-double(start_window),double(search_range{2})-double(start_window)); % Adjust the range as needed
            h5 = plot(x_line, ones(size(x_line)) * y_line, 'g--', 'LineWidth', 2);
        
            % Add two straight lines for the p2p amplitude of pulse
            h6 = plot([search_pos_begin_1+10, search_pos_begin_1+10], [p2p_amplitude_1, 0], 'k-', 'LineWidth', 2);
            h7 = plot([search_pos_begin_2+10, search_pos_begin_2+10], [p2p_amplitude_2, 0], 'k-', 'LineWidth', 2);
                    
            % Add legend
            %legend([h1, h2, h3, h4, h5, h6, h7, h8], 'EMG signal', 'threshold', '6*std noise', 'suppression level threshold', 'amplitude threshold', 'P2P peak 1', 'P2P peak 1', 'T 0');
        else
            % Add a straight line for noise threshold
            y_line = noise_threshold_peak;
            % disp("CLASS")
            % disp(class(search_range{1}))
            % disp(class(start_window))
            % search_range{1} = int32(search_range{1});
            % start_window= int32(start_window);
            % search_range{2} = int32(search_range{2});
            % disp("CLASS")
            % disp(class(search_range{1}))
            % disp(class(start_window))

            x_line = linspace(double(search_range{1})-double(start_window),double(search_range{2})-double(start_window)); % Adjust the range as needed
            h2 = plot(x_line, ones(size(x_line)) * y_line, 'r--', 'LineWidth', 1);
            %legend([h1, h8], 'EMG signal','T 0');

        end
        grid on;
    

        % Customize plot
        title('EMG signal');
        xlabel('Time');
        ylab = ylabel('Signal Value');
        ylabPos = get(ylab, 'Position');
        ylabPos(1) = ylabPos(1) + 5*numberOfchannels;  % Adjust the position
        set(ylab, 'Position', ylabPos);

    end
    
    
  

end    