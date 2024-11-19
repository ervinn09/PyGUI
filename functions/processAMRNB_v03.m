function [deg, ref, errFlag, actualErrRate, fs, t, bModeOutput, options] = processAMRNB_v03(filePath, plcMode, options, ii)

fsCodec = 8e3; % AMR-NB uses 8 kHz sample rate
frameLength = 0.02*fsCodec; % AMR-NB uses 20ms frames
encodeDelay = 40;  % AMR-NB has 40 samples delay
decodeDelay = 0;
codecDelay = encodeDelay+decodeDelay;

bModeList = {'MR475', 'MR515', 'MR59', 'MR67', 'MR74', 'MR795', 'MR102', 'MR122'};
bModeListOutput = [4.75, 5.15, 5.90, 6.70, 7.40, 7.95, 10.20, 12.20];

if options.bMode == -1
    options.bMode = 8; % standard bitrate for amr-nb
end

dtxList = {'', '-dtx'};

%%
global tmp_state_var;
global tmp_src_speech;
global tmp_src16_speech;
global tmp_src16_sync_speech
global tmp_src8_speech;
global tmp_src8_sync_speech;
global tmp_src32_speech;
global tmp_src32_sync_speech
global tmp_src48_speech;
global tmp_src48_sync_speech
global tmp_src96_speech;
global tmp_src96_sync_speech
global tmp_bitstream;
global tmp_err_pttrn;
global tmp_err_bitstream;
global tmp_dec_speech;
global tmp_dec16_speech;
global tmp_dec32_speech;
global tmp_dec48_speech;
global tmp_dec96_speech;

tmpvar = evalin('base', 'tmpFolder');

tmp_state_var = [tmpvar 'tmp_state_var_' num2str(ii) '.tmp'];
tmp_src_speech = [tmpvar 'tmp_src_speech_' num2str(ii) '.tmp'];
tmp_src8_speech = [tmpvar 'tmp_src8_speech_' num2str(ii) '.tmp'];
tmp_src16_speech = [tmpvar 'tmp_src16_speech_' num2str(ii) '.tmp'];
tmp_src32_speech = [tmpvar 'tmp_src32_speech' num2str(ii) '.tmp'];
tmp_src48_speech = [tmpvar 'tmp_src48_speech' num2str(ii) '.tmp'];
tmp_src96_speech = [tmpvar 'tmp_src96_speech' num2str(ii) '.tmp'];
tmp_src8_sync_speech = [tmpvar 'tmp_src8_sync_speech_' num2str(ii) '.tmp'];
tmp_src16_sync_speech = [tmpvar 'tmp_src16_sync_speech_' num2str(ii) '.tmp'];
tmp_src32_sync_speech = [tmpvar 'tmp_src32_sync_speech' num2str(ii) '.tmp'];
tmp_src48_sync_speech = [tmpvar 'tmp_src48_sync_speech' num2str(ii) '.tmp'];
tmp_src96_sync_speech = [tmpvar 'tmp_src96_sync_speech' num2str(ii) '.tmp'];
tmp_bitstream = [tmpvar 'tmp_bitstream_' num2str(ii) '.tmp'];
tmp_err_pttrn = [tmpvar 'tmp_err_pttrn_' num2str(ii) '.tmp'];
tmp_err_bitstream = [tmpvar 'tmp_err_bitstream_' num2str(ii) '.tmp'];
tmp_dec_speech = [tmpvar 'tmp_dec_speech_' num2str(ii) '.tmp'];
tmp_dec16_speech = [tmpvar 'tmp_dec16_speech_' num2str(ii) '.tmp'];
tmp_dec32_speech = [tmpvar 'tmp_dec32_speech' num2str(ii) '.tmp'];
tmp_dec48_speech = [tmpvar 'tmp_dec48_speech_' num2str(ii) '.tmp'];
tmp_dec96_speech = [tmpvar 'tmp_dec96_speech' num2str(ii) '.tmp'];

deleteTempFiles()

%% read wav, resample to 8 kHz and convert to pcm

% read wav and write pcm
[ref, fsSrc, srcFileLength] = wav2pcm(filePath, tmp_src_speech);

% resample
if fsSrc == 48e3
    [fsNew, fileLengthNew] = pcmDown3_v02(tmp_src_speech, tmp_src16_speech, srcFileLength, fsSrc, ii);
    [fsNew, fileLengthNew] = pcmDown2_v02(tmp_src16_speech, tmp_src8_speech, fileLengthNew, fsNew, ii);
else
    error('input must be 48 kHz')
end

% add postamble to compensate codec delay
encodeSync_v02(tmp_src8_speech, tmp_src8_sync_speech, codecDelay, fileLengthNew, ii);

%% encoding speech and save to bitstream
cmdStr = ['amrnb_encoder ' dtxList{options.dtx+1} ' ' bModeList{options.bMode} ' ' tmp_src8_sync_speech ' ' tmp_bitstream];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end
if options.verbose
    disp(result)
end

%% get number of frames
fileID = fopen(tmp_bitstream);
encodedBitstream = fread(fileID,'int16=>int16');
fclose(fileID);

bitstreamFrameLength = 250;
N = length(encodedBitstream);
nFrames = N/bitstreamFrameLength;

%% generate error pattern
errorPat = genErrPttrn_v03(plcMode, options, nFrames, frameLength, 0, fsCodec, tmp_err_pttrn, tmp_state_var);

%% insert errors
cmdStr = ['eid-amr ' tmp_bitstream ' ' tmp_err_pttrn ' ' tmp_err_bitstream];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end
if options.verbose
    disp(result)
end

%% decode bitstream including errors
cmdStr = ['amrnb_decoder ' tmp_err_bitstream ' ' tmp_dec_speech];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end
if options.verbose
    disp(result)
end

%% upsample
[fsNew, fileLengthNew] = pcmUp2_v02(tmp_dec_speech, tmp_dec16_speech, fileLengthNew, fsNew, ii);
fsNew = pcmUp3_v02(tmp_dec16_speech, tmp_dec48_speech, fileLengthNew, fsNew, ii);

%% read degraded file
deg = pcmread(tmp_dec48_speech);

%% Output
fs = fsNew;

errFlag = kron(errorPat', ones(1,frameLength*fs/fsCodec));

% errFlag delay
errFlagDelay = decodeDelay*fs/fsCodec; 

% equalize delay in errFlag audio
errFlag = [ones(1,errFlagDelay) errFlag(1:end-errFlagDelay) ];
errFlag = ~errFlag;

errFlag1 = errFlag;
errFlag = zeros(size(deg));
errFlag(1:length(errFlag1)) = errFlag1;
errFlag = errFlag(1:length(deg));

t = 0:1/fs:length(deg)/fs-1/fs;
actualErrRate = sum(errFlag)/length(errFlag);
bModeOutput = bModeListOutput(options.bMode);

options.plMode = plcMode;
deleteTempFiles()

end


function deleteTempFiles()
warning off
global tmp_state_var
global tmp_src_speech;
global tmp_src8_speech;
global tmp_src16_speech;
global tmp_src32_speech;
global tmp_src48_speech;
global tmp_src96_speech;
global tmp_src8_sync_speech;
global tmp_src16_sync_speech;
global tmp_src32_sync_speech;
global tmp_src48_sync_speech;
global tmp_src96_sync_speech;
global tmp_bitstream;
global tmp_err_pttrn;
global tmp_err_bitstream;
global tmp_dec_speech;
global tmp_dec16_speech;
global tmp_dec32_speech;
global tmp_dec48_speech;
global tmp_dec96_speech;
fclose all;


while exist(tmp_state_var, 'file')==2
    delete(tmp_state_var)
end

while exist(tmp_src_speech, 'file')==2
    delete(tmp_src_speech)
end


while exist(tmp_src8_speech, 'file')==2
    delete(tmp_src8_speech)
end

while exist(tmp_src16_speech, 'file')==2
    delete(tmp_src16_speech)
end


while exist(tmp_src32_speech, 'file')==2
    delete(tmp_src32_speech)
end


while exist(tmp_src48_speech, 'file')==2
    delete(tmp_src48_speech)
end


while exist(tmp_src96_speech, 'file')==2
    delete(tmp_src96_speech)
end


while exist(tmp_src8_sync_speech, 'file')==2
    delete(tmp_src8_sync_speech)
end

while exist(tmp_src16_sync_speech, 'file')==2
    delete(tmp_src16_sync_speech)
end

while exist(tmp_src32_sync_speech, 'file')==2
    delete(tmp_src32_sync_speech)
end


while exist(tmp_src48_sync_speech, 'file')==2
    delete(tmp_src48_sync_speech)
end


while exist(tmp_src96_sync_speech, 'file')==2
    delete(tmp_src96_sync_speech)
end


while exist(tmp_bitstream, 'file')==2
    delete(tmp_bitstream)
end

while exist(tmp_err_pttrn, 'file')==2
    delete(tmp_err_pttrn)
end

while exist(tmp_err_bitstream, 'file')==2
    delete(tmp_err_bitstream)
end

while exist(tmp_dec_speech, 'file')==2
    delete(tmp_dec_speech)
end

while exist(tmp_dec16_speech, 'file')==2
    delete(tmp_dec16_speech)
end

while exist(tmp_dec32_speech, 'file')==2
    delete(tmp_dec32_speech)
end


while exist(tmp_dec48_speech, 'file')==2
    delete(tmp_dec48_speech)
end

while exist(tmp_dec96_speech, 'file')==2
    delete(tmp_dec96_speech)
end

% warning on
end