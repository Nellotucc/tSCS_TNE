function plot_recruitement_curve(directories,amplitudes_all_dir,amplitude_std_all_dir,show_std,current_i,current_f)
%PLOT_RECRUITEMENT_CURVE Summary of this function goes here

    % Initialize figure
    figure;
    hold on;

    % Colors for shading
    %colors = {'b', 'y','g'}; % You can adjust colors as needed
    %colors = { [44, 160, 44] / 255, [148, 103, 189] / 255, [140, 86, 75] / 255, [227, 119, 194] / 255, [127, 127, 127] / 255, [188, 189, 34] / 255, [23, 190, 207] / 255};
    colors = {[31, 120, 180] / 255, ...  % Dark blue
        [255, 127, 0] / 255, ...   % Dark orange
        [106, 61, 154] / 255,...   % Dark purple
        [166, 206, 227] / 255, ... % Light blue
        [253, 191, 111] / 255, ... % Light orange
        [202, 178, 214] / 255, ... % Light purple
        [178, 223, 138] / 255, ... % Light green
        [51, 160, 44] / 255, ...   % Dark green
        [251, 154, 153] / 255, ... % Light red
        [227, 26, 28] / 255};   % Dark red

    current_values = current_i:5:current_f;

    for dir_index = 1:numel(directories)
        amplitudes = amplitudes_all_dir(dir_index,:);
        amplitude_values = cell2mat(amplitudes);
        plot(current_values, amplitude_values, 'o-', 'Color', colors{dir_index}, 'LineWidth', 1, 'DisplayName', sprintf('Directory %d', dir_index));

        if show_std
            amplitude_std = amplitude_std_all_dir(dir_index,:);
            amplitude_std_values = cell2mat(amplitude_std);
            fill([current_values, fliplr(current_values)], [amplitude_values + amplitude_std_values, fliplr(amplitude_values - amplitude_std_values)], colors{dir_index}, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end

    end
    % Add labels and title
    xlabel('Current (mA)');
    ylabel('Amplitude');
    title('Amplitude vs Current');
    legend('show');
    grid on;
    hold off; % Release the hold on the plot
end

