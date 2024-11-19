function upsampleTo48k(inPath, outPath, ii, fs)

if nargin<4
    fs=-1;
end

%%
path = strrep(which(mfilename),[mfilename '.m'],'');
oldFolder = cd(path);

%%
global pcmInPath;
global pcmTmpPath1;
global pcmOutPath;

tmpvar = evalin('base', 'tmpFolder');

pcmInPath = [tmpvar 'pcmInPath_' num2str(ii) '.tmp'];
pcmTmpPath1 = [tmpvar 'pcmTmpPath1_' num2str(ii) '.tmp'];
pcmOutPath = [tmpvar 'pcmOutPath_' num2str(ii) '.tmp'];

deleteTempFiles()

%%

if endsWith(inPath, '.wav')
    [~, fs, srcFileLength] = wav2pcm(inPath, pcmInPath);
else
    copyfile(inPath, pcmInPath);
    srcFileLength = length(pcmread(pcmInPath));
end

switch fs
    
    case 48e3
        pcmOutPath = pcmInPath;
        
    case 32e3
        [fs, fileLengthNew] = pcmUp3_v02(pcmInPath, pcmTmpPath1, srcFileLength, fs, ii);
        fs = pcmDown2_v02(pcmTmpPath1, pcmOutPath, fileLengthNew, fs, ii);
        
    case 16e3
        fs = pcmUp3_v02(pcmInPath, pcmOutPath, srcFileLength, fs, ii);
        
    case 8e3
        [fs, fileLengthNew] = pcmUp2_v02(pcmInPath, pcmTmpPath1, srcFileLength, fs, ii);
        fs = pcmUp3_v02(pcmTmpPath1, pcmOutPath, fileLengthNew, fs, ii);
        
    otherwise
        error('wrong input sample frequency')
end


%%
x48 = pcmread(pcmOutPath);
audiowrite( outPath, x48, fs );
deleteTempFiles()

cd(oldFolder);


end

%%


function deleteTempFiles()
warning off

global pcmInPath;
global pcmTmpPath1;
global pcmOutPath;

fclose all;

while exist(pcmInPath, 'file')==2
    delete(pcmInPath)
end

while exist(pcmTmpPath1, 'file')==2
    delete(pcmTmpPath1)
end

while exist(pcmOutPath, 'file')==2
    delete(pcmOutPath)
end

end









