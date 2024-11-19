clear
load('C:\Users\Gabriel\Documents\RCA_DBs\OPTICOM\rcaOpticom.mat')
dirPath = 'C:\Users\Gabriel\Documents\RCA_DBs\OPTICOM\ref\';
saveDir = 'C:\Users\Gabriel\Documents\RCA_DBs\OPTICOM\refswb\';

for i = 1:length(rcaOpticom)

i
filePath = [dirPath rcaOpticom(i).filename];
savePath = [saveDir rcaOpticom(i).filename];

% read wav and save as pcm
[ref, fsSrc, srcFileLength] = wav2pcm(filePath, 'tmp_src_speech.pcm');

% downsample
[fsNew, fileLengthNew] = pcmUp2('tmp_src_speech.pcm', 'tmp_src96_speech.pcm', srcFileLength, fsSrc);
[fsNew, fileLengthNew] = pcmDown3('tmp_src96_speech.pcm', 'tmp_src32_speech.pcm', fileLengthNew, fsNew);

% filter
filterLength = fsNew*0.02;
[status, result] = system(['filter 14KBP tmp_src32_speech.pcm tmp_src32_speech_filtered.pcm ' num2str(filterLength)]);
if status ~= 0
    disp(result)
    error('Something went wrong');
end

x = pcmread('tmp_src32_speech_filtered.pcm');
tmp_src32_speech_filtered = length(x);

[fsNew, fileLengthNew] = pcmUp3('tmp_src32_speech_filtered.pcm', 'tmp_dec96_speech.pcm', fileLengthNew, fsNew);
fsNew = pcmDown2('tmp_dec96_speech.pcm', 'tmp_dec48_speech.pcm', fileLengthNew, fsNew);


% read pcm
deg = pcmread('tmp_dec48_speech.pcm');
audiowrite(savePath, deg, fsNew)

end