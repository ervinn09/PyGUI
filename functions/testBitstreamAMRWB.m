filePath = 'C:\Users\Gabriel\Dropbox\UFESQ\Jens_Beispiel_Sprachfiles\2017_06_PTCA_example_files\EN_fm_wide_ref.wav';

%% read wav, resample to 16 kHz and convert to pcm
fsAMRWB = 16e3;
[rawAudio, fsSrc] = audioread(filePath,'native');
rawAudio = double(rawAudio);
if fsAMRWB ~= fsSrc
    rawAudio = resample(rawAudio, fsAMRWB, fsSrc);
end
rawAudio = int16(rawAudio);

% save resampled audio file
fileID = fopen('tmp_src_speech.pcm','w');
if (fileID < 0)
    error('output pcm file cannot be created')
end
fwrite(fileID,rawAudio,'int16');
fclose(fileID);

%%
cmdStr = ['amrwb_coder -mime 2 tmp_src_speech.pcm tmp_bitstream.g192'];
[status, result] = system(cmdStr);
if status ~= 0
    disp(result)
    error('Something went wrong');
end

%% get number of frames
filePath = 'tmp_bitstream.g192';
fileID = fopen(filePath);
encodedBitstream = fread(fileID,'int8=>int8');
fclose(fileID);

encodedBitstreamChar = char(encodedBitstream)';
% nFrames = sum( encodedBitstream == 27425 ); % 27425 = header in itu format