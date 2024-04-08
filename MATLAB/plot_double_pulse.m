function [pulse] = plot_double_pulse(pulse_deadtime,interpulse_duration,pulse_width,values_before_stim,values_after_stim,bool_microseconds)
%PLOT_PULSE Summary
% plot the double pulse stimulus for an easier
% visual analysis of the EMG

%bool_microseconds is to know if the parameters are in microseconds and
%need to be converted to ms
if bool_microseconds
    pulse_width = pulse_width/1000; % convert to ms
    interpulse_duration = interpulse_duration/1000;
    pulse_deadtime = pulse_deadtime/1000;

end





t = -values_before_stim:0.01:values_after_stim;
pulse = zeros(size(t));  % Initialize with zeros
pulse(t >= 0 & t < pulse_width) = 1;  % Set values to 1 in the pulse width
pulse(t >= pulse_width & t < pulse_width+pulse_deadtime) = 0;  % Set values to 0 for the deadtime
pulse(t >= pulse_width+pulse_deadtime & t < 2*pulse_width+pulse_deadtime) = -1; 

pulse(t >= 0+interpulse_duration & t < pulse_width+interpulse_duration) = 1;  % Set values to 1 in the pulse width
pulse(t >= pulse_width+interpulse_duration & t < pulse_width+pulse_deadtime+interpulse_duration) = 0;  % Set values to 0 for the deadtime
pulse(t >= pulse_width+pulse_deadtime+interpulse_duration & t < 2*pulse_width+pulse_deadtime+interpulse_duration) = -1; 

plot(pulse(1:200));


end

