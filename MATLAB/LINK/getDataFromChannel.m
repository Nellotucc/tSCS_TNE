function data = getDataFromChannel(ch,sampleRate, numberOfValuesmax)
    % ch: channel parameter
    % Example: getDataFromChannel(0);

    values = libstruct('tagSAFEARRAY');
    numberOfValues = getData(ch, sampleRate, numberOfValuesmax, values);

    if (numberOfValues > 0)
        %plot(values.pvData);
    else
        str = ['getData returned ', num2str(numberOfValues),' from channel ', num2str(ch)];
        disp(str);
    end

    %disp(values);
    data = values.pvData;
end

% COMPRENDRE QUI RETURN POUR AVOIR LE SIGNAL EMG UNIQUEMENT,
% VALUES.PVDATA??