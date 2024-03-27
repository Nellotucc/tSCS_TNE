function [f,subplotWidth,subplotHeight] = create_figure(numberOfchannels)
%CREATE_FIGURE Summary of this function goes here
%   Detailed explanation goes here

f = figure; % Adjust width and height as needed
pos1 = f.Position(1)-f.Position(1)/1.5;
pos2 = f.Position(2)-f.Position(2)/2;
f.Position(1:4) = [pos1,pos2,2000,800];
% Define the margins and gaps
leftMargin = 0.03;
rightMargin = 0.02;
topMargin = 0.1;
bottomMargin = 0.1;
horizontalGap = 0.02;
verticalGap = 0.1;

% Calculate the total width and height available for subplots
totalWidth = 1 - leftMargin - rightMargin - (numberOfchannels - 1) * horizontalGap;
totalHeight = 1 - topMargin - bottomMargin - verticalGap;

% Calculate the width and height of each subplot
subplotWidth = totalWidth / numberOfchannels;
subplotHeight = totalHeight; % Two rows
end

