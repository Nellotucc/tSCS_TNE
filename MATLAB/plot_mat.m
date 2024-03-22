% FOR C 50 IN FOLDER MARCH ITS PRESUMED M WAVE, WHAT DO YOU THINK ??



folder = '15march\';
folder_path = ['DATA\',folder];

data1 = load("DATA\15march\emg_current20_repetition2_5.0swindow_100interpulse.mat");
emg = data1.emg_data;

%% Variables needed for plotting

selectedChannels = {1};
sf = 1000;
interpulse_duration = 100; % us - ms --- for Double pulse. 
current = 65;
numberOfValues = 5000;
% EMG preprocessing
plot_chs = false;
bool_plot_PSD = false;
selected_filters = 3;
paper_nb = 1;

% MEP detection
bool_plot_MEP = true;
bool_colour_response = false;
muscleLocations = {'distal'};
t_0 = 1100;
%%

emg_3 = load('C:\Users\local_B216353\Documents\tSCS\tSCS_TNE\MATLAB\DATA\22march\emg_current25_repetition3_5.0swindow_100interpulse.mat');
emg_3 = emg_3.emg_data;
emg_2 = load('C:\Users\local_B216353\Documents\tSCS\tSCS_TNE\MATLAB\DATA\22march\emg_current25_repetition2_5.0swindow_100interpulse.mat');
emg_2 = emg_2.emg_data;
emg_1 = load('C:\Users\local_B216353\Documents\tSCS\tSCS_TNE\MATLAB\DATA\22march\emg_current25_repetition1_5.0swindow_100interpulse.mat');
emg_1 = emg_1.emg_data;

emg = [emg_1,emg_2,emg_3];

plot(emg_3)






%%

emg = load('C:\Users\local_B216353\Documents\tSCS\tSCS_TNE\MATLAB\DATA\20march\black2\45-50-50ip\full_emg_3.mat');
emg = load('C:\Users\local_B216353\Documents\tSCS\tSCS_TNE\MATLAB\DATA\20march\black2\45-50\full_emg_4.mat');
emg = emg.emg_data_4(1,5000:end);
plot(emg)
%%

disp("begin")

interpulse_duration = 50;
t_0 = 1090;
rep_number = floor((length(emg)-t_0)/5000);
responses = {};

for i=0:rep_number
    emg_short = emg(1,i*(5000)+1+t_0-500:i*(5000)+5000+t_0);
    plot(emg_short);
    [norm_factor_afterfilter, EMG_preprocessed] = EMG_preprocessing((double(emg_short))', sf, selected_filters, 0, plot_chs, selectedChannels, bool_plot_PSD, paper_nb); %preprocess
    response = ActionPotDetectDoublePulse3(500+10,muscleLocations{1},EMG_preprocessed,sf, interpulse_duration,norm_factor_afterfilter,bool_plot_MEP,bool_colour_response,numberOfValues); %find response 'no response', 'MEP reflex', 'M-wave', 'invalid'
    disp(response)
    responses = [responses;response];
    pause(3)
end
disp(responses)
%% FULL TRIAL WITH APD : setup the approximate t_0 and relevant parameters (see above) and run the cell.
disp('BEGIN');

[norm_factor_afterfilter, EMG_preprocessed] = EMG_preprocessing((double(emg))', sf, selected_filters, 0, plot_chs, selectedChannels, bool_plot_PSD, paper_nb); %preprocess
figure;

response = ActionPotDetectDoublePulse3(t_0,muscleLocations{1},EMG_preprocessed,sf, interpulse_duration,norm_factor_afterfilter,bool_plot_MEP,bool_colour_response,numberOfValues); %find response 'no response', 'MEP reflex', 'M-wave', 'invalid'

fprintf('Response : %s\n', response);
%% PLOT MULTIPLE FILES
current = 20;
% Specify the base file path
base_path = [folder_path,'emg_current',num2str(current),'_repetition'];

% Specify the number of repetitions
num_repetitions = 3; % Adjust this based on your actual number of repetitions

% Initialize a cell array to store the EMG data
emg_data = cell(num_repetitions, 1);

% Loop through each repetition
for rep = 1:num_repetitions
    % Construct the file path for each repetition
    file_path = [base_path, num2str(rep), '_5.0swindow_',num2str(interpulse_duration/sf),'interpulse.mat'];
    
    % Load the data
    data = load(file_path);
    
    % Extract the EMG data
    emg_data{rep} = data.emg_data;
end

% Loop through each repetition to plot the data
for rep = 1:num_repetitions
    % Create a new figure for each repetition
    fig_handles{rep} = figure;
    
    % Plot the EMG data
    plot(emg_data{rep});
    
    % Add labels and title
    xlabel('Time');
    ylabel('EMG Data');
    title(['EMG Data for Repetition ', num2str(rep)]);
    
    % Optionally save the figure
    % saveas(fig_handles{rep}, ['repetition_', num2str(rep), '_plot.png']);
end

%% TESTING STIM ARTIFACT FINDING AND BLANKING
[norm_factor_afterfilter, EMG_preprocessed] = EMG_preprocessing((double(emg))', sf, selected_filters, 0, plot_chs, selectedChannels, bool_plot_PSD, paper_nb); %preprocess
%
% [not_found, time,t_0] = StimPulseDetection3(EMG_preprocessed,interpulse_duration,sf);

[not_found, ~,t_artifact] = StimPulseDetection3(EMG_preprocessed,interpulse_duration,sf);
if not_found == false
    EMG_preprocessed(t_artifact-10:t_artifact+10) = 0;
    EMG_preprocessed(interpulse_duration/1000+t_artifact-10:interpulse_duration/1000+t_artifact+10) = 0;
    disp("BLANKED");

end

plot(EMG_preprocessed)