function plot_response_test()
    t = 0:0.01:2*pi;
    response = cos(t);
    
    plot(t, response);
    title('Response Plot');
    xlabel('Time');
    ylab = ylabel('Amplitude');
    ylabPos = get(ylab, 'Position');
    ylabPos(1) = ylabPos(1) + 0.5;  % Adjust the position
    set(ylab, 'Position', ylabPos);

end
