function [deg, ref, errFlag, actualErrRate, fs, t, bModeOutput, options] = processOPUS_v03(inputFilePath, plcMode, options, ii)

fsOPUS = 48e3; % 

if options.bMode == -1
    options.bMode = 25.0; % "standard" bitrate for opus
end
frameLength = 0.02*fsOPUS; % opus default is 20ms (can be changed in the options)

info = audioinfo(inputFilePath);
if info.SampleRate ~= fsOPUS
   error('Input should be 48kHz') 
end

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
tmp_dec_speech = [tmpvar 'tmp_dec_speech_' num2str(ii) '.wav'];
tmp_dec16_speech = [tmpvar 'tmp_dec16_speech_' num2str(ii) '.tmp'];
tmp_dec32_speech = [tmpvar 'tmp_dec32_speech' num2str(ii) '.tmp'];
tmp_dec48_speech = [tmpvar 'tmp_dec48_speech_' num2str(ii) '.tmp'];
tmp_dec96_speech = [tmpvar 'tmp_dec96_speech' num2str(ii) '.tmp'];

deleteTempFiles()

%% encoding speech and save to bitstream
cmdStr = ['opusenc --bitrate ' num2str(options.bMode) ' ' char(inputFilePath) ' ' tmp_bitstream];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end
if options.verbose
    disp(result)
end

%% get number of frames / preskip
fileID = fopen(tmp_bitstream);
encodedBitstream = fread(fileID,'int8=>int8');
fclose(fileID);

% preskip is a int16 -> convert from two int8 entries 
preSkip = bin2dec([dec2bin(encodedBitstream(40),8) dec2bin(encodedBitstream(39),8)]);
header = encodedBitstream(1:4); % ogg page header

% find start of pages
idx = strfind(encodedBitstream', header');
nPages = length(idx);
for i = 1:nPages
    tmp = encodedBitstream(idx(i):end);
    A(1:length(tmp),i) = tmp;
end

% find number of segments in stream
nSegments = A(27,:); 

% find number of laced packets (a packet that is divided in several
% segments)
nLacedPackets = nan(nPages,1);
for i = 1:nPages
    nLacedPackets(i) = sum( A(28:28+nSegments(i)-1,i) == 255);
end

% calculated packets by subtracting laced packets from the number of
% segments, not considering the first two pages, which are used by Opus for
% header information
nFrames = sum(nSegments(3:end)) - sum(nLacedPackets(3:end));

%% generate error pattern
errorPat = genErrPttrn_v03(plcMode, options, nFrames, frameLength, preSkip, fsOPUS, tmp_err_pttrn, tmp_state_var);


%% decode bitstream including errors
cmdStr = ['eid-opusdec --pattern ' tmp_err_pttrn ' --npackets ' num2str(nFrames) ' ' tmp_bitstream ' ' tmp_dec_speech];

[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end
if options.verbose
    disp(result)
end

%% Output
[deg, fs] = audioread(tmp_dec_speech);
ref = audioread(inputFilePath);

errFlag = kron(errorPat',ones(1,frameLength));
errFlag = errFlag(preSkip+1:length(deg)+preSkip);
errFlag = ~errFlag;

errFlag1 = errFlag;
errFlag = zeros(size(deg));
errFlag(1:length(errFlag1)) = errFlag1;
errFlag = errFlag(1:length(deg));

t = 0:1/fs:length(deg)/fs-1/fs;
actualErrRate = sum(~errFlag)/length(errFlag);
bModeOutput = options.bMode;

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