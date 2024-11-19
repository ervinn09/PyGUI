clear

filePath = 'C:\Users\Gabriel\Dropbox\UFESQ\Jens_Beispiel_Sprachfiles\2017_06_PTCA_example_files\EN_fm_wide_ref.wav';
pcmName = 'test.pcm';
pcmOutName = 'test2.pcm';

% read wav and save as pcm
[ref, fs] = wav2pcm(filePath, pcmName);
fileLength = length(ref);

% downsample
[fs, fileLength] = pcmDown3(pcmName, 'tmp3.pcm', fileLength, fs);
fs = pcmDown2('tmp3.pcm', pcmOutName, fileLength, fs);

% read pcm
deg = pcmread(pcmOutName);
refS = resample(ref, 8e3, 48e3);

figure(1)
clf
plot(refS)
hold on
plot(deg)