function x = pcm2wav(pcmPath, wavPath, fs)
% x = pcm2wav(pcmPath, wavPath, fs)

% read pcm
x = pcmread(pcmPath);

% write wav file
audiowrite(wavPath, x, fs)

end