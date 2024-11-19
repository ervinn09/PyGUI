function insertFrameLoss(inPath, outPath, fer, nburst)

% execute runPLC in folder which contains this function
path = strrep(which(mfilename),[mfilename '.m'],'');
oldFolder = cd(path);

info = audioinfo(inPath);
fs = info.SampleRate; 

% insert frame loss
cmdStr = ['InsertFrameLosses "' char(inPath) '" ' sprintf('%i', fs) ' ' sprintf('%i', fer) ' ' sprintf('%i', nburst) ' "' char(outPath) '"'];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong, %s, %s', inPath, outPath);
end

cd(oldFolder);

end


