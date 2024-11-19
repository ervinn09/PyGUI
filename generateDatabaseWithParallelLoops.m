function tFile = generateDatabaseWithParallelLoops(t, tLoop, srcFolder, degPath, noiseFolder, tmpFolder)
% change parfor to for if should be run without parallel (e.g. for
% debugging)

% spmd
%     warning('off','MATLAB:audiovideo:audiowrite:dataClipped')
% end

optionsDist = struct;
optionsDist.noiseFolder = noiseFolder;

stepSize = 1000; % number of files in each parallel loop part

tFile = table;
N = height(tLoop);
idx = 1:N;
nParts = ceil(length(idx)/stepSize);

disp('nParts')
disp(nParts)

ticAll = tic;

for iPart = 1:nParts
    
    ticPart = tic;
    
    iCurrent = (iPart-1)*stepSize+1;
    idxStop = iCurrent+stepSize-1;
    idxStop = min(idxStop, length(idx));
    
    idxI = idx(iCurrent:idxStop);
    
    
    parfor ii = idxI
        
        filename = tLoop.filename{ii};
        iCon = tLoop.con(ii);
        tt = t(t.con==iCon,:);
        
%             tFileTmp = generateDegradedSignal(filename, srcFolder, degPath, tt, optionsDist, tmpFolder, ii);
        try
            tFileTmp = generateDegradedSignal(filename, srcFolder, degPath, tt, optionsDist, tmpFolder, ii);
        catch
            fprintf('error - wait 60 seconds and try again: %i\n', ii)
            fclose all;
            pause(1)
            tFileTmp = generateDegradedSignal(filename, srcFolder, degPath, tt, optionsDist, tmpFolder, ii+1e6);
            fprintf('retry worked ..\n')
        end
        
        tFile = [tFile; tFileTmp];
        
    end
    toc(ticPart)
    fprintf('%i / %i\n', iPart, nParts)
    
    iCurrent = iCurrent+stepSize;
    
end
toc(ticAll)
end