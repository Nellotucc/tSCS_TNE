function plot_signal()
    t = 0:0.01:2*pi;
    signal = sin(t);
    
    plot(t, signal);
    title('Signal Plot');
    xlabel('Time');
    ylabel('Amplitude');
end
