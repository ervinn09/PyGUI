function [deg, ref, errFlag, actualErrRate, fs, t, bModeOutput, options] = processEVS_v03(filePath, plcMode, options, ii)

fsCodec = 32e3; % EVS uses 48 kHz sample rate
frameLength = 0.02*fsCodec; % 
encodeDelay = 0;  % EVS has 0 samples delay
decodeDelay = 0;  % EVS has 0 samples delay
codecDelay = encodeDelay+decodeDelay;

bModeList = {'5900', '7200', '8000', '9600', '13200', '16400', '24400', '32000', '48000', '64000', '96000', '128000'};
bModeListOutput = [5.9, 7.2, 8.0, 9.6, 13.2, 16.4, 24.4, 32.0, 48.0, 64.0, 96.0, 128.0];

if options.bMode == -1
    options.bMode = 5; % "standard" bitrate for evs-swb
end
if options.bMode < 1 || options.bMode > 12
    error('mode must be between 1 and 12')
end

dtxList = {'', '-dtx'};
if options.CA; channelAware = '-rf'; else; channelAware = ''; end

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

%% read wav, resample to 32 kHz and convert to pcm

if strcmp(options.maxBand, 'FB')
    % read wav and write pcm
    [ref, fsNew, fileLengthNew] = wav2pcm(filePath, tmp_src32_speech);
    fs = '48';
elseif strcmp(options.maxBand, 'SWB')
    % read wav and write pcm
    [ref, fsSrc, srcFileLength] = wav2pcm(filePath, tmp_src_speech);
    fs = '32';
    % resample
    if fsSrc == 48e3
        [fsNew, fileLengthNew] = pcmUp2_v02(tmp_src_speech, tmp_src96_speech, srcFileLength, fsSrc, ii);
        [fsNew, fileLengthNew] = pcmDown3_v02(tmp_src96_speech, tmp_src32_speech, fileLengthNew, fsNew, ii);
    else
        error('input must be 48 kHz')
    end
else 
    error('maxBand not supported')
end

%% encoding speech and save to bitstream
cmdStr = ['EVS_cod ' dtxList{options.dtx+1} ' ' channelAware ' -max_Band ' options.maxBand ' ' bModeList{options.bMode} ' ' fs ' ' tmp_src32_speech ' ' tmp_bitstream];
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

nFrames = sum( encodedBitstream == 27425 ); % 27425 = header in itu format

%% generate error pattern
codecDelay = 0;
errorPat = genErrPttrn_v03(plcMode, options, nFrames, frameLength, codecDelay, fsCodec, tmp_err_pttrn, tmp_state_var);

%% insert errors
cmdStr = ['eid-xor -vbr -ep g192 ' tmp_bitstream ' ' tmp_err_pttrn ' ' tmp_err_bitstream];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end
if options.verbose
    disp(result)
end

%% decode bitstream including errors
cmdStr = ['EVS_dec ' fs ' ' tmp_err_bitstream ' ' tmp_dec_speech];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end
if options.verbose
    disp(result)
end

%% upsample
if strcmp(options.maxBand, 'FB')
    tmp_dec48_speech = tmp_dec_speech;
elseif strcmp(options.maxBand, 'SWB')
    [fsNew, fileLengthNew] = pcmUp3_v02(tmp_dec_speech, tmp_dec96_speech, fileLengthNew, fsNew, ii);
    fsNew = pcmDown2_v02(tmp_dec96_speech, tmp_dec48_speech, fileLengthNew, fsNew, ii);
else 
    error('maxBand not supported')
end

%% read degraded file
deg = pcmread(tmp_dec48_speech);

%% Output
fs = fsNew;

errFlag = kron(errorPat', ones(1,frameLength*fs/fsCodec));

% errFlag delay
errFlagDelay = decodeDelay*fs/fsCodec; 

% equalize delay in errFlag audio
errFlag = [ones(1,errFlagDelay) errFlag(1:end-errFlagDelay) ones(1,length(deg))];

errFlag = errFlag(1:length(deg));

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