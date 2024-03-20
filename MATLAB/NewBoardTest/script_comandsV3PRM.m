% Initialisation Port Com
addpath(genpath(strcat(pwd,'\ComPortFunc')));
addpath(genpath(strcat(pwd,'\MiscFunc')));

ComPort        = 'COM8';
Baudrate       = 115200*8;   %921600

run('OpenComPort.m'); %
clc;

%% Disable everything for channel 0
%SetSingleChanState(s, 0, 0, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
SetSingleChanState(s, 1, 0, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
%SetSingleChanState(s, 2, 0, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
%SetSingleChanState(s, 3, 0, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
%SetSingleChanState(s, 4, 0, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
%SetSingleChanState(s, 5, 0, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)


%% Disable everything for channel 0
SetSingleChanState(s, 0, 1, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
SetSingleChanState(s, 1, 1, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
SetSingleChanState(s, 2, 1, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
SetSingleChanState(s, 3, 1, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
SetSingleChanState(s, 4, 1, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
SetSingleChanState(s, 5, 1, 0, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)

%% Disable everything for channel 0 / HV
SetSingleChanState(s, 0, 1, 1, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
SetSingleChanState(s, 1, 1, 1, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
SetSingleChanState(s, 2, 1, 1, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
SetSingleChanState(s, 3, 1, 1, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
SetSingleChanState(s, 4, 1, 1, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)
SetSingleChanState(s, 5, 1, 1, 0); % new channel - 1 . Channel 0: (s, 0, 1, 0, 0)


%% Try buster pulses

CARRIER_FREQ = 10e3;
STIMULATION_FREQ = 30;

% this is the 
burst_single_phase_pulse_duration = uint32(480); % us. Remember this is half of the duration of a bi-phasic pulse
burst_duration                    = uint32(1000); % us. The total duration of a burster (made of several short bi-phasic pulses)
burst_inner_pulse_repetition = 1;     % the number of inner bi-phasic pulses in a burster. 
burst_interpulse_duration = uint32(50); % us. time between two bi-phasic pulses in a burster 
burst_pulse_deadtime = uint32( 20 );        % us - 20 is the minimum
%burst_interframe_duration = uint32(0000); % us  - 50000000
burst_interframe_duration = uint32( 1e6 * 1/STIMULATION_FREQ - ...    % this is the burst frequency in us
                                        (burst_inner_pulse_repetition * (2 * burst_single_phase_pulse_duration + burst_pulse_deadtime) ) ... % the total duration of the bi-phasic pulses including deadtime
                                        ) ; % us. This is the time between two bursters. 
burster_pulse_amplitude =  40; % mA

%% HIGH fREQUENCY

STIMULATION_FREQ = 1000;
burster_pulse_amplitude =  40; % mA
burst_inner_pulse_repetition = 1; 
burst_pulse_deadtime = uint32(19);
burst_single_phase_pulse_duration = uint32(31);

burst_duration = uint32(2*burst_single_phase_pulse_duration + burst_pulse_deadtime);


burst_interframe_duration = uint32( 1e6 * 1/STIMULATION_FREQ - ...    % this is the burst frequency in us
                                        (burst_inner_pulse_repetition * (2 * burst_single_phase_pulse_duration + burst_pulse_deadtime) ) ... % the total duration of the bi-phasic pulses including deadtime
                                        ) ; % us. This is the time between two bursters. 

%%
% set burster parameters
SetSingleChanAllParam(s, 0, ...
                        burst_single_phase_pulse_duration, ...    % pulseDurationUS
                        burst_pulse_deadtime, ...                 % deadTimeUS
                        burst_interpulse_duration, ...            % interpulseDurationUS
                        burst_interframe_duration, ...            % interframeDurationUS
                        burst_inner_pulse_repetition, ...         % numberOfPulsesPerFrame
                        burster_pulse_amplitude ...               % IAmplitude in mA
                        );

%% stop output and active HV
SetSingleChanState(s, 1, 1, 1, 0);

%% Mode ON
SetSingleChanSingleParam_v2(s, 1, 8, 1) % Trigger mode - Active 0.  For trigger mode, SetSingleChanSingleParam_v2(s, 0, 8, 0)


%% Mode OFF
SetSingleChanSingleParam_v2(s, 1, 7, 0) %Disable continuous mode: 1 Enable: 0 . For trigger mode ac, SetSingleChanSingleParam_v2(s, 0, 8, )


%%  Script PRM

    for i = 1: 5

        pause(0.05);
        SetSingleChanState(s, 1, 1, 1, 1);
        pause(1);
        SetSingleChanState(s, 1, 1, 1, 0); %HV disable
    end

%% stop output and HV
SetSingleChanState(s, 0, 1, 1, 0);

%% Therapeutic protocol

% Set parameters

CARRIER_FREQ = 10e3; %dont using
STIMULATION_FREQ = 30;

% this is the 
burst_single_phase_pulse_duration = uint32( 500 ); % us. Remember this is half of the duration of a bi-phasic pulse
burst_duration                    = uint32( 1000 ); % us. The total duration of a burster (made of several short bi-phasic pulses)
burst_inner_pulse_repetition = 1;     % the number of inner bi-phasic pulses in a burster. 
burst_interpulse_duration = uint32( 0 *1000); % us. This is ideally set to 0 because there is no time between two bi-phasic pulses in a burster
burst_pulse_deadtime = uint32( 20 );        % us - 20 is the minimum
burst_interframe_duration = uint32(0 *1000); % us to ms ...33ms
%burst_interframe_duration = uint32( 1e6 * 1/STIMULATION_FREQ - ...    % this is the burst frequency in us
                                  %      (burst_inner_pulse_repetition * (2 * burst_single_phase_pulse_duration + burst_pulse_deadtime) ) ... % the total duration of the bi-phasic pulses including deadtime
                                   %     ) ; % us. This is the time between two bursters. 
burster_pulse_amplitude =  40; % mA

% set burster parameters
SetSingleChanAllParam(s, 0, ...
                        burst_single_phase_pulse_duration, ...    % pulseDurationUS
                        burst_pulse_deadtime, ...                 % deadTimeUS
                        burst_interpulse_duration, ...            % interpulseDurationUS
                        burst_interframe_duration, ...            % interframeDurationUS
                        burst_inner_pulse_repetition, ...         % numberOfPulsesPerFrame
                        burster_pulse_amplitude ...               % IAmplitude in mA
                        );
%% Active HV
SetSingleChanState(s, 0, 1, 1, 0);
%% Start output
 pause(0.05);
 SetSingleChanState(s, 0, 1, 1, 1);

  %% stop output 
SetSingleChanState(s, 0, 1, 1, 0);
 
 %% stop output and HV
SetSingleChanState(s, 0, 1, 0, 0);

%%  Teste individual
%SetSingleChanSingleParam(s, 0, 6, 15)
%SetSingleChanState(s, 0, 1, 1, 0); %HV enable
SetSingleChanState(s, 0, 1, 1, 1);
%SetSingleChanSingleParam(s, 0, 6, 0)


%%
fclose(s);
delete(s);
clear s;