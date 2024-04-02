function [string_response] = binary2response(binary_response)
%BINARY2RESPONSE Summary of this function goes here
%   Detailed explanation goes here
    % Initialize the cell array to store mapped responses
    string_response = cell(size(binary_response));

    % Iterate over each element in the binary array
    for i = 1:numel(binary_response)
        % Check if the current element is 1, if yes, map it to 'reflex'
        if binary_response(i) == 1
            string_response{i} = 'reflex response';
        % Check if the current element is 0, if yes, map it to 'not reflex'
        else
            string_response{i} = 'not reflex response';
        end
    end
end