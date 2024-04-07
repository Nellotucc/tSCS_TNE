function filename = find_emg_filename(directory,muscle,current, repetition,interpulse_duration)
 
    %% UNCOMMENT HERE FOR THE NEW DATA SAVING FORMAT
    %Construct the pattern to search for
    pattern = sprintf('emg_channel%s_current%d_repetition%d_window5s_interpulse%d_t0*.mat',muscle,current, repetition+1,interpulse_duration);
    % Search for files matching the pattern
    files = dir(fullfile(directory,pattern));    
    disp(pattern);
    disp(directory)
    if isempty(files)
        % If no matching file is found, return empty string
        filename = '';
        return;
    end

    % Extract the filename from the first matching file
    filename = files(1).name;
    
    %% UNCOMMENT HERE FOR OLDER VERSIONS

    %filepath = sprintf('emg_current%d_repetition%d_window5s_interpulse50.mat', current, repetition+1);
    % filepath = sprintf('emg_current%d_repetition%d_5.0swindow_100interpulse.mat', current, repetition+1);
    % filepath = sprintf('emg_channel%s_current%d_repetition%d_window5s_interpulse%d.mat', muscle,current, repetition+1,interpulse_duration);
    % 
    % filename = fullfile(directory,filepath);
end