function errorPat = genErrPttrn_v03(plcMode, options, nFrames, frameLength, codecDelay, fs, tmp_err_pttrn, stateVarFileName)


errorRate = options.errorRate;
burstR = options.burstR;
tLossLocation = options.tLossLocation;
nLostFrames = options.nLostFrames; 

if strcmp(plcMode,'noloss') || strcmp(plcMode,'-')
    errorRate = 0;
end

%% generate error pattern

% -------------------------------------------------------------------------
if strcmp(plcMode, 'noloss') || strcmp(plcMode,'-')
    % generate error pattern
    errorPat = int16(27425.*ones(nFrames,1));
    
    % save error pattern
    fileID = fopen(tmp_err_pttrn,'w');
    if (fileID < 0)
        error('output error pattern cannot be created')
    end
    fwrite(fileID, errorPat, 'int16');
    fclose(fileID);
    
    % -------------------------------------------------------------------------
elseif strcmp(plcMode, 'bursty')  % use EID tool to create bursty pattern according to bellcore model
    cmdStr = sprintf('gen-patt -g192 -tol 0.005 %s B %i 1 %s %f', tmp_err_pttrn, nFrames, stateVarFileName, errorRate);
    [status, result] = system(cmdStr);
    if status ~= 0
        disp(result)
        error('Something went wrong');
    end
    
    % -------------------------------------------------------------------------
elseif strcmp(plcMode, 'random')  % use EID tool to create random pattern according to gilbert model
    cmdStr = sprintf('gen-patt -g192 -tol 0.005 %s F %i 1 %s %f', tmp_err_pttrn, nFrames, stateVarFileName, errorRate);
    [status, result] = system(cmdStr);
    if status ~= 0
        disp(result)
        error('Something went wrong');
    end
    
    % -------------------------------------------------------------------------
elseif strcmp(plcMode, 'location') % use loss locations from input
    % calc location from seconds to samples
    sampleLossLocation = round( tLossLocation*fs );
    
    % find the packet location
    packetVector = (1:nFrames).*frameLength - frameLength/2 - codecDelay;
    nPacketsLossLocation = nan(length(sampleLossLocation),1);
    for i = 1:length(sampleLossLocation)
        [~, nPacketsLossLocation(i)] = min(abs(packetVector-sampleLossLocation(i)));
    end
    
    % generate error pattern
    errorPat = int16(27425.*ones(nFrames,1));
    for i = 1:length(sampleLossLocation)
        if length(nLostFrames) == 1
            nLostFramesI = nLostFrames;
        else
            nLostFramesI = nLostFrames(i);
        end
        errorPat(nPacketsLossLocation(i):nPacketsLossLocation(i)+nLostFramesI-1) = 27424;
    end
    
    % save error pattern
    fileID = fopen(tmp_err_pttrn,'w');
    if (fileID < 0)
        error('output error pattern cannot be created')
    end
    fwrite(fileID, errorPat, 'int16');
    fclose(fileID);
    
    % -------------------------------------------------------------------------
elseif strcmp(plcMode, 'pattern') % use loss locations from input
    % calc location from seconds to samples
    sampleLossLocation = round( tLossLocation*fs );
    
    % find the packet location
    packetVector = (1:nFrames).*frameLength - frameLength/2 - codecDelay;
    nPacketsLossLocation = nan(length(sampleLossLocation),1);
    for i = 1:length(sampleLossLocation)
        [~, nPacketsLossLocation(i)] = min(abs(packetVector-sampleLossLocation(i)));
    end
    
    % generate error pattern
    errorPat = int16(27425.*ones(nFrames,1));
    nLostFrames = ~nLostFrames + 27424;
    for i = 1:length(sampleLossLocation)
        nLostFramesI = length(nLostFrames);
        errorPat(nPacketsLossLocation(i):nPacketsLossLocation(i)+nLostFramesI-1) = nLostFrames;
    end
    
    % save error pattern
    fileID = fopen(tmp_err_pttrn,'w');
    if (fileID < 0)
        error('output error pattern cannot be created')
    end
    fwrite(fileID, errorPat, 'int16');
    fclose(fileID);    
    
    % -------------------------------------------------------------------------
elseif strcmp(plcMode, 'bursty_thilo') % use loss locations from input

    pattern_output = genpatt_thilo(errorRate, burstR, nFrames);
    
    errorPat = int16(27425.*ones(nFrames,1));
    errorPat(pattern_output==1) = 27424;
    
    % save error pattern
    fileID = fopen(tmp_err_pttrn,'w');
    if (fileID < 0)
        error('output error pattern cannot be created')
    end
    fwrite(fileID, errorPat, 'int16');
    fclose(fileID);    

end % plc mode
% -------------------------------------------------------------------------

%% read error pattern
fileID = fopen(tmp_err_pttrn);
errorPat = fread(fileID,'int16');
fclose(fileID);

errorPat = errorPat - 27424;
end % main function


