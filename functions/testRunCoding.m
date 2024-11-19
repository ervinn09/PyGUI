%
%                            E V S    -    B I T R A T E     M O D E S
% mode:       1       2       3       4       5        6        7        8        9        10       11       12
% rList = {'5900', '7200', '8000', '9600', '13200', '16400', '24400', '32000', '48000', '64000', '96000', '128000' };

clear
% filePath = 'D:\Soundfiles\NCS_semi_spontaneous\ref\m016_beirut_d7.wav';
% filePath = 'C:\Users\Gabriel\Dropbox\UFESQ\Jens_Beispiel_Sprachfiles\2017_06_PTCA_example_files\EN_fm_wide_ref.wav';
filePath = "D:\Soundfiles\P501\AnnexC\P501_C_german_f1_FB_48k.wav";

% plcMode = 'location';
% options.tLossLocation = [2 3 5];
% options.nLostFrames = [10 4 6];

% plcMode = 'random';
% options.errorRate = 0.25;

plcMode = 'noloss';
% options.errorRate = 0.1;
% options.burstR = 2;


options.bMode = 12;
% options.dtx = 1;
options.verbose = 1;
options.useConceal = 0;
options.maxBand = 'FB';

% info = audioinfo(filePath);
% plcMode = 'noloss';
% options.errorRate = [];
% options.tLossLocation = 0.5:0.6:info.Duration-0.5;
% nFrames = repmat(1:6,1,round(length(options.tLossLocation)/5));
% options.nLostFrames = nFrames(1:length(options.tLossLocation));

DO_PLOT = true;
ii=1;
[deg, ref, errFlag, actualErrRate, t, fs, bitrate] = runCoding(filePath, 'evs', plcMode, options, ii, 'doPlot', DO_PLOT);
bitrate
actualErrRate
audiowrite('test.wav', deg, fs)


