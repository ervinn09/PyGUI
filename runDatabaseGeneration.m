% this script automatically creates speech database with conditions taken from a condition table
addpath('functions')  
addpath('voicebox')  

% !!!!!!!!!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!!!!!!!!
% !! Folders are not allowed to have spaces in them !!!
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

sourcFolder = 'C:\Database_Generation3\ref'; % folder containing clean reference signals
outputFolder = 'C:\Database_Generation3\deg'; % output folder
noiseFolder = 'C:\Database_Generation3\noise'; % random noise .wav files will be selected from here

% The tmpFolder needs to have a trailing backspace!
tmpFolder = 'C:\Database_Generation3\tmp\'; % folder for temporary files (files will be deleted, at least if no error happens)

%% CREATE CONDITION LIST
% this function writes a table with conditions. this could also be manually
% created in Excel. 
%
% supports the codecs: amr-nb, amr-wb, g711, g722, opus, evs. in all
% bitrate modes and with random/bursty packet-loss. background noises,
% white noise, mnru, speech level, highpass/lowpass/bandpass and arbitrary
% filter, clipping. also, all available combinations of these distortions.
%
% two examples are available:

% this was used for NISQA_TEST_P501 dataset with 60 conditions (noise files are here randomly selected and noise filename saved within condition table "tConditions")
tConditions = makeConditionTable_NISQA_TEST_P501(noiseFolder);

% this was used for NISQA_TRAIN_SIM dataset with 10k conditions (noise files are randomly selected later during dataset generation)
% tConditions = makeConditionTable_NISQA_TRAIN_SIM(); 

%% CREATE FILE LIST
% this function writes a table with the files that are used for each
% condition. can be adjusted if, e.g., not all files should be used for
% each condition. Could also be manually written in Excel.

tRef = makeFilelist(tConditions, sourcFolder);

%% GENERATE DEGRADED FILES
% This function generates the database within a parallel for loop
tFile = generateDatabaseWithParallelLoops(tConditions, tRef, sourcFolder, outputFolder, noiseFolder, tmpFolder);

writetable(tFile, 'per_file.csv') % save filenames and conditions in table
















