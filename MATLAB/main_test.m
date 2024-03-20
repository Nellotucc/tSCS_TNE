EMG_data = [];
bool_colour_response = false;
bool_plot_MEP = true;
pause(3); % ensures we'll have enough data for the first window
SetSingleChanState(s, 0, 1, 1, 1);
% CREER SECTION QUI DETECTE PULSE ARTIFACT AVEC GRANDE WINDOW POUR TROUVER
% T_0 DE STIMULATION

current = 15;
not_found = true;
SetSingleChanSingleParam(s, 0, 6, current)

while not_found
    pause(2);
    tic;
    emg_data = getDataFromChannel(selectedChannels{1},sf,2000); % collect data    
    [norm_factor_afterfilter, EMG_preprocessed] = EMG_preprocessing((double(emg_data))', sf, selected_filters, 0, plot_chs, selectedChannels, bool_plot_PSD, paper_nb); %preprocess
    [not_found, time] = StimPulseDetection(EMG_preprocessed,interpulse_duration,sf);
    elapsed_time = toc;
end
disp("FOUND");

temp = EMG_preprocessed;

disp("waiting for :");
disp(time-elapsed_time);

pause(time-elapsed_time);


for j = 1: 1    % Need to be increased
    tic;
    current =  30 + j*5; % mA 
    SetSingleChanSingleParam(s, 0, 6, current)
    elapsed = toc;
    disp("ELAPSED");
    disp(elapsed);

    pause(5);


    for i = 1: 1  % Number of repetitions
        % Enable Output
        pause(2) %A RECHANGER A 650 take window of 680ms after 650ms of stimulation (it will take 650ms for the first run since we won't have 680 available values)
        disp('waiting for:')
        disp(values_after_stim/sf);
        % collect EMG data and process it
        tic; % start timer
        
        disp(['Repetition: ', num2str(i)]);
        disp(['Current: ', num2str(current)]);
        emg_data = getDataFromChannel(selectedChannels{1},sf,10000); % collect data        
        [norm_factor_afterfilter, EMG_preprocessed] = EMG_preprocessing((double(emg_data))', sf, selected_filters, 0, plot_chs, selectedChannels, bool_plot_PSD, paper_nb); %preprocess
        
        EMG_data =[EMG_data;EMG_preprocessed];
        response = ActionPotDetectDoublePulse(muscleLocations{1},EMG_preprocessed,sf, interpulse_duration/1000,values_before_stim,norm_factor_afterfilter,bool_plot_MEP,bool_colour_response); %find response 'no response', 'MEP reflex', 'M-wave', 'invalid'
        
        fprintf('Response for current %d and repetition %d: %s\n', current, i, response);

        % Save the data in the 'DATA' folder
        filename = fullfile(folderPath, sprintf('emg_current%d_repetition%d_%sswindow_100interpulse.mat', current,i,num2str(numberOfValues/sf, '%.1f')));
        %save(filename, 'emg_data');

        elapsed_time = toc; % stop timer
        fprintf('Processing time: %.4f seconds\n', elapsed_time);

        pause(3-elapsed_time); %take into account processing time for interframe interval (4.35)
    end
    disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
    
end

disp(numberOfValues);
SetSingleChanState(s, 0, 1, 0, 0);
%%
EMG_data = [];
bool_colour_response = false;
bool_plot_MEP = true;
pause(3); % ensures we'll have enough data for the first window
SetSingleChanState(s, 0, 1, 1, 1);
% CREER SECTION QUI DETECTE PULSE ARTIFACT AVEC GRANDE WINDOW POUR TROUVER
% T_0 DE STIMULATION

current = 15;
not_found = true;
SetSingleChanSingleParam(s, 0, 6, current)

while not_found
    pause(2);
    tic;
    emg_data = getDataFromChannel(selectedChannels{1},sf,2000); % collect data    
    [norm_factor_afterfilter, EMG_preprocessed] = EMG_preprocessing((double(emg_data))', sf, selected_filters, 0, plot_chs, selectedChannels, bool_plot_PSD, paper_nb); %preprocess
    [not_found, time] = StimPulseDetection(EMG_preprocessed,interpulse_duration,sf);
    elapsed_time = toc;
end
disp("FOUND");

temp = EMG_preprocessed;

disp("waiting for :");
disp(time-elapsed_time);
tic;
pause(time-elapsed_time+1);
el = toc;
emg_data = getDataFromChannel(selectedChannels{1},sf,4000); % collect data        

SetSingleChanState(s, 0, 1, 0, 0);
plot(emg_data)
%%


EMG_data = [];
bool_colour_response = false;
bool_plot_MEP = true;
pause(2); % ensures we'll have enough data for the first window
SetSingleChanState(s, 0, 1, 1, 1);
% CREER SECTION QUI DETECTE PULSE ARTIFACT AVEC GRANDE WINDOW POUR TROUVER
% T_0 DE STIMULATION

current = 15;
not_found = true;
SetSingleChanSingleParam(s, 0, 6, current)

while not_found
    pause(2);
    tic;
    emg_data = getDataFromChannel(selectedChannels{1},sf,2000); % collect data    
    [norm_factor_afterfilter, EMG_preprocessed] = EMG_preprocessing((double(emg_data))', sf, selected_filters, 0, plot_chs, selectedChannels, bool_plot_PSD, paper_nb); %preprocess
    [not_found, time] = StimPulseDetection(EMG_preprocessed,interpulse_duration,sf);
    elapsed_time = toc;
end
disp("FOUND");
temp = EMG_preprocessed;
disp("waiting for :");
disp(time-elapsed_time);
pause(time-elapsed_time);
disp('finished');
for j = 1: 2    % Need to be increase if 
    current =  30 + j*5; % mA 
    SetSingleChanSingleParam(s, 0, 6, current)
    tic;
    for i = 1: 2  % Number of repetitions
        % Enable Output
        disp("first pause")
        pause(1) %A RECHANGER A 650 take window of 680ms after 650ms of stimulation (it will take 650ms for the first run since we won't have 680 available values)
        disp("end first pause")
        % collect EMG data and process it
        
        disp(['Repetition: ', num2str(i)]);
        disp(['Current: ', num2str(current)]);
        
        fprintf('Processing time: %.4f seconds\n', elapsed_time);
        disp("second pause")
        pause(4); %take into account processing time for interframe interval (4.35)
        disp('end second pause  ')
    end
    elapsed = toc;
    disp(elapsed);
    disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
    
end
emg_data = getDataFromChannel(0,sf,45000); % collect data        
emg_trigger = getDataFromChannel(8,sf,45000); % collect data        

disp(numberOfValues);
SetSingleChanState(s, 0, 1, 0, 0);
%%
plot(emg_data)
%%
plot(temp)
%%
plot(emg_trigger)
%%
sf =1000;
emg_data = getDataFromChannel(8,sf,45000); % collect data        
%%
disp(emg_data)
plot(emg_data);
%%
data8 = load("DATA\RIC\emg_current55_repetition1_2.0swindow_100interpulse.mat");

emg = data8.emg_data;

bool_plot_PSD =false;

[norm_factor_afterfilter, EMG_preprocessed] = EMG_preprocessing((double(emg))', sf, selected_filters, 0, plot_chs, selectedChannels, bool_plot_PSD, paper_nb); %preprocess
plot(EMG_preprocessed);
bool_plot_MEP = true;

%response = ActionPotDetectDoublePulse("distal",EMG_preprocessed,sf, interpulse_duration/1000,values_before_stim,norm_factor_afterfilter,bool_plot_MEP,true); %find response 'no response', 'MEP reflex', 'M-wave', 'invalid'

fprintf('Response for current %d and repetition %d: %s\n', current, i, response);
