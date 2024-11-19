inDir = 'D:\Soundfiles\POLQA_DBs\_UNSORTED\benchmark_TRAINING_PCM\NB_BT_P862_PROP\reference\';
outDir = 'D:\Soundfiles\NISQA\NB_48kHz_BT_P862_PROP\ref\';
% 
D = dir( inDir );


global pcmTmpPath1 pcmOutPath
fsSrc = 8e3;
N = size(D,1);
for i = 1:N
    
    fileName = D(i).name;
    folderName = D(i).folder;
    
    if endsWith(fileName, '.OUT') || endsWith(fileName, '.SRC') || endsWith(fileName, '.pcm')
        
        pcmInPath = [folderName '\' fileName];
        
        wavOutPath = [outDir '\' fileName(1:end-4) '.wav'];
        
        pcmTmpPath1 = 'tmp1_speech.pcm';
        pcmOutPath = 'tmp_out_speech.pcm';
        
        deleteTmpFiles()
        
        srcFileLength = length(pcmread(pcmInPath));
                
        switch fsSrc
            
            
            case 48e3
                
                pcmOutPath = pcmInPath;
                
            case 32e3
                
                [fs, fileLengthNew] = pcmUp3(pcmInPath, pcmTmpPath1, srcFileLength, fsSrc);
                fs = pcmDown2(pcmTmpPath1, pcmOutPath, fileLengthNew, fs);
                
            case 16e3
                
                [fs, fileLengthNew] = pcmUp3(pcmInPath, pcmOutPath, srcFileLength, fsSrc);
                
                
            case 8e3
                
                [fs, fileLengthNew] = pcmUp2(pcmInPath, pcmTmpPath1, srcFileLength, fsSrc);
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

