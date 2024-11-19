filePath = 'C:\Users\Gabriel\Dropbox\UFESQ\Jens_Beispiel_Sprachfiles\2017_06_PTCA_example_files\EN_fm_wide_ref.wav';

%% read wav, resample to 16 kHz and convert to pcm
fsg722 = 16e3;
[rawAudio, fsSrc] = audioread(filePath,'native');
rawAudio = double(rawAudio);
if fsg722 ~= fsSrc
    rawAudio = resample(rawAudio, fsg722, fsSrc);
end
rawAudio = int16(rawAudio);

% save resampled audio file
fileID = fopen('tmp_src_speech.pcm','w');
if (fileID < 0)
    error('output pcm file cannot be created')
end
fwrite(fileID,rawAudio,'int16');
fclose(fileID);

%% encode

cmdStr = ['encg722 -fsize 320 -mode 3 tmp_src_speech.pcm tmp_bitstream.g192'];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end

%% decode

cmdStr = ['decg722 tmp_bitstream.g192 tmp_dec_speech.pcm'];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end


%% read degraded file
filePath = 'tmp_dec_speech.pcm';
fileID = fopen(filePath);
rawDeg = fread(fileID,'int16');
fclose(fileID);

% normalized output
deg = rawDeg ./ (2^16/2);