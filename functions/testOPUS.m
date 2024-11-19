clear

%% encoding speech and save to bitstream
filePath = 'C:\Users\Gabriel\Dropbox\UFESQ\Matlab_Estimator\_Matlab_Git\PLC\runPLC\in.wav';
cmdStr = ['opusenc --expect-loss 50 ' filePath ' tmp_bitstream.opus'];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end


%% get number of packets

bsPath = 'tmp_bitstream.opus';
fileID = fopen(bsPath);
encodedBitstream = fread(fileID,'uint8=>uint8');
fclose(fileID);

preSkip = bin2dec([dec2bin(encodedBitstream(40),8) dec2bin(encodedBitstream(39),8)]);
header = encodedBitstream(1:4);

clear A nLacedPakets

idx = strfind(encodedBitstream', header');
for i = 1:length(idx)
    
    tmp = encodedBitstream(idx(i):end);
    A(1:length(tmp),i) = tmp;
    
end

nSegments = A(27,:);
for i = 1:length(nSegments)
    
    nLacedPakets(i) = sum( A(28:28+nSegments(i)-1,i) == 255);
    
end
nPackets = sum(nSegments(3:end)) - sum(nLacedPakets(3:end));



%% gen err pattern
% errorRate = [];
% codecDelay = preSkip;
fs = 48e3;
frameLength = 0.02*fs;
% tLossLocation = [1 1.5 2 3 4 5];
% nLostFrames = [1 2 3 4 5 6];
% errorPat = genErrPttrn('location', nPackets, errorRate, tLossLocation, nLostFrames, frameLength, codecDelay, fs);
% errFlag = kron(errorPat',ones(1,frameLength));

% generate error pattern
errorPat = int16(27425.*ones(nPackets,1));
errorPat(2) = errorPat(2) - 1;

% save error pattern
fileID = fopen('tmp_err_pttrn.g192','w');
if (fileID < 0)
    error('output error pattern cannot be created')
end
fwrite(fileID, errorPat, 'int16');
fclose(fileID);
errorPat = double(errorPat) - 27424;
errFlag = kron(errorPat',ones(1,frameLength));

%% decode bitstream including errors
cmdStr = ['opusdec --npackets ' num2str(nPackets) ' tmp_bitstream.opus tmp_dec_speech.wav'];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end


%% Plot

deg = audioread('tmp_dec_speech.wav');
ref = audioread(filePath);

t = (0:length(ref)-1)/48e3;

figure(1)
clf
hold on
plot(t,ref)
plot(t,deg)
plot(t,errFlag(preSkip:length(deg)+preSkip-1))

sound(deg, fs)
