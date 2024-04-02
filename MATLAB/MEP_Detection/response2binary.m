function [binary_response] = response2binary(responses)
%MAP_RESPONSE Summary of this function goes here
%   Detailed explanation goes here
% Initialize the binary response array
binary_response = zeros(size(responses));

% Iterate over each element in the cell array
for i = 1:numel(responses)
    % Check if the current element is 'reflex response', if yes, map it to 1
    if strcmp(responses{i}, 'reflex response')
        binary_response(i) = 1;
        % Check if the current element is not reflex, if yes, map it to 0
    else
        binary_response(i) = 0;
    end
end
end
