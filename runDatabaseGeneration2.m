function runDatabaseGeneration2(filePath)
     
    addpath('functions')  
    addpath('voicebox') 
    
    % Define variables
    sourcFolder = 'C:\Database_Generation3\ref';
    outputFolder = 'C:\Database_Generation3\deg';
    noiseFolder = 'C:\Database_Generation3\noise';
    tmpFolder = 'C:\Database_Generation3\tmp\';

    %% CREATE FILE LIST
    tConditions = readtable(filePath, 'TextType', 'string');
    tRef = makeFilelist(tConditions, sourcFolder);
    
    %% GENERATE DEGRADED FILES
    % This function generates the database within a parallel for loop
    tFile = generateDatabaseWithParallelLoops(tConditions, tRef, sourcFolder, outputFolder, noiseFolder, tmpFolder);
    
    writetable(tFile, 'per_file.csv') % save filenames and conditions in table

    % Add 'functions' and 'voicebox' directories to MATLAB path
    
end



