addpath('functions')  
addpath('voicebox')

sourcFolder = 'C:\Database_Generation3\ref'; % folder containing clean reference signals
outputFolder = 'C:\Database_Generation3\deg'; % output folder
noiseFolder = 'C:\Database_Generation3\noise'; % random noise .wav files will be selected from here

% The tmpFolder needs to have a trailing backspace!
tmpFolder = 'C:\Database_Generation3\tmp\';
