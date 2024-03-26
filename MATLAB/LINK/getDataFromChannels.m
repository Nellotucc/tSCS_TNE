function stacked_data = getDataFromChannels(chs,sampleRate, numberOfValuesmax)
    % This function allows to call getDataFromChannels with multiple
    % channels
    % chs: channels parameter
    % Example: getDataFromChannels({0,2});

    data_list = {};
    for i = 1:length(chs)
        channel = chs{i};
        data = getDataFromChannel(channel, sampleRate, numberOfValuesmax);
        data_list{i} = data;
        
    end

    % Horizontally concatenate the cell array into a single matrix
    %stacked_data = horzcat(data_list{:});
    %stacked_data = data_list;
    stacked_data = vertcat(data_list{:});

end

