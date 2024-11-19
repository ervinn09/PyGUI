function x = pcmread(filepath, native)
%PCMREAD reads raw pcm audio signals, with signed 16 bit sampling and
%little endian byte order
%
%       filepath = 'c:\speech.wav';
%       x = pcmread(filepath);

if nargin < 2
    native = 'normalize';
end

if strcmp(native, 'native')
    
    fileID = fopen(filepath);
    if (fileID < 0)
        error('output pcm file cannot be opened')
    end
    x = fread(fileID,'int16=>int16');
    fclose(fileID);
    
else
    
    fileID = fopen(filepath);
    if (fileID < 0)
        error('output pcm file cannot be opened')
    end
    rawAudio = fread(fileID,'int16=>double');
    x = rawAudio / (2^16/2); % Matlab audio vectors are normalized between -1 and 1
    fclose(fileID);
    
end

end