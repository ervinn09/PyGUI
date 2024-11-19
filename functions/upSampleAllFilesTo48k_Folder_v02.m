inDir = 'D:\Soundfiles\POLQA_DBs\_UNSORTED\benchmark_TRAINING_PCM\NB_BT_P862_PROP\degraded';
outDir =  'D:\Soundfiles\NISQA\NB_48kHz_BT_P862_PROP\deg\';

fs = 48e3;
fileEnding = '.wav';

%%
D = dir( [inDir '\*' fileEnding]);
% D(1:2) = [];
% D(end) = [];

N = size(D,1);
parfor ii = 1:N
    
    fileName = D(ii).name;
    folderName = D(ii).folder;
    
    inPath = [folderName '\' fileName];
    outPath = [outDir '\' fileName(1:end-4) '.wav'];
%     outPath = [outDir '\' fileName '.wav'];

    upsampleTo48k(inPath, outPath, ii, fs)
        
%     printProgress(ii,N)
end




