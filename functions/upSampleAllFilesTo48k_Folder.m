inDir = 'C:\Users\Gabriel\Documents\NISQA\FB_PSAMD_VAL_SIM\ref\';
outDir = 'C:\Users\Gabriel\Documents\NISQA\FB_PSAMD_VAL_SIM\ref_48k\';

D = dir( inDir );
global pcmInPath pcmTmpPath1 pcmOutPath
N = size(D,1);
for i = 1:N
    
    fileName = D(i).name;
    folderName = D(i).folder;
    
    if endsWith(fileName, '.wav')
        
        wavInPath = [folderName '\' fileName];
        
%         wavOutPath = [outDir fileName(1:end-8) '.wav'];
        wavOutPath = [outDir fileName(1:end-4) '.wav'];
        
        pcmInPath = 'tmp_src_speech.pcm';
        pcmTmpPath1 = 'tmp1_speech.pcm';
        pcmOutPath = 'tmp_out_speech.pcm';
        
        deleteTmpFiles()
        
        
        [x, fs, srcFileLength] = wav2pcm(wavInPath, pcmInPath);
        
        switch fs
            
            
            case 48e3
                
                pcmOutPath = pcmInPath;
                
            case 32e3
                
                [fs, fileLengthNew] = pcmUp3(pcmInPath, pcmTmpPath1, srcFileLength, fs);
                fs = pcmDown2(pcmTmpPath1, pcmOutPath, fileLengthNew, fs);
                
            case 16e3
                
                [fs, fileLengthNew] = pcmUp3(pcmInPath, pcmOutPath, srcFileLength, fs);
                
                
            case 8e3
                
                [fs, fileLengthNew] = pcmUp2(pcmInPath, pcmTmpPath1, srcFileLength, fs);
                fs = pcmUp3(pcmTmpPath1, pcmOutPath, fileLengthNew, fs);
                
            otherwise
                error('wrong input sample frequency')
        end
        %%
        x48 = pcmread(pcmOutPath);
        audiowrite( wavOutPath, x48, fs );
        deleteTmpFiles()
        
    end
    printProgress(i,N)
end

function deleteTmpFiles()
global pcmInPath pcmTmpPath1 pcmOutPath

while exist([pwd '\' pcmInPath], 'file')==2
    delete(pcmInPath)
end
while exist([pwd '\' pcmTmpPath1], 'file')==2
    delete(pcmTmpPath1)
end
while exist([pwd '\' pcmOutPath], 'file')==2
    delete(pcmOutPath)
end

end

