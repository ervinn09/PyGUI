function [x, fs, fileLength] = wav2pcm(wavPath, pcmPath)
%PCMWRITE x = pcmwrite(filepath, x)

% read
[rawAudio, fs] = audioread(wavPath, 'native');
fileLength = length(rawAudio);

% check 16 bit
if ~isa(rawAudio, 'int16')
    error('input vector must be int16!')
end

% write pcm
pcmwrite(pcmPath, rawAudio)

% output normalized matlab audio vector
if nargout > 0
    x = double(rawAudio) ./ (2^16/2);
end

end