function y = applyOverload(x, overload)

% 1% ~ 0.09
% 2% ~ 0.11

% [x, fs] = audioread(inPath);

y = x;
y = min(overload, y);
y = max(-overload,y);

% audiowrite(outPath, x, fs);

end










