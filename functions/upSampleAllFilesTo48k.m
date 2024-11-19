load('D:\Soundfiles\POLQA_DBs\SWB\SWB_TUBLIK\tublik_table.mat')


for i = 1:size(tFile,1)
    wavInPath = getDegPath(tFile,i);
    
    wavOutPath = ['D:\Soundfiles\POLQA_DBs\SWB\SWB_TUBLIK\deg48\' tFile.file_deg{i}];
    
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
            
            [fs, fileLengthNew] = pcmUp3(pcmInPath, pcmTmpPath1, srcFileLength, fs);
            
            
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

function deleteTmpFiles()
global pcmInPath pcmTmpPath1 pcmOutPath

while exist([path pcmInPath], 'file')==2
    delete(pcmInPath)
end
while exist([path pcmTmpPath1], 'file')==2
    delete(pcmTmpPath1)
end
while exist([path pcmOutPath], 'file')==2
    delete(pcmOutPath)
end

end

