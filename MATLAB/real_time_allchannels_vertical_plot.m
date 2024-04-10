clear;
clc;
%% Imports
addpath(genpath('NewBoardTest')); % for stimulator
addpath(genpath('MEP_Detection'));  %to have the MEP functions
addpath(genpath('LINK')); %to have the Matlab-DataLink connection functions
%%
DataLogInit %% link to biometrics

%% CONNECT TO STIMULATOR 
ComPort        = 'COM28';
Baudrate       = 115200*8;   %921600
 
run('OpenComPort.m'); %

%% SET VARIABLES
%These are the variables you can change

% RECORDING
% MAKE SURE ALL THE AVAILABLE CHANNELS ARE SELECTED OTHERWISE IT OVERFLOWS !!
selectedChannels = {0,1,2,3,4,5,6}; % channel to record from, multiple channels will be used later. Channel 0 here is channel 1 on BIOMETRICS. 
channelNames = {'SO_R','SO_L','TA_R','TA_L','RF_R','RF_L','ST_L','ST_R'};

% selectedChannels = {0,1}; % channel to record from, multiple channels will be used later. Channel 0 here is channel 1 on BIOMETRICS
% channelNames = {'SO_R','SO_L'};

sf = 1000; %sampling frequency of channel acquisition


% PREPROCESSING
plot_chs = false;
bool_plot_PSD = false;
selected_filters = 3;
paper_nb = 1;

% MEP detection
bool_plot_MEP = true;

% SAVING
numberOfelectrodes = 6;
directories = cell(1, numberOfelectrodes);

for i = 1:numberOfelectrodes
    % Create the directory path
    directory = ['DATA/RICCARDO/4april/2swindow/electrode', num2str(i)];
    
    % Add directory to directories cell array
    directories{i} = directory;
    
    % Create the directory if it doesn't exist
    if ~exist(directory, 'dir')
        mkdir(directory);
    end
end

% STIMULATION
interpulse_duration = uint32(50 *1000); % us - ms --- for Double pulse. Usually between 35-100ms --- time between two bi-phasic pulses. 
current_0 = 30; %mA : Set the current to start the loop with.
current_f = 80; %mA : Final current

% LOOP PARAMETERS
real_time_channels = selectedChannels; % set the real time channel
current_step = 5; %mA : steps of the current ex: current_step = 5 : 10--15--20...
numberOfrepetitions = 3; %i value
%numberOfcurrents = 2; %j value, increased by steps of current_step
numberOfcurrents = round((current_f-current_0)/current_step)+1; %j value, increased by steps of current_step (ATTENTION current_f-current_step should be multiples of current_step. ROUND is added in case they are not.
numberOfchannels = length(real_time_channels);

%% SET CONSTANTS
%Don't change these values unless big modification is made
current_initial = 10; % small comfortable current before the loop

% RECORDING WINDOW
numberOfValues = 2000;
pause_value = numberOfValues/1000; % ms - s
t_0 = 1000; % we record windows starting 1s before stimulation (see pause(0.920) line  112)

% PLOTTING
% Define the margins and gaps
leftMargin = 0.03;
rightMargin = 0.02;
topMargin = 0.05;
bottomMargin = 0.05;
horizontalGap = 0.02;
verticalGap = 0.05;
% Calculate the total width and height available for subplots
totalWidth = 1 - leftMargin - rightMargin - horizontalGap;
totalHeight = 1 - topMargin - bottomMargin - (numberOfchannels - 1)*verticalGap;
% Calculate the width and height of each subplot
subplotWidth = totalWidth ;
subplotHeight = totalHeight/ numberOfchannels; % Two rows
subplotWidth_signal = subplotWidth*0.60;
gap = subplotWidth*0.05;
subplotHeight_signal = subplotHeight;
start_subplot_response = subplotWidth*0.75;
subplotWidth_response = subplotWidth*0.25;
subplotHeight_response = subplotHeight;


%% SET PARAMETERS FOR STIMULATOR

pulse_width = uint32(490); % us --- Fixed --- Remember this is half of the duration of a bi-phasic pulse
pulse_width_1pulse = uint32(1000); % us --- Fixed --- The total duration of a burster (made of several short bi-phasic pulses)
N_pulse_repetition = 2;     % --- Insert 1 to Single Pulse (SP)-  2 to Double Pulse (DP) --- the number of inner bi-phasic pulses in a burster.   
pulse_deadtime = uint32(20);        % us - --- Fixed ---  20 is the minimum
interframe_duration = uint32( numberOfValues*1000 ); % us - s 
%burst_interframe_duration = uint32( 1e6 * 1/STIMULATION_FREQ - ...    % --- Not used for PRM reflex --- 
%                                       (burst_inner_pulse_repetition * (2 * burst_single_phase_pulse_duration + burst_pulse_deadtime) ) ... % the total duration of the bi-phasic pulses including deadtime
%                                       ) ; % us. This is the time between two bursters. - Not necessary for SP and DP



SetSingleChanAllParam_v2(s, 0, ...
                        pulse_width, ...    % pulseDurationUS
                        pulse_deadtime, ...                 % deadTimeUS
                        interpulse_duration, ...            % interpulseDurationUS
                        interframe_duration, ...            % interframeDurationUS
                        N_pulse_repetition, ...         % numberOfPulsesPerFrame
                        current_initial,...               % IAmplitude in mA
                        0);

SetSingleChanSingleParam_v2(s, 0, 7, 0) % Trigger mode (7), Output
SetSingleChanState(s, 0, 1, 0, 0) %  Output disabled

%% FOR TESTING
SetSingleChanState(s, 0, 1, 1, 1); % activate output before testing
%% FOR TESTING
current = 15;

SetSingleChanSingleParam(s, 0, 6, current)
%% FOR TESTING
SetSingleChanSingleParam_v2(s, 0, 9, 1);
%% FOR TESTING
SetSingleChanState(s, 0, 1, 0, 0);
%% REAL TIME DATA ACQUISISTION ONE ELECTRODE CHANNEL
%params to tune each time : current_0 and real_time_channel
% can also tune pause(0.920) updated t_0 for synchronization if they change


% BEGGINING OF REAL TIME
electrode_number = 6; %set the electrode number

all_responses = cell(numberOfcurrents, numberOfrepetitions,numberOfchannels); % jxixn array of responses
all_amplitudes = cell(numberOfcurrents, numberOfrepetitions,numberOfchannels); % jxixn array of amplitudes of first MEP
all_emgs = cell(numberOfcurrents, numberOfrepetitions,numberOfchannels); % jxixn array of all emg windows


%prepare the figure
f = create_figure(true);

SetSingleChanSingleParam(s, 0, 6, current_initial);

SetSingleChanState(s, 0, 1, 1, 0); % activate High Voltage
pause(1)
SetSingleChanState(s, 0, 1, 1, 1); % activate output

start_time = tic;

emg_removed = getDataFromChannels(real_time_channels,sf,40000); % remove available samples before recording

theoretical_elapsed_time = 0;
offset = 0;

emg_removed = getDataFromChannels(real_time_channels,sf,40000); % remove available samples before recording

SetSingleChanSingleParam(s,0, 6, current_0)

pause(0.920); % pause accounts for delay when sending the next command SetSingleChanSingleParam_v2(s, 0, 9, 1). Based on tests.

SetSingleChanSingleParam_v2(s, 0, 9, 1);

pause(pause_value)
close all;
for j = 1: numberOfcurrents    % Need to be increased
    current =  current_0 + (j-1)*current_step; % mA, it will start the first 3 repetitions at current_0
    SetSingleChanSingleParam(s, 0, 6, current)
    f = create_figure(false);
    clf; % change for multiple currents like add a figure or something

    for i = 1: numberOfrepetitions  % Number of repetitions

        % Enable Output
        % Make the figure visible
        %f.Visible = 'on';


        %collect EMG data and process it
        for_timer = tic; % start timer
        theoretical_elapsed_time = theoretical_elapsed_time+5;
        offset = offset+ toc(start_time)-theoretical_elapsed_time;

        % CHANGE OFFSET DAILY BASED ON OFFSET TESTS. EITHER -50 , 0 , +50

        %updated_t_0 = t_0 +offset+49*i; %offset is computation time and 49(ms) is the time shift of each window
        updated_t_0 = t_0-40*i; %offset is computation time and 49(ms) is the time shift of each window

        disp(['Repetition: ', num2str(i)]);
        disp(['Current: ', num2str(current)]);
        emg_data = getDataFromChannels(real_time_channels,sf,numberOfValues); % collect data

        disp(['Looking at pulse at time t_0 = : ', num2str(updated_t_0)]);



        for k = 1:numberOfchannels  % Loop over channels PLOT VERTICALLY

            %PLOTTING
            % Calculate the position for subplot 1 (Signal)
            xPos1 = leftMargin+(i-1)*subplotWidth_signal*1/3+(i-1)*gap;
            yPos1 = 1 - topMargin - (k-1) * (subplotHeight_signal + verticalGap)-subplotHeight_signal;
            signalPosition = [xPos1, yPos1, subplotWidth_signal/3, subplotHeight_signal];
            % Calculate the position for subplot 2 (Response)
            xPos2 = leftMargin + start_subplot_response + horizontalGap;
            yPos2 = yPos1;
            responsePosition = [xPos2, yPos2, subplotWidth_response, subplotHeight_response];

            % Subplot 1 for Signal
            %subplot(2, numberOfchannels, (k-1)*2 + 1);
            subplot('Position', signalPosition);
            [response,p2p_amplitude] = Signal_analysis(updated_t_0,(double(emg_data(k,:)))',sf,selected_filters, 0, plot_chs, selectedChannels{k}, bool_plot_PSD, paper_nb, interpulse_duration, bool_plot_MEP,numberOfValues);
            title(['Signal of ', channelNames{k}]);

            all_responses{j, i,k} = response;
            all_amplitudes{j, i,k} = p2p_amplitude;
            emg = emg_data(k, :);
            all_emgs{j, i, k} = emg; % Store EMG data for the current channel

            % Subplot 2 for Response
            %subplot(2, numberOfchannels, (k-1)*2 + 2);
            subplot('Position', responsePosition);
            plot_response2(all_responses(j, :,k),current,  subplotWidth_response, subplotHeight_response);
            title(['Response of ', channelNames{k}]);

            fprintf('Response for current %d, repetition %d, channel %d: %s\n', current, i, k,response);
            % Save the data in the 'DATA' folder
            filename = fullfile(directories{electrode_number}, sprintf('emg_channel%s_current%d_repetition%d_window%ss_interpulse%s_t0%d.mat', channelNames{k},current,i,num2str(numberOfValues/sf),num2str(interpulse_duration/1000),round(updated_t_0)));
            save(filename, 'emg'); % saving raw data

        end
        pause(pause_value)

        elapsed_time_loop = toc(for_timer); % stop timer
        fprintf('Processing time: %.4f seconds\n', elapsed_time_loop);

    end
    disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")


end
SetSingleChanState(s, 0, 1, 0, 0);



disp("END")
%% REAL TIME DATA ACQUISISTION ALL ELECTRODE CHANNELS
%params to tune each time : current_0 and real_time_channel
% can also tune pause(0.920) updated t_0 for synchronization if they change


% BEGGINING OF REAL TIME
for electrode_number = 1:numberOfelectrodes
    
    all_responses = cell(numberOfcurrents, numberOfrepetitions,numberOfchannels); % jxixn array of responses
    all_amplitudes = cell(numberOfcurrents, numberOfrepetitions,numberOfchannels); % jxixn array of amplitudes of first MEP
    all_emgs = cell(numberOfcurrents, numberOfrepetitions,numberOfchannels); % jxixn array of all emg windows
    
    
    %prepare the figure
    f = create_figure(); % Adjust width and height as needed
    
    
    %SetSingleChanSingleParam(s, electrode_number, 6, current_initial);
    
    %SetSingleChanState(s, electrode_number, 1, 1, 0); % activate High Voltage
    pause(1)
    %SetSingleChanState(s, electrode_number, 1, 1, 1); % activate output
    
    start_time = tic;
    
    emg_removed = getDataFromChannels(real_time_channels,sf,40000); % remove available samples before recording
    
    theoretical_elapsed_time = 0;
    offset = 0;
    
    emg_removed = getDataFromChannels(real_time_channels,sf,40000); % remove available samples before recording
    
    %SetSingleChanSingleParam(s, electrode_number, 6, current_0)
    
    pause(0.920); % pause accounts for delay when sending the next command SetSingleChanSingleParam_v2(s, 0, 9, 1). Based on tests.
    
    %SetSingleChanSingleParam_v2(s, electrode_number, 9, 1);
    
    pause(pause_value)
    
    for j = 1: numberOfcurrents    % Need to be increased
        current =  current_0 + (j-1)*current_step; % mA, it will start the first 3 repetitions at current_0
        %SetSingleChanSingleParam(s, electrode_number, 6, current)
        
        clf; % change for multiple currents like add a figure or something
        for i = 1: numberOfrepetitions  % Number of repetitions
    
            % Enable Output
            % Make the figure visible
            %f.Visible = 'on';
            
    
            %collect EMG data and process it
            for_timer = tic; % start timer
            theoretical_elapsed_time = theoretical_elapsed_time+5;
            offset = offset+ toc(start_time)-theoretical_elapsed_time;
            
            % CHANGE OFFSET DAILY BASED ON OFFSET TESTS. EITHER -50 , 0 , +50
            
            %updated_t_0 = t_0 +offset+49*i; %offset is computation time and 49(ms) is the time shift of each window
            updated_t_0 = t_0-40*i; %offset is computation time and 49(ms) is the time shift of each window
    
            disp(['Repetition: ', num2str(i)]);
            disp(['Current: ', num2str(current)]);
            emg_data = getDataFromChannels(real_time_channels,sf,numberOfValues); % collect data
    
            disp(['Looking at pulse at time t_0 = : ', num2str(updated_t_0)]);
            
    
    
            for k = 1:numberOfchannels  % Loop over channels PLOT VERTICALLY
                
                %PLOTTING
                % Calculate the position for subplot 1 (Signal)
                xPos1 = leftMargin+(i-1)*subplotWidth_signal*1/3;
                yPos1 = 1 - topMargin - (k-1) * (subplotHeight_signal + verticalGap)-subplotHeight_signal;
                signalPosition = [xPos1, yPos1, subplotWidth_signal/3, subplotHeight_signal];
                % Calculate the position for subplot 2 (Response)
                xPos2 = leftMargin + subplotWidth_signal + horizontalGap;
                yPos2 = yPos1;
                responsePosition = [xPos2, yPos2, subplotWidth_response, subplotHeight_response];
    
                % Subplot 1 for Signal
                %subplot(2, numberOfchannels, (k-1)*2 + 1);
                subplot('Position', signalPosition);
                [response,p2p_amplitude] = Signal_analysis(updated_t_0,(double(emg_data(k,:)))',sf,selected_filters, 0, plot_chs, selectedChannels{k}, bool_plot_PSD, paper_nb, interpulse_duration, bool_plot_MEP,numberOfValues);
                title(['Signal of ', channelNames{k}]);
    
                all_responses{j, i,k} = response;  
                all_amplitudes{j, i,k} = p2p_amplitude;  
                emg = emg_data(k, :);
                all_emgs{j, i, k} = emg; % Store EMG data for the current channel
    
                % Subplot 2 for Response
                %subplot(2, numberOfchannels, (k-1)*2 + 2);  
                subplot('Position', responsePosition);
                plot_response2(all_responses(j, :,k),current,  subplotWidth_response, subplotHeight_response);
                title(['Response of ', channelNames{k}]);
    
                fprintf('Response for current %d, repetition %d, channel %d: %s\n', current, i, k,response);
                % Save the data in the 'DATA' folder
                filename = fullfile(directories{electrode_number}, sprintf('emg_channel%s_current%d_repetition%d_window%ss_interpulse%s_t0%d.mat', channelNames{k},current,i,num2str(numberOfValues/sf),num2str(interpulse_duration/1000),round(updated_t_0)));
                save(filename, 'emg'); % saving raw data
    
            end
            pause(pause_value)
    
            elapsed_time_loop = toc(for_timer); % stop timer
            fprintf('Processing time: %.4f seconds\n', elapsed_time_loop);
    
        end
        disp("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
        
        
    end
    %SetSingleChanState(s, electrode_number, 1, 0, 0);

end

disp("END")
