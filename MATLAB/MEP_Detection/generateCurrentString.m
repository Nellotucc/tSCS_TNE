function currentString = generateCurrentString(current, numberOfCurrents)
    % Initialize the string with the first current value
    currentString = num2str(current);
    
    % Generate additional currents based on the number of currents
    for i = 1:numberOfCurrents-1
        % Calculate the next current value by adding 5
        nextCurrent = current + i * 5;
        
        % Append the next current value to the string
        currentString = [currentString, '-', num2str(nextCurrent)];
    end
end

