% Initialisation Port Com
addpath(genpath(strcat(pwd,'\ComPortFunc')));
addpath(genpath(strcat(pwd,'\MiscFunc')));

ComPort        = 'COM9';
Baudrate       = 115200*8;   %921600

run('OpenComPort.m'); %
clc;

%% Try buster pulses - Paired Pulses

CARRIER_FREQ = 10e3;
STIMULATION_FREQ = 30;

% this is the 
burst_single_phase_pulse_duration = uint32( 480 ); % us. Remember this is half of the duration of a bi-phasic pulse -  500us
burst_duration                    = uint32( 1000 ); % us. The total duration of a burster (made of several short bi-phasic pulses)
burst_inner_pulse_repetition = 1;     % the number of inner bi-phasic pulses in a burster. 
burst_interpulse_duration = uint32( 0 *1000); % us - ms. time between two bi-phasic pulses in a burster (Paired pulse - 35-50k)
burst_pulse_deadtime = uint32( 19 );        % us - 20 is the minimum
burst_interframe_duration = uint32(1000000); % us to ms ...33ms. / 6000000 - 6s
%burst_interframe_duration = uint32( 1e6 * 1/STIMULATION_FREQ - ...    % this is the burst frequency in us
                                  %      (burst_inner_pulse_repetition * (2 * burst_single_phase_pulse_duration + burst_pulse_deadtime) ) ... % the total duration of the bi-phasic pulses including deadtime
                                   %     ) ; % us. This is the time between two bursters. 
burster_pulse_amplitude =  110; % mA

%% Single Pulse Mode - All Parameters - Trigger Mode 
SetSingleChanAllParam_v2(s, 0, ...
                        burst_single_phase_pulse_duration, ...    % pulseDurationUS
                        burst_pulse_deadtime, ...                 % deadTimeUS
                        burst_interpulse_duration, ...            % interpulseDurationUS
                        burst_interframe_duration, ...            % interframeDurationUS
                        burst_inner_pulse_repetition, ...         % numberOfPulsesPerFrame
                        burster_pulse_amplitude, ...               % IAmplitude in mA
                        1 ...                                     % Trigger Mode = 1. Continuous Mode = 0
                        );  

%% Active HV, OFF output
SetSingleChanState(s, 0, 1, 1, 0);
%% Single Pulse Mode
SetSingleChanSingleParam_v2(s, 0, 8, 1) %Disable continuous mode

%% Send Single Pulse
SetSingleChanState(s, 0, 1, 1, 1); %send pulse

%% stop output and HV
SetSingleChanState(s, 0, 1, 0, 0);