function [fsNew, fileLengthNew] = pcmUp3_v02(pcmInPath, pcmOutName, fileLength, fs, ii)

global tmp_up_1;
global tmp_up_2;

tmpvar = evalin('base', 'tmpFolder');

tmp_up_1 = [tmpvar 'tmp_up_1_' num2str(ii) '.tmp'];
tmp_up_2 = [tmpvar 'tmp_up_2_' num2str(ii) '.tmp'];

deleteTempFiles()

%%
filterLength = fs*0.02;
fsNew = 3*fs; 
fileLengthNew = 3*fileLength;

% fill
[status, result] = system(['concat -f ' pcmInPath ' preamble.g719dec ' tmp_up_1]);
if status ~= 0
    disp(result)
    error('Something went wrong');
end

% filter
[status, result] = system(['filter -up SHQ3 ' tmp_up_1 ' ' tmp_up_2 ' ' num2str(filterLength)]);
if status ~= 0
    disp(result)
    error('Something went wrong');
end

% compensate delay
[status, result] = system(['astrip -sample -start 437 -n ' num2str(fileLengthNew) ' ' tmp_up_2 ' ' pcmOutName]);
if status ~= 0
    disp(result)
    error('Something went wrong');
end

deleteTempFiles()


end


function deleteTempFiles()
warning off

global tmp_up_1
global tmp_up_2;

fclose all;

while exist(tmp_up_1, 'file')==2
    delete(tmp_up_1)
end

while exist(tmp_up_2, 'file')==2
    delete(tmp_up_2)
end

% warning on
end