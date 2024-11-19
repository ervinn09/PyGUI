%
%                            E V S    -    B I T R A T E     M O D E S
% mode:       1       2       3       4       5        6        7        8        9        10       11       12
% rList = {'5900', '7200', '8000', '9600', '13200', '16400', '24400', '32000', '48000', '64000', '96000', '128000' };

clear
% filePath = 'D:\Soundfiles\NCS_semi_spontaneous\ref\m016_beirut_d7.wav';
% filePath = 'C:\Users\Gabriel\Dropbox\UFESQ\Jens_Beispiel_Sprachfiles\2017_06_PTCA_example_files\EN_fm_wide_ref.wav';
filePath = 'C:\Users\Gabriel\tubCloud\Soundfiles\P501\AnnexC_WB\P501_C_english_m1_WB_16k.wav';

% read wav and save as pcm
[ref, fs] = wav2pcm(filePath, 'test.pcm');

% % fill
% [status, results] = system('concat -f test.pcm preamble.g719dec test2.pcm');
% 
% % filter
% [status, results] = system('filter -up SHQ3 test2.pcm test3.pcm 320');
% fDelay = 436;

pcmDownsample48to16('test.pcm', length(ref))

% read pcm
deg = pcmread('test3.pcm');

% % compensate for delay 
% deg = deg(fDelay+1:length(refS)+fDelay);

refS = resample(ref, 48e3, 16e3);


figure(1)
clf
plot(refS)
hold on
plot(deg)
