function encodeSync_v02(inputPcmName, outputPcmName, delay, fileLength, ii)

tmpvar = evalin('base', 'tmpFolder');

global tmp_sync;
tmp_sync = [tmpvar 'tmp_sync' num2str(ii) '.tmp'];


deleteTempFiles()

%%
% fill
[status, result] = system(['concat -f ' inputPcmName ' preamble.g719dec ' tmp_sync]);
if status ~= 0
    disp(result)
    error('Something went wrong');
end

% strip
[status, result] = system(['astrip -sample -start ' num2str(delay+1) ' -n ' num2str(fileLength) ' ' tmp_sync ' ' outputPcmName]);
if status ~= 0
    disp(result)
    error('Something went wrong');
end

deleteTempFiles()

end



function deleteTempFiles()
warning off
global tmp_sync
fclose all;


while exist(tmp_sync, 'file')==2
    delete(tmp_sync)
end



% warning on
end