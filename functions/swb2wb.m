function [deg, fsNew] = swb2wb(inPath)


% read wav and write pcm
[~, fsSrc, srcFileLength] = wav2pcm(inPath, 'tmp_src_speech.pcm');

% resample
if fsSrc == 48e3
    [fsNew, fileLengthNew] = pcmDown3('tmp_src_speech.pcm', 'tmp_src16_speech.pcm', srcFileLength, fsSrc);
else
    error('input must be 48 kHz')
end

[fsNew, fileLengthNew] = pcmUp3('tmp_src16_speech.pcm', 'tmp_src48_speech.pcm', fileLengthNew, fsNew);


deg = pcmread('tmp_src48_speech.pcm');

deleteTempFiles(pwd)

end




function deleteTempFiles(path)

path = [path '\'];

fclose all;

while exist([path 'tmp_src16_speech.pcm'], 'file')==2
    delete tmp_src16_speech.pcm
end

while exist([path 'tmp_src_speech.pcm'], 'file')==2
    delete tmp_src_speech.pcm
end

while exist([path 'tmp_src48_speech.pcm'], 'file')==2
    delete tmp_src48_speech.pcm
end

end

