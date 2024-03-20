function [emg_dd] = Laplace(emg,sf,bool_plot)
%LAPLACE Summary of this function goes here

    % Assuming you have your EMG signal stored in 'emg'
    
    % Compute the non-causal double differentiation emg_dd
    dt = 1/sf; % You may need to adjust this value based on your sampling rate
    
    % Compute emg_dd using finite difference approximation
    emg_dd = abs(gradient(gradient(emg, dt), dt));

    if bool_plot
        % Plotting for visualization
        figure;
        subplot(2,1,1);
        plot(emg);
        xlabel('Time');
        ylabel('EMG Signal');
        title('Original EMG Signal');
        
        subplot(2,1,2);
        plot(emg_dd);
        xlabel('Time');
        ylabel('EMG Double Differentiation');
        title('Non-Causal Double Differentiation of EMG Signal');
    end
    

end

