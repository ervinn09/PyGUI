function [polqaResults, polqaResultsFrame, delay] = getPolqaSquadAnalyzer_v03(refPath, degPath, ii)

squadpath = 'C:\Program Files (x86)\SwissQual\SQuadAnalyzer\';
resultpath = ['C:\Users\Gabriel\Documents\tmp_polqa_results_' num2str(ii) '_.txt'];

while exist(resultpath, 'file')==2
    delete(resultpath)
end

% Run POLQA
oldFolder = cd(squadpath);
cmdStr = ['SQuadAnalyzer "' refPath '" "' degPath '" 3 1 "' resultpath '"'];

[status, result] = system(cmdStr);

if status ~= 0
    cd(oldFolder)
    disp(result)
    error('Something went wrong. ii: %i, ref:%s, deg: %s', ii, refPath, degPath);
    
end
cd(oldFolder)

%% Read result
polqaResults = readSquadResults_v02(resultpath);
opts = detectImportOptions(resultpath); % number of header lines which are to be ignored
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
polqaResultsFrame = readtable(resultpath, opts);

if strcmp(polqaResultsFrame{4,1},'')
    polqaResultsFrame = -1;
    delay = -1;
else
    try
        idxStop = find(isnan(polqaResultsFrame{:,1}),1);
        polqaResultsFrame = polqaResultsFrame(1:idxStop-1,:);
        
        startTime = polqaResultsFrame.FramePositionInReference_s_(1) + polqaResults.StartDelayms/1000;
        nFrames = size(polqaResultsFrame,1);
        
        fs = 48e3;
        stopTime = (nFrames-1)*512/fs+startTime;
        tFrame = startTime:512/fs:stopTime;
        
        polqaResultsFrame.tFrame = tFrame';
        
        polqaResultsFrame.Properties.VariableNames(1) = {'tFrameRef'};
        polqaResultsFrame.Properties.VariableNames(2) = {'Similarity'};
        polqaResultsFrame.Properties.VariableNames(3) = {'SignalEnvelopeRef'};
        polqaResultsFrame.Properties.VariableNames(4) = {'SignalEnvelopeDeg'};
        polqaResultsFrame.Properties.VariableNames(5) = {'PerceptualSpeechSignalLoss'};
        polqaResultsFrame.Properties.VariableNames(6) = {'SignalGainTrend'};
        polqaResultsFrame.Properties.VariableNames(7) = {'NoiseLevelTrend'};
        
        % delay
        %     infoRef = audioinfo(refPath);
        %
        %     tRef = (0:infoRef.TotalSamples-1)'/fs;
        %
        %     delayWin = polqaResultsFrame.tFrame - polqaResultsFrame.tFrameRef;
        %     tWin = polqaResultsFrame.tFrameRef;
        %
        %     [tWin, index] = unique(tWin);
        %     delayWin = delayWin(index);
        %
        %     delay = interp1(tWin, delayWin, tRef);
        
        infoDeg = audioinfo(degPath);
        
        tDeg = (0:infoDeg.TotalSamples-1)'/fs;
        
        delayWin = polqaResultsFrame.tFrame - polqaResultsFrame.tFrameRef;
        tWin = polqaResultsFrame.tFrame;
        
        delay = interp1(tWin, delayWin, tDeg);
        
    catch
        polqaResultsFrame = -1;
        delay = -1;
    end
end



%%
while exist(resultpath, 'file')==2
    delete(resultpath)
end

end