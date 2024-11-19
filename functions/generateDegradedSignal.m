function tFile = generateDegradedSignal(filename, srcFolder, degPath, t, optionsDist, tmpFolder, ii)

global tmpPath;
global tmpPath2;
global tmpPath3;
global tmpPath4;
global tmpPath5;
global tmpPath6;
global tmpPath7;

global tmpAddPath1;
global tmpAddPath2;
global tmpAddPath3;
global tmpAddPath4;
global tmpAddPath5;
global tmpAddPath6;
global tmpAddPath7;
global tmpAddPath8;
global tmpAddPath9;
global tmpAddPath10;

tmpPath  = [tmpFolder '/tmp_ds_1_' num2str(ii) '.wav'];
tmpPath2 = [tmpFolder '/tmp_ds_2_' num2str(ii) '.wav'];
tmpPath3 = [tmpFolder '/tmp_ds_3_' num2str(ii) '.wav'];
tmpPath4 = [tmpFolder '/tmp_ds_4_' num2str(ii) '.wav'];
tmpPath5 = [tmpFolder '/tmp_ds_5_' num2str(ii) '.wav'];
tmpPath6 = [tmpFolder '/tmp_ds_6_' num2str(ii) '.wav'];
tmpPath7 = [tmpFolder '/tmp_ds_7_' num2str(ii) '.wav'];

tmpAddPath1  = [tmpFolder '/tmp_add_ds_1_' num2str(ii) '.wav'];
tmpAddPath2 = [tmpFolder '/tmp_add_ds_2_' num2str(ii) '.wav'];
tmpAddPath3 = [tmpFolder '/tmp_add_ds_3_' num2str(ii) '.wav'];
tmpAddPath4 = [tmpFolder '/tmp_add_ds_4_' num2str(ii) '.wav'];
tmpAddPath5 = [tmpFolder '/tmp_add_ds_5_' num2str(ii) '.wav'];
tmpAddPath6 = [tmpFolder '/tmp_add_ds_6_' num2str(ii) '.wav'];
tmpAddPath7 = [tmpFolder '/tmp_add_ds_7_' num2str(ii) '.wav'];
tmpAddPath8 = [tmpFolder '/tmp_add_ds_8_' num2str(ii) '.wav'];
tmpAddPath9 = [tmpFolder '/tmp_add_ds_9_' num2str(ii) '.wav'];
tmpAddPath10 = [tmpFolder '/tmp_add_ds_10_' num2str(ii) '.wav'];

tmpAddPaths = struct;
tmpAddPaths(1).path = tmpAddPath1;
tmpAddPaths(2).path = tmpAddPath2;
tmpAddPaths(3).path = tmpAddPath3;
tmpAddPaths(4).path = tmpAddPath4;
tmpAddPaths(5).path = tmpAddPath5;
tmpAddPaths(6).path = tmpAddPath6;
tmpAddPaths(7).path = tmpAddPath7;
tmpAddPaths(8).path = tmpAddPath8;
tmpAddPaths(9).path = tmpAddPath9;
tmpAddPaths(10).path = tmpAddPath10;

%% delete tmp files
deleteTempFiles()

%% set paths
inPath = fullfile(srcFolder, filename);

degName = ['c' sprintf('%05.0f', t.con) '_' filename];
matName = ['c' sprintf('%05.0f', t.con) '_' filename(1:end-4) '.mat'];
errName = ['c' sprintf('%05.0f', t.con) '_' filename(1:end-4) '.csv'];

outPath = fullfile(degPath, degName);
matPath = fullfile(degPath, 'mat', matName); % uncomment below to activate 
errPath = fullfile(degPath, 'pl', errName);  %  uncomment below to activate 

%%
[deg, fs] = audioread(inPath);

if fs~=48000
    deg = resample(deg,48e3,fs);
    fs = 48e3;
end
audiowrite(tmpPath, deg, fs);



%% set source file level to -26dB ASL
if t.asl_in=='x'
    asl26_v02(tmpPath, tmpPath2, t.asl_in_level, ii);
elseif t.asl_in=='no'
    [deg, fs] = audioread(inPath);
    audiowrite(tmpPath2, deg, fs);
else
    asl26_v02(tmpPath, tmpPath2, -26, ii);
end

%% add simulated distortions

dtype = cell(1);
dtype{1} = 'clean';

i = 1;
if t.filter=='bandpass'
    dtype{i} = 'bandpass';
    i=i+1;
end
if t.filter=='lowpass'
    dtype{i} = 'lowpass';
    i=i+1;
end
if t.filter=='highpass'
    dtype{i} = 'highpass';
    i=i+1;
end
if t.timeclipping=='x'
    dtype{i} = 'timeclipping';
    i=i+1;
end
if t.wbgn=='x'
    dtype{i} = 'wbgn';
    i=i+1;
end
if t.p50mnru=='x'
    dtype{i}= 'p50mnru';
    i=i+1;
end
if t.bgn=='random_bgn'
    dtype{i} = 'random_bgn';
    i=i+1;
end
if t.bgn=='x'
    dtype{i} = 'random_bgn';
    i=i+1;
end
if t.bgn=='bgn_file'
    dtype{i} = 'bgn_file';
    i=i+1;
end
if t.clipping=='x'
    dtype{i} = 'clipping';
    i=i+1;
end
if t.arb_filter=='x'
    dtype{i} = 'arb_filter';
    i=i+1;
end

optionsDist.fpass = [t.bp_low t.bp_high];
optionsDist.tc_nburst = t.tc_nburst;
optionsDist.tc_fer = t.tc_fer;
optionsDist.wbgn_snr = t.wbgn_snr;
optionsDist.p50_q = t.p50_q;
optionsDist.bgn_snr = t.bgn_snr;
if any(strcmp('bgn_file', t.Properties.VariableNames))
    optionsDist.bgn_file = t.bgn_file;
end
optionsDist.cl_th = t.cl_th;

dtype = dtype(randperm(numel(dtype)));

if ~(t.dist_post_codec=='x')
    tmpAddPaths(1).path = tmpPath2;
    for i = 1:numel(dtype)
        optionsDist.type = dtype{i};
        addDegradation(tmpAddPaths(i).path, tmpAddPaths(i+1).path, fs, optionsDist, ii);
    end
    tmpPath2 = tmpAddPaths(i+1).path;
end

%% apply codec and losses 1
plcMode = char(t.plcMode1);
codec = char(t.codec1);
optionsCodec.bMode = t.bMode1;
optionsCodec.errorRate = t.FER1;
% optionsCodec.burstR = t.burstR1;

[deg, ~, errFlag, actualErrRate, ~, fs, bitrate, optionsOutput] = runCoding(tmpPath2, codec, plcMode, optionsCodec, ii);
audiowrite(tmpPath4, deg, fs);

%% apply codec and losses 2
plcMode = char(t.plcMode2);
codec = char(t.codec2);
optionsCodec.bMode = t.bMode2;
optionsCodec.errorRate = t.FER2;

[deg, ~, errFlag2, actualErrRate2, ~, fs, bitrate2, optionsOutput2] = runCoding(tmpPath4, codec, plcMode, optionsCodec, ii);
audiowrite(tmpPath5, deg, fs);

%% apply codec and losses 3
plcMode = char(t.plcMode3);
codec = char(t.codec3);
optionsCodec.bMode = t.bMode3;
optionsCodec.errorRate = t.FER3;

[deg, ~, errFlag3, actualErrRate3, ~, fs, bitrate3, optionsOutput3] = runCoding(tmpPath5, codec, plcMode, optionsCodec, ii);
audiowrite(tmpPath6, deg, fs);

%%
if (t.dist_post_codec=='x')
    tmpAddPaths(1).path = tmpPath6;
    for i = 1:numel(dtype)
        optionsDist.type = dtype{i};
        addDegradation(tmpAddPaths(i).path, tmpAddPaths(i+1).path, fs, optionsDist, ii);
    end
    tmpPath6 = tmpAddPaths(i+1).path;
end

%% set degraded active speech level and save file

if t.asl_out=='x'
    asl26_v02(tmpPath6, outPath, t.asl_out_level, ii);
else
    [deg, fs] = audioread(tmpPath6);
    audiowrite(outPath, deg, fs);
end

% save additional infos
% save(matPath, 'optionsDist', 'errFlag', 'actualErrRate', 'bitrate', 'optionsOutput', ...
%     'errFlag2', 'actualErrRate2', 'bitrate2', 'optionsOutput2', ...
%     'errFlag3', 'actualErrRate3', 'bitrate3', 'optionsOutput3')
% 
% writematrix(errFlag+errFlag2+errFlag3, errPath)

%%
tFile = t;

tFile.file_ref = {filename};
tFile.file_deg = {degName};
tFile.dir_ref = {srcFolder};
tFile.dir_deg = {degPath};


deleteTempFiles()

end


function deleteTempFiles()
warning off
global tmpPath;
global tmpPath2;
global tmpPath3;
global tmpPath4;
global tmpPath5;
global tmpPath6;
global tmpPath7;

global tmpAddPath1;
global tmpAddPath2;
global tmpAddPath3;
global tmpAddPath4;
global tmpAddPath5;
global tmpAddPath6;
global tmpAddPath7;
global tmpAddPath8;
global tmpAddPath9;
global tmpAddPath10;


fclose all;

while exist(tmpPath, 'file')==2
    delete(tmpPath)
end

while exist(tmpPath2, 'file')==2
    delete(tmpPath2)
end

while exist(tmpPath3, 'file')==2
    delete(tmpPath3)
end

while exist(tmpPath4, 'file')==2
    delete(tmpPath4)
end

while exist(tmpPath5, 'file')==2
    delete(tmpPath5)
end

while exist(tmpPath6, 'file')==2
    delete(tmpPath6)
end

while exist(tmpPath7, 'file')==2
    delete(tmpPath7)
end

while exist(tmpAddPath1, 'file')==2
    delete(tmpAddPath1)
end

while exist(tmpAddPath2, 'file')==2
    delete(tmpAddPath2)
end

while exist(tmpAddPath3, 'file')==2
    delete(tmpAddPath3)
end

while exist(tmpAddPath4, 'file')==2
    delete(tmpAddPath4)
end

while exist(tmpAddPath5, 'file')==2
    delete(tmpAddPath5)
end

while exist(tmpAddPath6, 'file')==2
    delete(tmpAddPath6)
end

while exist(tmpAddPath7, 'file')==2
    delete(tmpAddPath7)
end

while exist(tmpAddPath8, 'file')==2
    delete(tmpAddPath8)
end

while exist(tmpAddPath9, 'file')==2
    delete(tmpAddPath9)
end

while exist(tmpAddPath10, 'file')==2
    delete(tmpAddPath10)
end

% warning on
end