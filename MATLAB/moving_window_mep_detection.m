% in this file I load the whole emg and try to detect the MEP using moving
% windows. This allows me to assess where in the signal the function
% detects MEPs. At the end I disp the times where the code found action
% potentials.

%filePath = 'elect.txt';
filePath = "C:\Users\ricca\OneDrive\Documenti\TNE_MA2\tSCS_Autumn2023\3.Experiments\RecordedExperiments\Chris\Conv_DP_T3_55mA.txt";
filePath = "C:\Users\ricca\OneDrive\Documenti\TNE_MA2\tSCS_Autumn2023\3.Experiments\RecordedExperiments\Riccardo\Conv_DP_t11-T12_T3_45mA";

data = readmatrix(filePath);

emg = data(:,1);
plot(emg);


sf = 1000;
plot_chs = true;
bool_plot_PSD = true;
selected_filters = 3;
paper_nb = 1;
selectedChannels = {0};
interpulse_duration = 100;
bool_plot_MEP = false;
bool_colour_response = false;
values_before_stim = 0;
muscle_loc = 'distal';


[norm_factor_afterfilter1, EMG_preprocessed1] = EMG_preprocessing(emg, sf, selected_filters, 0, plot_chs, selectedChannels, bool_plot_PSD, paper_nb); %preprocess


window_size = 1000;
overlap = 30; % Move window of 10ms (start_1 = 0, start_2 = 10...)
mini_emg = EMG_preprocessed1(1:1050);
signal_length = length(EMG_preprocessed1); % Replace your_signal with the actual variable name
disp(signal_length);
disp('runs needed :');
disp((signal_length-1000)/10);
i =0;
idx =[];
response = 'no';
idx_start_window_MEP = [];
%%

for start_idx = 1:overlap:(signal_length - window_size + 1)
    i= i+1;
    end_idx = start_idx + window_size - 1;
    % Extract the current window
    current_window = EMG_preprocessed1(start_idx:end_idx);
    if start_idx<27211 && start_idx>27200
        disp(start_idx)
        disp(end_idx)

    end

    %MEP detection
    response = ActionPotDetectDoublePulse(muscle_loc,current_window,sf, interpulse_duration,values_before_stim,norm_factor_afterfilter1,bool_plot_MEP,bool_colour_response); %find response 'no response', 'MEP reflex', 'M-wave', 'invalid'
    if strcmp(response, 'reflex response')
        idx =[idx;start_idx];
        disp('RESPONSE')
        disp(start_idx)
        response ='no';
    end

    
    % Display or save the results as needed
    %disp(['Window: ' num2str(start_idx) ' to ' num2str(end_idx)]);
    
    % Add your function result handling here


end
    
disp(size(idx));
%%
disp("begin");
start_idx =  37251;
% 37281
% 37311
% 37341
% 37461
% 37491
% 37641
values_before_stim = 100;
end_idx = start_idx + window_size - 1;
current_window = EMG_preprocessed1(start_idx:end_idx);

response = ActionPotDetectDoublePulse(muscle_loc,current_window,sf, interpulse_duration,values_before_stim,norm_factor_afterfilter1,true,bool_colour_response); %find response 'no response', 'MEP reflex', 'M-wave', 'invalid'
disp(response)