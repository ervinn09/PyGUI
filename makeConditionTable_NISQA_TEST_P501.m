function t = makeConditionTable(noiseFolder)

catnames = {'dist_post_codec', 'filter', 'timeclipping', 'wbgn', 'p50mnru', 'bgn', 'bgn_file', 'clipping', 'arb_filter', 'asl_in', 'asl_out', 'codec1', 'codec2', 'codec3', 'plcMode1', 'plcMode2', 'plcMode3'};
doublenames = {'wbgn_snr', 'bgn_snr', 'tc_fer', 'tc_nburst', 'cl_th', 'bp_low', 'bp_high', 'p50_q', 'bMode1', 'bMode2', 'bMode3', 'FER1', 'FER2', 'FER3', 'asl_in_level', 'asl_out_level'};

N = 1000;

c = cell(N, length(catnames));
c(:) = {'-'};
t1 = cell2table(c, 'VariableNames', catnames);
t1 = convertvars(t1, catnames, 'categorical');

c = zeros(N, length(doublenames));
c(:) = nan;
t2 = array2table(c, 'VariableNames', doublenames);

t = [t1,t2];

%% noise files
% noiseFolder = 'D:\Other\DNS-Challenge\DNS-Challenge\datasets\noise';
noiseFileList = dir([noiseFolder '\*.wav']);


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
BGN_N = 60;
BGN_SNR_START = -10;
BGN_SNR_END = 0;

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
BURSTY_END = 0.01;


%%
warning off

i = 1;

%% bgn



%% anchor

% clean
i = i + 1;

% P50MNRU 25dB
t.p50mnru(i) = 'x';
t.p50_q(i) = 25;
i = i + 1;

% White Noise 12dB
t.wbgn(i) = 'x';
t.wbgn_snr(i) = 12;
i = i + 1;

% Level -20
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-20;
i = i + 1;

% BP 500 - 2500
t.filter(i) = {'bandpass'};
t.bp_low(i) = 500;
t.bp_high(i) = 2500;
i = i + 1;



% BP 100 - 5000
t.filter(i) = {'bandpass'};
t.bp_low(i) = 100;
t.bp_high(i) = 5000;
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-10;
i = i + 1;

% Time Clipping 2%
t.timeclipping(i) = 'x';
t.tc_fer(i) = 2;
t.tc_nburst(i) = 3;
i = i + 1;

% Time Clipping 20%
t.timeclipping(i) = 'x';
t.tc_fer(i) = 20;
t.tc_nburst(i) = 3;
i = i + 1;

%% Amp clipping + Codec
t.clipping(i) = 'x';
t.cl_th(i) = 0.15;
t.codec1(i) = {'amrwb'};
t.bMode1(i) = 1;
t.plcMode1(i) = {'noloss'};
i = i + 1;

t.clipping(i) = 'x';
t.cl_th(i) = 0.10;
t.codec1(i) = {'opus'};
t.bMode1(i) = 12;
t.plcMode1(i) = {'noloss'};
i = i + 1;


t.clipping(i) = 'x';
t.cl_th(i) = 0.05;
t.codec1(i) = {'evs'};
t.bMode1(i) = 5;
t.plcMode1(i) = {'noloss'};
i = i + 1;


%% Packet Loss EVS

t.codec1(i) = {'evs'};
t.bMode1(i) = 7;
t.plcMode1(i) = {'noloss'};
i = i + 1;

t.codec1(i) = {'evs'};
t.bMode1(i) = 7;
t.plcMode1(i) = {'bursty'};
t.FER1(i) = 0.03;
i = i + 1;

t.codec1(i) = {'evs'};
t.bMode1(i) = 7;
t.plcMode1(i) = {'random'};
t.FER1(i) = 0.06;
i = i + 1;

t.codec1(i) = {'evs'};
t.bMode1(i) = 7;
t.plcMode1(i) = {'bursty'};
t.FER1(i) = 0.15;
i = i + 1;

t.codec1(i) = {'evs'};
t.bMode1(i) = 7;
t.plcMode1(i) = {'random'};
t.FER1(i) = 0.25;
i = i + 1;


%% Packet Loss Opus

t.codec1(i) = {'opus'};
t.bMode1(i) = 25;
t.plcMode1(i) = {'noloss'};
i = i + 1;

t.codec1(i) = {'opus'};
t.bMode1(i) = 25;
t.plcMode1(i) = {'bursty'};
t.FER1(i) = 0.03;
i = i + 1;

t.codec1(i) = {'opus'};
t.bMode1(i) = 25;
t.plcMode1(i) = {'random'};
t.FER1(i) = 0.06;
i = i + 1;

t.codec1(i) = {'opus'};
t.bMode1(i) = 25;
t.plcMode1(i) = {'bursty'};
t.FER1(i) = 0.15;
i = i + 1;

t.codec1(i) = {'opus'};
t.bMode1(i) = 25;
t.plcMode1(i) = {'random'};
t.FER1(i) = 0.25;
i = i + 1;

%% Level
t.codec1(i) = {'opus'};
t.bMode1(i) = 25;
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-30;
i = i + 1;

t.codec1(i) = {'amrnb'};
t.bMode1(i) = 8;
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-15;
i = i + 1;

t.codec1(i) = {'amrwb'};
t.bMode1(i) = 2;
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-10;
i = i + 1;

%% Level + BGN

t.codec1(i) = {'amrnb'};
t.bMode1(i) = 8;
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-25;
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 0;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
i = i + 1;

t.codec1(i) = {'evs'};
t.bMode1(i) = 4;
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-25;
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 10;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
i = i + 1;

t.codec1(i) = {'amrwb'};
t.bMode1(i) = 9;
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-15;
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 20;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
i = i + 1;

%% Combinations
% codec / fer
t.codec1(i) = {'opus'};
t.bMode1(i) = 20;
t.plcMode1(i) = {'random'};
t.FER1(i) = 0.25;
% bgn
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 10;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
% level
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-10;
i = i + 1;


% codec / fer
t.codec1(i) = {'evs'};
t.bMode1(i) = 5;
t.plcMode1(i) = {'bursty'};
t.FER1(i) = 0.15;
% bgn
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 20;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
% level
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-15;
i = i + 1;

% codec / fer
t.codec1(i) = {'amrwb'};
t.bMode1(i) = 9;
t.plcMode1(i) = {'bursty'};
t.FER1(i) = 0.06;
% bgn
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 30;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
i = i + 1;

% codec / fer
t.codec1(i) = {'amrnb'};
t.bMode1(i) = 4;
t.plcMode1(i) = {'noloss'};
% bgn
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 10;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
% level
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-25;
i = i + 1;

% codec / fer
t.codec1(i) = {'opus'};
t.bMode1(i) = 10;
t.plcMode1(i) = {'bursty'};
t.FER1(i) = 0.15;
% bgn
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 5;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
% level
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-25;
i = i + 1;

% codec / fer
t.codec1(i) = {'amrwb'};
t.bMode1(i) = 3;
t.codec2(i) = {'amrwb'};
t.bMode2(i) = 3;
t.codec3(i) = {'amrwb'};
t.bMode3(i) = 3;
% bgn
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 20;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
% level
t.asl_in(i) = 'x';
t.asl_in_level(i) = -26-10;
i = i + 1;


% codec / fer
t.codec1(i) = {'amrnb'};
t.bMode1(i) = 8;
t.plcMode1(i) = {'random'};
t.FER1(i) = 0.03;
t.codec2(i) = {'g711'};
t.bMode2(i) = 1;
t.codec3(i) = {'amrnb'};
t.bMode3(i) = 8;
t.plcMode3(i) = {'random'};
t.FER3(i) = 0.03;
i = i + 1;


% codec / fer
t.codec1(i) = {'amrwb'};
t.bMode1(i) = 3;
t.plcMode1(i) = {'random'};
t.FER1(i) = 0.03;
t.codec2(i) = {'g722'};
t.bMode2(i) = 1;
t.codec3(i) = {'amrwb'};
t.bMode3(i) = 3;
t.plcMode3(i) = {'random'};
t.FER3(i) = 0.03;
% bgn
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 15;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
i = i + 1;

% codec / fer
t.codec1(i) = {'amrnb'};
t.bMode1(i) = 8;
t.plcMode1(i) = {'random'};
t.FER1(i) = 0.15;
t.codec2(i) = {'g711'};
t.bMode2(i) = 1;
t.codec3(i) = {'amrnb'};
t.bMode3(i) = 8;
t.plcMode3(i) = {'noloss'};
% bgn
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 10;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
i = i + 1;

%% live with bgn
i = 38;
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 15;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;

i = 40;
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 25;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;


i = 43;
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 20;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;


i = 45;
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 30;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;


i = 48;
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 12;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;


i = 50;
t.bgn(i) = 'bgn_file';
t.bgn_snr(i) = 20;
idx = ceil(rand*size(noiseFileList,1));
fileName = noiseFileList(idx).name;
noiseFileList(idx) = [];
t.bgn_file(i) = fileName;
i = i + 1;

%%
t = t(1:60,:);

t.con = (1:height(t))';



warning on
end