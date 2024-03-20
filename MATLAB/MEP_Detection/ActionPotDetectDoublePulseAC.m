% IDEALLY YOU WOULD HAVE ONLY ONE STIMPULSE DETECTION WITH STIMULATION
% INDEXES FOR ALL CHANNELS. THIS WILL BE CODED THIS WEEK (3/20/24)
function [responses] = ActionPotDetectDoublePulseAC(t_0,muscle_loc,emg_data,sf,interpulse_duration,norm_factor_afterfilter,bool_plot_MEP,bool_colour_response,window_size)
    % AC stands for ALL CHANNELS. here we call
    % ActionPotentialDetectionDoublePulse for all channels
    % Check the size of the array
    [x, y] = size(emg_data);
    
    if x < y
        % Transpose the array
        emg_data = emg_data';
    end

    % Determine the smaller of x and y which will be considered as the
    % channel number
    n_channels = min(x, y);
    
    responses = cell(1, n_channels);
    %responses ={};
    
    for i = 1:n_channels
        
         % Call ActionPotDetectDoublePulse3 for each channel
        channel_response = ActionPotDetectDoublePulse3(t_0, muscle_loc{i}, emg_data(:, i), sf, interpulse_duration, norm_factor_afterfilter, bool_plot_MEP, bool_colour_response, window_size);
        
        % Store the response in a cell array
        responses{i} = channel_response;
    
    end

end    


