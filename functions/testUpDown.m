%
%                            E V S    -    B I T R A T E     M O D E S
% mode:       1       2       3       4       5        6        7        8        9        10       11       12
% rList = {'5900', '7200', '8000', '9600', '13200', '16400', '24400', '32000', '48000', '64000', '96000', '128000' };

clear
% filePath = 'D:\Soundfiles\NCS_semi_spontaneous\ref\m016_beirut_d7.wav';
filePath = 'C:\Users\Gabriel\Dropbox\UFESQ\Jens_Beispiel_Sprachfiles\2017_06_PTCA_example_files\EN_fm_wide_ref.wav';
% filePath = 'C:\Users\Gabriel\tubCloud\Soundfiles\P501\AnnexC_WB\P501_C_english_m1_WB_16k.wav';

% read wav and save as pcm
[ref, fs] = wav2pcm(filePath, 'test.pcm');

% downsample
pcmDownsample48to16('test.pcm', length(ref)/3)

% read pcm
deg = pcmread('test.16k.pcm');

refS = resample(ref, 16e3, 48e3);


figure(1)
clf
plot(refS)
hold on
plot(deg)
