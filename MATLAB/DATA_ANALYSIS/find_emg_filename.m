function filename = find_emg_filename(directory,current, repetition,interpulse_duration)
    % Construct the pattern to search for
    pattern = sprintf('emg_channelRF_L_current%d_repetition%d_window5s_interpulse%d_t0*.mat', current, repetition+1,interpulse_duration);
    % Search for files matching the pattern
    files = dir(fullfile(directory,pattern));    
    %filename = sprintf('emg_current%d_repetition%d_window5s_interpulse50.mat', current, repetition+1);
    %filename = sprintf('emg_current%d_repetition%d_5.0swindow_100interpulse.mat', current, repetition+1);
            
    
    if isempty(files)
        % If no matching file is found, return empty string
        filename = '';
        return;
    end
    
    % Extract the filename from the first matching file
    filename = files(1).name;
end