function [deg, fs] = addDegradation(inPath, outPath, fs, options, ii)


switch options.type
    
    case 'clean'
        
        [deg,fs] = audioread(inPath);
        audiowrite(outPath, deg, fs);
        
    case 'wbgn'
        
        [ref,fs] = audioread(inPath);
        deg = v_addnoise(ref, fs, options.wbgn_snr, 'k');
        audiowrite(outPath, deg, fs);
        
    case 'car'
        
        [ref,fs] = audioread(inPath);
        noiseFolder = options.noiseFolder;
        
        noisePath = [noiseFolder '\car.wav'];
        [n,fn] = audioread(noisePath);
        n = n(:,1); % using left channel only in case of stereo
        deg = v_addnoise(ref, fs, options.bgn_snr, 'k', n, fn);
        audiowrite(outPath, deg, fs);
        
        
    case 'bgn_file'
        
        [ref,fs] = audioread(inPath);
        noiseFolder = options.noiseFolder;
        
        noisePath = [noiseFolder '\' char(options.bgn_file)];
        [n,fn] = audioread(noisePath);
        n = n(:,1); % using left channel only in case of stereo
        deg = v_addnoise(ref, fs, options.bgn_snr, 'k', n, fn);
        audiowrite(outPath, deg, fs);        
        
        
    case 'random_bgn'
        
        [ref,fs] = audioread(inPath);
        noiseFolder = options.noiseFolder;
        
        fileList = dir([noiseFolder '\*.wav']);
        fileName = fileList( ceil(rand*size(fileList,1)) ).name;
        noisePath = [noiseFolder '\' fileName];
        [n,fn] = audioread(noisePath);
        n = n(:,1); % using left channel only in case of stereo
        deg = v_addnoise(ref, fs, options.bgn_snr, 'k', n, fn);
        audiowrite(outPath, deg, fs);
        
    case 'pub'
        
        [ref,fs] = audioread(inPath);
        noiseFolder = options.noiseFolder;
        
        noisePath = [noiseFolder '\pub.wav'];
        [n,fn] = audioread(noisePath);
        n = n(:,1); % using left channel only in case of stereo
        deg = v_addnoise(ref, fs, options.bgn_snr, 'k', n, fn);
        audiowrite(outPath, deg, fs);
        
    case 'shopping'
        
        [ref,fs] = audioread(inPath);
        noiseFolder = options.noiseFolder;
        
        noisePath = [noiseFolder '\shopping.wav'];
        [n,fn] = audioread(noisePath);
        n = n(:,1); % using left channel only in case of stereo
        deg = v_addnoise(ref, fs, options.bgn_snr, 'k', n, fn);
        audiowrite(outPath, deg, fs);
        
    case 'clipping'
        
        [ref,fs] = audioread(inPath);
        deg = applyOverload(ref, options.cl_th);
        audiowrite(outPath, deg, fs);
        
    case 'bgn'
        
        [ref,fs] = audioread(inPath);
        [xNoise, noiseFS] = audioread(options.noisePath);
        xNoise = xNoise(:,1);
        deg = v_addnoise(ref, fs, options.bgn_snr, 'k', xNoise, noiseFS);
        audiowrite(outPath, deg, fs);
        
    case 'bandpass'
        
        if strcmp(options.fpass, 'swb')
            
            D = load('swb_filter.mat');
            D = D.D;
            
            options.fpass = [50 14000];
            
            [ref,fs] = audioread(inPath);
            
            filtDelay = (length(D.Coefficients)-1)/2;
            nCols = size(ref,2);
            deg = filter(D, [ref; zeros(filtDelay,nCols)]);
            deg = deg(filtDelay+1:end,:);
            
        elseif strcmp(options.fpass, 'wb')
            
            options.fpass = [100 7000];
            
            [ref,fs] = audioread(inPath);
            deg = bandpass(ref, options.fpass, fs);
            
        elseif strcmp(options.fpass, 'nb')
            
            options.fpass = [300 3400];
            
            [ref,fs] = audioread(inPath);
            deg = bandpass(ref, options.fpass, fs);
            
        else
            [ref,fs] = audioread(inPath);
            deg = bandpass(ref, options.fpass, fs);
            
        end
        
        audiowrite(outPath, deg, fs);
        
    case 'lowpass'
        
        [ref,fs] = audioread(inPath);
        deg = lowpass(ref, options.fpass(2), fs, 'Steepness',0.99);
        audiowrite(outPath, deg, fs);
        
    case 'highpass'
        
        [ref,fs] = audioread(inPath);
        deg = highpass(ref, options.fpass(1), fs, 'Steepness',0.99);
        audiowrite(outPath, deg, fs);        
        
    case 'timeclipping'
        
        insertFrameLoss(inPath, outPath, options.tc_fer, options.tc_nburst);
        
    case 'p50mnru'
        
        [deg, fs] = p50mnru_v02(inPath, outPath, options.p50_q, ii);
        
        
    case 'arb_filter'
        [ref,fs] = audioread(inPath);
        deg = applyArbFilter(ref);
        audiowrite(outPath, deg, fs);
        
    case 'asl'
        
        [deg, fs] = asl26_v02(inPath, outPath, options.asl_level, ii);
        
    otherwise
        
        [deg,fs] = audioread(inPath);
        audiowrite(outPath, deg, fs);
        
end




















end