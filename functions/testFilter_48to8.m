%
%                            E V S    -    B I T R A T E     M O D E S
% mode:       1       2       3       4       5        6        7        8        9        10       11       12
% rList = {'5900', '7200', '8000', '9600', '13200', '16400', '24400', '32000', '48000', '64000', '96000', '128000' };

clear
% filePath = 'D:\Soundfiles\NCS_semi_spontaneous\ref\m016_beirut_d7.wav';
filePath = 'C:\Users\Gabriel\Dropbox\UFESQ\Jens_Beispiel_Sprachfiles\2017_06_PTCA_example_files\EN_fm_wide_ref.wav';
% filePath = 'C:\Users\Gabriel\tubCloud\Soundfiles\P501\AnnexC_WB\P501_C_english_m1_WB_16k.wav';


[rawRef, fsSrc] = audioread(filePath, 'native');

% write pcm
fileID = fopen('test.pcm','w');
if (fileID < 0)
    error('output pcm file cannot be created')
end
fwrite(fileID,rawRef,'int16');
fclose(fileID);

% fill
[status, results] = system('concat -f test.pcm preamble.g719dec test2.pcm');

% filter
[status, results] = system('filter -down SHQ3 test2.pcm test3.pcm 960');
fDelay = 145;

% read pcm
filePath = 'test3.pcm';
fileID = fopen(filePath);
rawDeg = fread(fileID,'int16');
fclose(fileID);

deg = double(rawDeg) ./ (2^16/2);
ref = double(rawRef) ./ (2^16/2);
refS = resample(ref, 16e3, 48e3);

deg = deg(fDelay+1:length(refS)+fDelay);


figure(1)
clf
plot(refS)
hold on
plot(deg)
