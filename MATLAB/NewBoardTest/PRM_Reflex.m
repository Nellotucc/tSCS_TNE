% Initialisation Port Com
addpath(genpath(strcat(pwd,'\ComPortFunc')));
addpath(genpath(strcat(pwd,'\MiscFunc')));

ComPort        = 'COM8';
Baudrate       = 115200*8;   %921600

run('OpenComPort.m'); %
clc;

%% Disable everything for channel 0
SetSingleChanState(s, 0, 0, 0, 0); %   

%% Active channel
SetSingleChanState(s, 0, 1, 0, 0); %   

%% Active channel and HV
SetSingleChanState(s, 0, 1, 1, 0); 

%% Define parameters

CARRIER_FREQ = 10e3; % Not used for PRM reflex
STIMULATION_FREQ = 30; % Not used for PRM reflex

% this is the 
pulse_width = uint32(490); % us --- Fixed --- Remember this is half of the duration of a bi-phasic pulse
pulse_width_1pulse                    = uint32(1000); % us --- Fixed --- The total duration of a burster (made of several short bi-phasic pulses)
N_pulse_repetition = 1;     % --- Insert 1 to Single Pulse (SP)-  2 to Double Pulse (DP) --- the number of inner bi-phasic pulses in a burster.   
interpulse_duration = uint32(50 *1000); % us - ms --- for Double pulse. Usually between 35-100ms --- time between two bi-phasic pulses. 
pulse_deadtime = uint32(20);        % us - --- Fixed ---  20 is the minimum
interframe_duration = uint32( 5000000 ); % us - s 
%burst_interframe_duration = uint32( 1e6 * 1/STIMULATION_FREQ - ...    % --- Not used for PRM reflex --- 
%                                       (burst_inner_pulse_repetition * (2 * burst_single_phase_pulse_duration + burst_pulse_deadtime) ) ... % the total duration of the bi-phasic pulses including deadtime
%                                       ) ; % us. This is the time between two bursters. - Not necessary for SP and DP
current =  30; % mA
max_current = 10; % mA

%% Set parameters
SetSingleChanAllParam(s, 0, ...
                        pulse_width, ...    % pulseDurationUS
                        pulse_deadtime, ...                 % deadTimeUS
                        interpulse_duration, ...            % interpulseDurationUS
                        interframe_duration, ...            % interframeDurationUS
                        N_pulse_repetition, ...         % numberOfPulsesPerFrame
                        current ...               % IAmplitude in mA
                        );

%% Enable Trigger Mode
SetSingleChanSingleParam_v2(s, 0, 7, 0) % Trigger mode (7), Output
SetSingleChanState(s, 0, 1, 1, 0) %  Output disabled 

%%  PRM - Double Pulse. For the recruitment curve, 3 reps for each current
current =  0;
SetSingleChanState(s, 0, 1, 1, 1);

for j = 1: 10    % Need to be increase if 
    current = 0 + j*5; % mA 
    SetSingleChanSingleParam(s, 0, 6, current)

    for i = 1: 3  % Number of repetitions
        % Enable Output
        disp(['Repetition: ', num2str(i)]);
        disp(['Current: ', num2str(current)]);
        pause(5);
    end
    
end

SetSingleChanState(s, 0, 1, 1, 0);

%% stop all
SetSingleChanState(s, 0, 1, 0, 0);


%% Continuous Mode
SetSingleChanSingleParam_v2(s, 0, 7, 0) %Disable:1 Enable:0 . 

%%
fclose(s);
delete(s);
clear s;