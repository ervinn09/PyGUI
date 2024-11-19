function pcmwrite(filepath, x)
%PCMWRITE x = pcmwrite(filepath, x)

    if ~isa(x, 'int16') 
        error('input vector must be int16!')
    end
    if all(abs(x)<=1)
        warning('all values in x<=1: do not use normalized vector!')
    end
    
    fileID = fopen(filepath,'w');
    if (fileID < 0)
        error('output pcm file cannot be created')
    end
    fwrite(fileID, x, 'int16');
    fclose(fileID);

end