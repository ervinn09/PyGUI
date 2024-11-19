
srcFolder = 'D:\Soundfiles\PSAMD_VAL\NSC\asl_in\';
dstFolder = 'D:\Soundfiles\PSAMD_VAL\NSC\asl_out\';

fileList = dir( [srcFolder '*.wav'] );

%%
db = -26-25;

parfor ii = 1:size(fileList,1)

    inPath = [srcFolder, fileList(ii).name];
    outPath = [dstFolder, fileList(ii).name];
    
    asl26_v02(inPath, outPath, db, ii);

end