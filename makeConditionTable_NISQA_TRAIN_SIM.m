function t = makeConditionTable_NISQA_TRAIN_SIM()

catnames = {'dist_post_codec', 'filter', 'timeclipping', 'wbgn', 'p50mnru', 'bgn', 'clipping', 'arb_filter', 'asl_in', 'asl_out', 'codec1', 'codec2', 'codec3', 'plcMode1', 'plcMode2', 'plcMode3'};
doublenames = {'wbgn_snr', 'bgn_snr', 'tc_fer', 'tc_nburst', 'cl_th', 'bp_low', 'bp_high', 'p50_q', 'bMode1', 'bMode2', 'bMode3', 'FER1', 'FER2', 'FER3', 'asl_in_level', 'asl_out_level'};

N = 100000;

c = cell(N, length(catnames));
c(:) = {'-'};
t1 = cell2table(c, 'VariableNames', catnames);
t1 = convertvars(t1, catnames, 'categorical');

c = zeros(N, length(doublenames));
c(:) = nan;
t2 = array2table(c, 'VariableNames', doublenames);

t = [t1,t2];


%% Codec list
codec_list = struct;

codec_list(1).codec = {'amrnb'};
codec_list(1).bModes = 1:8;
codec_list(1).plcMode = {'noloss'};

codec_list(2).codec = {'amrwb'};
codec_list(2).bModes = 1:9;
codec_list(2).plcMode = {'noloss'};

codec_list(3).codec = {'evs'};
codec_list(3).bModes = 1:12;
codec_list(3).plcMode = {'noloss'};

codec_list(4).codec = {'opus'};
codec_list(4).bModes = linspace(6,48,12);
codec_list(4).plcMode = {'noloss'};

codec_list(5).codec = {'g722'};
codec_list(5).bModes = 1:3;
codec_list(5).plcMode = {'noloss'};

codec_list(6).codec = {'g711'};
codec_list(6).bModes = 1;
codec_list(6).plcMode = {'noloss'};


%% PARAMETERS

% white background noise
WBGN_N = 100;
WBGN_SNR_START = -50;
WBGN_SNR_END = 50;

% recorded background noises
BGN_N = 100;
BGN_SNR_START = -50;
BGN_SNR_END = 50;

% timeclipping
TC_FER_N = 50;
TC_BURST_N = 3;
TC_FER_START = 1;
TC_FER_END = 50;
TC_BURST_START = 1;
TC_BURST_END = 10;

% highpass (in mel)
HP_N = 100;
HP_COF_MIN = 1;
HP_COF_MAX = 55;

% lowpass (in mel)
LP_N = 100;
LP_COF_MIN = 1;
LP_COF_MAX = 55;

% bandpass (in mel)
BP_N = 100;
BP_COF_MIN = 1;
BP_COF_MAX = 55;

% mnru 
Q_N = 100;
Q_SNR_START = -30;
Q_SNR_END = 30;

% clipping 
CL_N = 100;
CL_START = 0.01;
CL_END = 0.5;

% arbitrary filter
AFILT_N = 200;

% asl
ASL_N = 100;
ASL_START = -30;
ASL_STOP = 30;

% random
RANDOM_N = 20;
RANDOM_START = 0.01;
RANDOM_END = 0.5;

% bursty
BURSTY_N = 20;
BURSTY_START = 0.01;
BURSTY_END = 0.3;


%%
warning off

i = 1;

%% wbgn
for snr = linspace(WBGN_SNR_START, WBGN_SNR_END, WBGN_N)
    
    t.wbgn(i) = 'x';
    t.wbgn_snr(i) = snr;
    
    i = i + 1;
end

%% bgn
for snr = linspace(BGN_SNR_START, BGN_SNR_END, BGN_N)
    
    t.bgn(i) = 'random_bgn';
    t.bgn_snr(i) = snr;
    
    i = i + 1;
end

%% timeclipping
for fer = linspace(TC_FER_START, TC_FER_END, TC_FER_N)
    for nburst = linspace(TC_BURST_START, TC_BURST_END, TC_BURST_N)
        t.timeclipping(i) = 'x';
        t.tc_fer(i) = fer;
        t.tc_nburst(i) = floor(nburst);
        i = i + 1;
    end
end


%% filter
for fpass = linspace(HP_COF_MIN, HP_COF_MAX, HP_N)
    
    t.filter(i) = {'highpass'};
    t.bp_low(i) = mel2hz(fpass);
    
    i = i + 1;
end

for fpass = linspace(LP_COF_MIN, LP_COF_MAX, LP_N)
    t.filter(i) = {'lowpass'};
    t.bp_high(i) = mel2hz(fpass);
    
    i = i + 1;
end

for fpassHigh = linspace(BP_COF_MIN+1,BP_COF_MAX,sqrt(BP_N))

    for fpassLow = linspace(BP_COF_MIN,fpassHigh-1,sqrt(BP_N))
        t.filter(i) = {'bandpass'};
        t.bp_high(i) = mel2hz(fpassHigh);
        t.bp_low(i) = mel2hz(fpassLow);
        i = i + 1;
    end
    
end



%% p50 mnru
for q = linspace(Q_SNR_START, Q_SNR_END, Q_N)
    
    t.p50mnru(i) = 'x';
    t.p50_q(i) = q;
    
    i = i + 1;
end

%% clipping
for cl_th = linspace(CL_START, CL_END, CL_N)
    
    t.clipping(i) = 'x';
    t.cl_th(i) = cl_th;
    
    i = i + 1;
end

%% arb filter
for cl_th = 1:AFILT_N
    t.arb_filter(i) = 'x';
    i = i + 1;
end

%% asl 
for asl_level = linspace(ASL_START, ASL_STOP, ASL_N)
    t.asl_out(i) = 'x';
    t.asl_out_level(i) = asl_level;
    i = i + 1;
end

%% codecs 
for iCodec = 1:size(codec_list,2)
    for iBitrate = 1:length(codec_list(iCodec).bModes)
        t.codec1(i) = codec_list(iCodec).codec;
        t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
        t.plcMode1(i) = codec_list(iCodec).plcMode;
        i = i + 1;
    end
end

%% tandem
for iCodec = 1:size(codec_list,2)
    for iBitrate = 1:length(codec_list(iCodec).bModes)
        
        t.codec1(i) = codec_list(iCodec).codec;
        t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
        t.plcMode1(i) = codec_list(iCodec).plcMode;
        
        t.codec2(i) = codec_list(iCodec).codec;
        t.bMode2(i) = codec_list(iCodec).bModes(iBitrate);
        t.plcMode2(i) = codec_list(iCodec).plcMode;        
        
        i = i + 1;
    end
end

%% tripple tandem
for iCodec = 1:size(codec_list,2)
    for iBitrate = 1:length(codec_list(iCodec).bModes)
        
        t.codec1(i) = codec_list(iCodec).codec;
        t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
        t.plcMode1(i) = codec_list(iCodec).plcMode;
        
        t.codec2(i) = codec_list(iCodec).codec;
        t.bMode2(i) = codec_list(iCodec).bModes(iBitrate);
        t.plcMode2(i) = codec_list(iCodec).plcMode;        
        
        t.codec3(i) = codec_list(iCodec).codec;
        t.bMode3(i) = codec_list(iCodec).bModes(iBitrate);
        t.plcMode3(i) = codec_list(iCodec).plcMode;         
        i = i + 1;
    end
end

%% random loss
for iCodec = 1:size(codec_list,2)
    for iBitrate = 1:length(codec_list(iCodec).bModes)
        for fer = linspace(RANDOM_START, RANDOM_END, RANDOM_N) 
            t.codec1(i) = codec_list(iCodec).codec;
            t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
            t.plcMode1(i) = {'random'};
            t.FER1(i) = fer;
            i = i + 1;
        end
    end
end

%% bursty loss
for iCodec = 1:size(codec_list,2)
    for iBitrate = 1:length(codec_list(iCodec).bModes)
        for fer = linspace(BURSTY_START, BURSTY_END, BURSTY_N) 
            t.codec1(i) = codec_list(iCodec).codec;
            t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
            t.plcMode1(i) = {'bursty'};
            t.FER1(i) = fer;
            i = i + 1;
        end
    end
end


%% Combinations

% white background noise
WBGN_N = 50;
WBGN_SNR_START = 0;
WBGN_SNR_END = 40;

% recorded background noises
BGN_N = 50;
BGN_SNR_START = 0;
BGN_SNR_END = 40;

% timeclipping
TC_FER_N = 30;
TC_BURST_N = 3;
TC_FER_START = 1;
TC_FER_END = 50;
TC_BURST_START = 1;
TC_BURST_END = 10;

% highpass (in mel)
HP_N = 50;
HP_COF_MIN = 1;
HP_COF_MAX = 55;

% lowpass (in mel)
LP_N = 50;
LP_COF_MIN = 1;
LP_COF_MAX = 55;

% bandpass (in mel)
BP_N = 50;
BP_COF_MIN = 1;
BP_COF_MAX = 55;

% mnru 
Q_N = 50;
Q_SNR_START = -30;
Q_SNR_END = 30;

% clipping 
CL_N = 50;
CL_START = 0.01;
CL_END = 0.5;

% arbitrary filter
AFILT_N = 50;

% asl
ASL_N = 50;
ASL_START = -30;
ASL_STOP = 30;

% random
RANDOM_N = 4;
RANDOM_START = 0.01;
RANDOM_END = 0.3;

% bursty
BURSTY_N = RANDOM_N;
BURSTY_START = RANDOM_START;
BURSTY_END = RANDOM_END;


%% bgn with codecs and no loss

nLoops = 100;
snr_range = linspace(BGN_SNR_START, BGN_SNR_END, 100);
codec_range = 1:size(codec_list,2);
fer_range = linspace(BURSTY_START, BURSTY_END, 100);
plcMode_range = {'bursty', 'random'};

for iLoop = 1:nLoops
    
    iCodec = randsample(codec_range,1);
    bitrate_range = 1:length(codec_list(iCodec).bModes);
    iBitrate = randsample(bitrate_range,1);
    
    snr = randsample(snr_range,1);
    fer = randsample(fer_range,1);
    plcMode = randsample(plcMode_range,1);
   
    t.codec1(i) = codec_list(iCodec).codec;
    t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
    
    t.plcMode1(i) = codec_list(iCodec).plcMode;
        
    t.bgn(i) = 'random_bgn';
    t.bgn_snr(i) = snr;
    
    i = i + 1;
    
end


%% bgn with codecs and loss

nLoops = 100;
snr_range = linspace(BGN_SNR_START, BGN_SNR_END, 100);
codec_range = 1:size(codec_list,2);
fer_range = linspace(BURSTY_START, BURSTY_END, 100);
plcMode_range = {'bursty', 'random'};

for iLoop = 1:nLoops
    
    iCodec = randsample(codec_range,1);
    bitrate_range = 1:length(codec_list(iCodec).bModes);
    iBitrate = randsample(bitrate_range,1);
    
    snr = randsample(snr_range,1);
    fer = randsample(fer_range,1);
    plcMode = randsample(plcMode_range,1);
   
    t.codec1(i) = codec_list(iCodec).codec;
    t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
    
    t.plcMode1(i) = plcMode;
    
    t.FER1(i) = fer;
    
    t.bgn(i) = 'random_bgn';
    t.bgn_snr(i) = snr;
    
    i = i + 1;
    
end


%% wbgn with codecs and no loss

nLoops = 100;
snr_range = linspace(BGN_SNR_START, BGN_SNR_END, 100);
codec_range = 1:size(codec_list,2);
fer_range = linspace(BURSTY_START, BURSTY_END, 100);
plcMode_range = {'bursty', 'random'};

for iLoop = 1:nLoops
    
    iCodec = randsample(codec_range,1);
    bitrate_range = 1:length(codec_list(iCodec).bModes);
    iBitrate = randsample(bitrate_range,1);
    
    snr = randsample(snr_range,1);
    fer = randsample(fer_range,1);
    plcMode = randsample(plcMode_range,1);
   
    t.codec1(i) = codec_list(iCodec).codec;
    t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
    
    t.plcMode1(i) = codec_list(iCodec).plcMode;
        
    t.wbgn(i) = 'x';
    t.wbgn_snr(i) = snr;
    
    i = i + 1;
    
end


%% wbgn with codecs and loss
nLoops = 100;
snr_range = linspace(BGN_SNR_START, BGN_SNR_END, 100);
codec_range = 1:size(codec_list,2);
fer_range = linspace(BURSTY_START, BURSTY_END, 100);
plcMode_range = {'bursty', 'random'};

for iLoop = 1:nLoops
    
    iCodec = randsample(codec_range,1);
    bitrate_range = 1:length(codec_list(iCodec).bModes);
    iBitrate = randsample(bitrate_range,1);
    
    snr = randsample(snr_range,1);
    fer = randsample(fer_range,1);
    plcMode = randsample(plcMode_range,1);
   
    t.codec1(i) = codec_list(iCodec).codec;
    t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
    
    t.plcMode1(i) = plcMode;
    
    t.FER1(i) = fer;
    
    t.wbgn(i) = 'x';
    t.wbgn_snr(i) = snr;
    
    i = i + 1;
    
end


%% clipping with codec and loss
nLoops = 100;
snr_range = linspace(BGN_SNR_START, BGN_SNR_END, 100);
codec_range = 1:size(codec_list,2);
fer_range = linspace(BURSTY_START, BURSTY_END, 100);
clip_range = linspace(CL_START, CL_END, CL_N);
plcMode_range = {'bursty', 'random'};

for iLoop = 1:nLoops
    
    cl_th = randsample(clip_range,1);
    iCodec = randsample(codec_range,1);
    bitrate_range = 1:length(codec_list(iCodec).bModes);
    iBitrate = randsample(bitrate_range,1);
    
    snr = randsample(snr_range,1);
    fer = randsample(fer_range,1);
    plcMode = randsample(plcMode_range,1);
   
    t.codec1(i) = codec_list(iCodec).codec;
    t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
    
    t.plcMode1(i) = plcMode;
    
    t.FER1(i) = fer;
    
    t.clipping(i) = 'x';
    t.cl_th(i) = cl_th;
    
    i = i + 1;
    
end


%% arb filter with codec and loss

nLoops = 100;
codec_range = 1:size(codec_list,2);
fer_range = linspace(BURSTY_START, BURSTY_END, 100);
plcMode_range = {'bursty', 'random'};

for iLoop = 1:nLoops
    
    iCodec = randsample(codec_range,1);
    bitrate_range = 1:length(codec_list(iCodec).bModes);
    iBitrate = randsample(bitrate_range,1);
    
    fer = randsample(fer_range,1);
    plcMode = randsample(plcMode_range,1);
   
    t.codec1(i) = codec_list(iCodec).codec;
    t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
    
    t.plcMode1(i) = plcMode;
    
    t.FER1(i) = fer;
    
    t.arb_filter(i) = 'x';

    
    i = i + 1;
    
end

%% arb filter with codec, post codec
nLoops = 100;
codec_range = 1:size(codec_list,2);
fer_range = linspace(BURSTY_START, BURSTY_END, 100);
plcMode_range = {'bursty', 'random'};

for iLoop = 1:nLoops
    
    iCodec = randsample(codec_range,1);
    bitrate_range = 1:length(codec_list(iCodec).bModes);
    iBitrate = randsample(bitrate_range,1);
    
    fer = randsample(fer_range,1);
    plcMode = randsample(plcMode_range,1);
   
    t.codec1(i) = codec_list(iCodec).codec;
    t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
    
    t.plcMode1(i) = plcMode;
    
    t.FER1(i) = fer;
    
    t.arb_filter(i) = 'x';
    t.dist_post_codec(i) = 'x';

    
    i = i + 1;
    
end


%% asl in with codec

nLoops = 100;
codec_range = 1:size(codec_list,2);
fer_range = linspace(BURSTY_START, BURSTY_END, 100);
plcMode_range = {'bursty', 'random'};
asl_range = linspace(ASL_START, ASL_STOP, ASL_N);

for iLoop = 1:nLoops
    
    asl_level = randsample(asl_range,1);
    
    iCodec = randsample(codec_range,1);
    bitrate_range = 1:length(codec_list(iCodec).bModes);
    iBitrate = randsample(bitrate_range,1);
    
    fer = randsample(fer_range,1);
    plcMode = randsample(plcMode_range,1);
   
    t.codec1(i) = codec_list(iCodec).codec;
    t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
    
    t.plcMode1(i) = plcMode;
    
    t.FER1(i) = fer;
    
    t.asl_in(i) = 'x';
    t.asl_in_level(i) = asl_level;

    i = i + 1;
    
end

%% asl out with codec

nLoops = 100;
codec_range = 1:size(codec_list,2);
fer_range = linspace(BURSTY_START, BURSTY_END, 100);
plcMode_range = {'bursty', 'random'};
asl_range = linspace(ASL_START, ASL_STOP, ASL_N);

for iLoop = 1:nLoops
    
    asl_level = randsample(asl_range,1);
    
    iCodec = randsample(codec_range,1);
    bitrate_range = 1:length(codec_list(iCodec).bModes);
    iBitrate = randsample(bitrate_range,1);
    
    fer = randsample(fer_range,1);
    plcMode = randsample(plcMode_range,1);
   
    t.codec1(i) = codec_list(iCodec).codec;
    t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);
    
    t.plcMode1(i) = plcMode;
    
    t.FER1(i) = fer;
    
    t.asl_out(i) = 'x';
    t.asl_out_level(i) = asl_level;

    i = i + 1;
    
end


%% Random combinations
p = 0.1;
p_codec1 = 0.8;

for k = 1:6015
    
    if rand < p
        t.filter(i) = {'highpass'};
        
        fpass = linspace(HP_COF_MIN, HP_COF_MAX, 10*HP_N);
        fpass = fpass( randperm(length(fpass),1) );
        
        t.bp_low(i) = mel2hz(fpass);
    end
    
    if rand < p
        t.filter(i) = {'lowpass'};
        
        fpass = linspace(LP_COF_MIN, LP_COF_MAX, 10*LP_N);
        fpass = fpass( randperm(length(fpass),1) );
        
        t.bp_high(i) = mel2hz(fpass);
    end
    
    
    if rand < p
        t.filter(i) = {'bandpass'};
        
        fpassHigh = linspace(BP_COF_MIN+1,BP_COF_MAX,10*BP_N);
        fpassHigh = fpassHigh( randperm(length(fpassHigh),1) );
        
        fpassLow = linspace(BP_COF_MIN,fpassHigh-1,10*BP_N);
        fpassLow = fpassLow( randperm(length(fpassLow),1) );
        
        t.bp_high(i) = mel2hz(fpassHigh);
        t.bp_low(i) = mel2hz(fpassLow);
    end
    
    
    if rand < p
        snr = linspace(WBGN_SNR_START, WBGN_SNR_END, 10*WBGN_N);
        snr = snr( randperm(length(snr),1) );
        t.wbgn(i) = 'x';
        t.wbgn_snr(i) = snr;
    end
    
    
    if rand < p
        snr = linspace(BGN_SNR_START, BGN_SNR_END, 10*BGN_N);
        snr = snr( randperm(length(snr),1) );
        t.bgn(i) = 'random_bgn';
        t.bgn_snr(i) = snr;
    end
    
    if rand < p
        
        fer = linspace(TC_FER_START, TC_FER_END, 10*TC_FER_N);
        nburst = linspace(TC_BURST_START, TC_BURST_END, 10*TC_BURST_N);
        
        fer = fer( randperm(length(fer),1) );
        nburst = nburst( randperm(length(nburst),1) );
        
        t.timeclipping(i) = 'x';
        t.tc_fer(i) = fer;
        t.tc_nburst(i) = floor(nburst);
        
    end
    
    
    if rand < p
        q = linspace(Q_SNR_START, Q_SNR_END,10*Q_N);
        q = q( randperm(length(q),1) );
        t.p50mnru(i) = 'x';
        t.p50_q(i) = q;
    end
    
    if rand < p
        
        cl_th = linspace(CL_START, CL_END, 10*CL_N);
        cl_th = cl_th( randperm(length(cl_th),1) );
        t.clipping(i) = 'x';
        t.cl_th(i) = cl_th;
        
    end
    
    if rand < p
        t.arb_filter(i) = 'x';
    end
    
    if rand < p
        asl_level = linspace(ASL_START, ASL_STOP, 10*ASL_N);
        asl_level = asl_level( randperm(length(asl_level),1) );
        t.asl_out(i) = 'x';
        t.asl_out_level(i) = asl_level;
    end
    
    if rand < p
        asl_level = linspace(ASL_START, ASL_STOP, 10*ASL_N);
        asl_level = asl_level( randperm(length(asl_level),1) );
        t.asl_in(i) = 'x';
        t.asl_in_level(i) = asl_level;
    end
    
    
    if rand < p
        asl_level = linspace(ASL_START, ASL_STOP, 10*ASL_N);
        asl_level = asl_level( randperm(length(asl_level),1) );
        t.asl_in(i) = 'x';
        t.asl_in_level(i) = asl_level;
    end
    
    if rand < p
        t.dist_post_codec(i) = 'x';
    end
    
    % codec 1
    if rand < p_codec1
        
        iCodec = randperm( size(codec_list,2), 1);
        iBitrate = randperm( length(codec_list(iCodec).bModes), 1);
        
        t.codec1(i) = codec_list(iCodec).codec;
        t.bMode1(i) = codec_list(iCodec).bModes(iBitrate);      
        t.plcMode1(i) = {'noloss'};
        
        if rand < p
            fer = linspace(BURSTY_START, BURSTY_END, 10*BURSTY_N);
            fer = fer(randperm(length(fer),1));
            t.plcMode1(i) = {'bursty'};
            t.FER1(i) = fer;
        end
        
        if rand < p
            fer = linspace(RANDOM_START, RANDOM_END, 10*RANDOM_N);
            fer = fer(randperm(length(fer),1));
            t.plcMode1(i) = {'random'};
            t.FER1(i) = fer;
        end
        
        % codec 2
        if rand < p

            iCodec = randperm( size(codec_list,2), 1);
            iBitrate = randperm( length(codec_list(iCodec).bModes), 1);

            t.codec2(i) = codec_list(iCodec).codec;
            t.bMode2(i) = codec_list(iCodec).bModes(iBitrate);      
            t.plcMode2(i) = {'noloss'};

            if rand < p
                fer = linspace(BURSTY_START, BURSTY_END, 10*BURSTY_N);
                fer = fer(randperm(length(fer),1));
                t.plcMode2(i) = {'bursty'};
                t.FER2(i) = fer;
            end

            if rand < p
                fer = linspace(RANDOM_START, RANDOM_END, 10*RANDOM_N);
                fer = fer(randperm(length(fer),1));
                t.plcMode2(i) = {'random'};
                t.FER2(i) = fer;
            end
            
            % codec 3
            if rand < p

                iCodec = randperm( size(codec_list,2), 1);
                iBitrate = randperm( length(codec_list(iCodec).bModes), 1);

                t.codec3(i) = codec_list(iCodec).codec;
                t.bMode3(i) = codec_list(iCodec).bModes(iBitrate);      
                t.plcMode3(i) = {'noloss'};

                if rand < p
                    fer = linspace(BURSTY_START, BURSTY_END, 10*BURSTY_N);
                    fer = fer(randperm(length(fer),1));
                    t.plcMode3(i) = {'bursty'};
                    t.FER3(i) = fer;
                end

                if rand < p
                    fer = linspace(RANDOM_START, RANDOM_END, 10*RANDOM_N);
                    fer = fer(randperm(length(fer),1));
                    t.plcMode1(i) = {'random'};
                    t.FER1(i) = fer;
                end
            end            
        end        
    end
    
    i = i + 1;
    
end

%%
t = t(1:i-1,:);

t.con = (1:height(t))';



warning on
end