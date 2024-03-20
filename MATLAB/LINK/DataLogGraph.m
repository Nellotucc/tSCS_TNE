
int32 ch;
ch = 0;	% will need to be changed to match the sensor channel
values = libstruct('tagSAFEARRAY');
numberOfValues = getData(ch, 1000, 50000, values); % ch, Sample rate 2500 au début changé à 1000, numberOfValues, values
if (numberOfValues > 0)
    plot(values.pvData);
else
    str = ['getData returned ', num2str(numberOfValues),' from channel ', num2str(ch)];
    disp(str);
end

disp((values))

