% Initialisation Port Com
addpath(genpath(strcat(pwd,'\ComPortFunc')));
addpath(genpath(strcat(pwd,'\MiscFunc')));

ComPort        = 'COM9';
Baudrate       = 115200*8;   %921600

run('OpenComPort.m'); %
clc;

%% Disable everything for channel 0
SetSingleChanState(s, 0, 0, 0, 0);

%% Try buster pulses

CARRIER_FREQ = 10e3;
STIMULATION_FREQ = 30;

% this is the 
burst_single_phase_pulse_duration = uint32( 500 ); % us. Remember this is half of the duration of a bi-phasic pulse
burst_duration                    = uint32( 1000 ); % us. The total duration of a burster (made of several short bi-phasic pulses)
burst_inner_pulse_repetition = 1;     % the number of inner bi-phasic pulses in a burster. 
burst_interpulse_duration = uint32( 0 *1000); % us. This is ideally set to 0 because there is no time between two bi-phasic pulses in a burster
burst_pulse_deadtime = uint32( 20 );        % us 
burst_interframe_duration = uint32(0 *1000); % us to ms ...33ms?
%burst_interframe_duration = uint32( 1e6 * 1/STIMULATION_FREQ - ...    % this is the burst frequency in us
                                  %      (burst_inner_pulse_repetition * (2 * burst_single_phase_pulse_duration + burst_pulse_deadtime) ) ... % the total duration of the bi-phasic pulses including deadtime
                                   %     ) ; % us. This is the time between two bursters. 
burster_pulse_amplitude =  5; % mA

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

%% stop output
SetSingleChanState(s, 0, 1, 0, 0);

%% Test with HV active all the time / Parece melhor

for j = 1: 12
    burster_pulse_amplitude =  0 + j*5; % mA 
    burster_pulse_amplitude
 % set burster parameters
 SetSingleChanAllParam(s, 0, ...
                        burst_single_phase_pulse_duration, ...    % pulseDurationUS
                        burst_pulse_deadtime, ...                 % deadTimeUS
                        burst_interpulse_duration, ...            % interpulseDurationUS
                        burst_interframe_duration, ...            % interframeDurationUS
                        burst_inner_pulse_repetition, ...         % numberOfPulsesPerFrame
                        burster_pulse_amplitude ...               % Amplitude in mA
                        );
 % stop output - ver se precisa disso
SetSingleChanState(s, 0, 1, 0, 0);

    for i = 1: 3
        SetSingleChanState(s, 0, 1, 1, 0); %HV enable
        pause(0.05);
        SetSingleChanState(s, 0, 1, 1, 1);
    
        pause(0.05);
        SetSingleChanState(s, 0, 1, 1, 0); %HV disable
        pause(5);
        i
    end
    %pause(5);
end

SetSingleChanState(s, 0, 1, 0, 0);

%%
fclose(s);
delete(s);
clear s;