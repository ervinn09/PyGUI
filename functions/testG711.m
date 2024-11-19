filePath = 'C:\Users\Gabriel\Dropbox\UFESQ\Jens_Beispiel_Sprachfiles\2017_06_PTCA_example_files\EN_fm_wide_ref.wav';

%% read wav, resample to 8 kHz and convert to pcm

% read wav and write pcm
[ref, fsSrc, srcFileLength] = wav2pcm(filePath, 'tmp_src_speech.pcm');

% resample
if fsSrc == 48e3
    [fsNew, fileLengthNew] = pcmDown3('tmp_src_speech.pcm', 'tmp_src16_speech.pcm', srcFileLength, fsSrc);
    [fsNew, fileLengthNew] = pcmDown2('tmp_src16_speech.pcm', 'tmp_src8_speech.pcm', fileLengthNew, fsNew);
else
    error('input must be 48 kHz')
end


% generate error pattern
errorPat = genErrPttrn('random', 600, 0.03, [], [], 0.01*8e3, 0, 8e3);

%% encode decode
[status, results] = system('g711iplc -noplc -stats tmp_err_pttrn.g192 tmp_src8_speech.pcm tmp_dec_speech.pcm');
disp(results)

%% upsample
[fsNew, fileLengthNew] = pcmUp2('tmp_dec_speech.pcm', 'tmp_dec16_speech.pcm', fileLengthNew, fsNew);
fsNew = pcmUp3('tmp_dec16_speech.pcm', 'tmp_dec48_speech.pcm', fileLengthNew, fsNew);

%% read degraded file
deg = pcmread('tmp_dec48_speech.pcm');
errFlag = kron(errorPat', ones(1,0.01*8e3*48/8));
errFlagDelay = 5*48/8; 
% errFlag = [ errFlag(errFlagDelay+1:end) ones(1,errFlagDelay) ];
errFlag = ~errFlag;

%%
figure(1)
clf
plot(ref)
hold on
plot(deg)
plot(errFlag)
