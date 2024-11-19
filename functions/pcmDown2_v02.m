function [fsNew, fileLengthNew] = pcmDown2_v02(pcmInPath, pcmOutName, fileLength, fs, ii)

%%
global tmp_down_1;
global tmp_down_2;

tmpvar = evalin('base', 'tmpFolder');

tmp_down_1 = [tmpvar 'tmp_down_1_' num2str(ii) '.tmp'];
tmp_down_2 = [tmpvar 'tmp_down_2_' num2str(ii) '.tmp'];


deleteTempFiles()

%%

filterLength = fs*0.02;
fsNew = fs/2; 
fileLengthNew = fileLength/2;

% fill
[status, result] = system(['concat -f ' pcmInPath ' preamble.g719dec ' tmp_down_1]);
if status ~= 0
    disp(result)
    error('Something went wrong');
end

% filter
[status, result] = system(['filter -down SHQ2 ' tmp_down_1 ' ' tmp_down_2 ' ' num2str(filterLength)]);
if status ~= 0
    disp(result)
    error('Something went wrong');
end

% compensate delay
[status, result] = system(['astrip -sample -start 219 -n ' num2str(fileLengthNew) ' ' tmp_down_2 ' ' pcmOutName]);
if status ~= 0
    disp(result)
    error('Something went wrong');
end

deleteTempFiles()


end


function deleteTempFiles()
warning off
global tmp_down_1
global tmp_down_2;

fclose all;


while exist(tmp_down_1, 'file')==2
    delete(tmp_down_1)
end

while exist(tmp_down_2, 'file')==2
    delete(tmp_down_2)
end

% warning on
end