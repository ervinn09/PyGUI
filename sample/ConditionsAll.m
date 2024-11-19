function conTable = ConTableA() % no noise folder neded otherwise makeCondtionTableTemplate(noiseFolder)

%static names of degradations and their options more info see readme.txt
catnames = {'dist_post_codec', 'filter', 'timeclipping', 'wbgn', 'p50mnru', 'bgn', 'bgn_file', 'clipping', 'arb_filter', 'asl_in', 'asl_out', 'codec1', 'codec2', 'codec3', 'plcMode1', 'plcMode2', 'plcMode3'};
doublenames = {'wbgn_snr', 'bgn_snr', 'tc_fer', 'tc_nburst', 'cl_th', 'bp_low', 'bp_high', 'p50_q', 'bMode1', 'bMode2', 'bMode3', 'FER1', 'FER2', 'FER3', 'asl_in_level', 'asl_out_level'};

% Max Number of conditions, one condition per row, set to number of conditions
N = 1000;
%% in this block the empty table is created
c = cell(N, length(catnames));
c(:) = {'-'};
t1 = cell2table(c, 'VariableNames', catnames);
t1 = convertvars(t1, catnames, 'categorical');

c = zeros(N, length(doublenames));
c(:) = nan;
t2 = array2table(c, 'VariableNames', doublenames);

conTable = [t1,t2]; % table creation



codec_list = struct;

codec_list(1).codec = {'opus'};
codec_list(1).bModes = [13.2,16.4,24.4,32,48];
codec_list(1).plcMode = {'noloss'};
codec_list(1).fer = [0.03,0.1,0.2];

codec_list(2).codec = {'evs'};
%codec_list(2).bModes = [48,32,24.4,16.4,13.2,9.6];
codec_list(2).bModes = [9,8,7,6,5,4];
codec_list(2).plcMode = {'noloss'};
%SWB

%amrwb=722.2
codec_list(3).codec = {'amrwb'};
%codec_list(3).bModes = [23.85,12.65,8.85];
codec_list(3).bModes = [9,3,2];
codec_list(3).plcMode = {'noloss'};
%WB

codec_list(4).codec = {'g722'};
codec_list(4).bModes = [1,3];
codec_list(4).plcMode = {'noloss'};
%WB


codec_list(5).codec = {'g279'};
codec_list(5).bModes = [32,24];
codec_list(5).plcMode = {'noloss'};
%WB



i=1; 

i = i +1;

%EVS-SWB

for iLoop = 1:6
   conTable.codec1(i) = codec_list(2).codec;
   conTable.bMode1(i) = codec_list(2).bModes(iLoop);
   conTable.plcMode1(i) = {'noloss'};
   conTable.filter(i)= {'bandpass'};
   conTable.bp_low(i) = 50;
   conTable.bp_high(i) =14000;
   i = i+1;
end



%G.722.2



for iLoop = 1:3
   conTable.codec1(i) = codec_list(3).codec;
   conTable.bMode1(i) = codec_list(3).bModes(iLoop);
   conTable.plcMode1(i) = {'noloss'};
   conTable.filter(i) = {'bandpass'};
   conTable.bp_low(i) = 100;
   conTable.bp_high(i) =7000;
   i = i+1;
end
%iLoop =1;

%G.722


for iLoop = 1:2
   conTable.codec1(i) = codec_list(4).codec;
   conTable.bMode1(i) = codec_list(4).bModes(iLoop);
   conTable.plcMode1(i) = {'noloss'};
   conTable.filter(i) = {'bandpass'};
   conTable.bp_low(i) = 100;
   conTable.bp_high(i) =7000;
   i = i+1;
end
%iLoop =1;


%condition 13
i = i+1;
%condition 14
i = i+1;


%Opus in Single operation

 for iLoop = 1:5
        conTable.codec1(i) = codec_list(1).codec;
         conTable.bMode1(i) = codec_list(1).bModes(iLoop);
         conTable.plcMode1(i) = {'noloss'};
         i = i+1;
 end



%---------------------------------------------------------------%
%--------------------Conditons B--------------------------------%

conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i)= {'evs'};
conTable.bMode1(i)= 8; %8 corresponds to 32kbit
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 32;
i = i+1;

%% Tandem  evs 24.4 bit and at  opus in 32 kbit
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i)= {'evs'};
conTable.bMode1(i)= 7; %24.4kbit
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 32;
i = i+1;

%% Tandem SWB evs 16.4 bit and at  opus 32kbit
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i)= {'evs'};
conTable.bMode1(i)= 6; %16.4kbit
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 32;
i = i+1;

%% Tandem SWB evs 13.2 bit and at  opus 32kbit
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i)= {'evs'};
conTable.bMode1(i)= 5; %13.2 kbit
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 32;
i = i+1;

%% Tandem SWB evs 9.6 bit and opus in 32kbit
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i)= {'evs'};
conTable.bMode1(i)= 4; %9.6 kbit
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 32;
i = i+1;

%% Tandem opus in 32kbit and SWB EVS 32bit 
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 32;
conTable.codec2(i)= {'evs'};
conTable.bMode2(i)= 8; %8 corresponds to 32kbit
i = i+1;

%% Tandem opus in 32 kbit and evs 24.4 bit 
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 32;
conTable.codec2(i)= {'evs'};
conTable.bMode2(i)= 7; % 24.4kbit
i = i+1;

%% Tandem opus in 32kbit and SWB evs 16.4 kbit 
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 32;
conTable.codec2(i)= {'evs'};
conTable.bMode2(i)= 6; %16.4kbit
i = i+1;

%% Tandemopus in 32kbit and SWB evs 13.2 kbit 
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 32;
conTable.codec2(i)= {'evs'};
conTable.bMode2(i)= 5; %5 13.2 kbit
i = i+1;

%% Tandemopus in 32kbit and SWB evs 9.6 kbit 
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 32;
conTable.codec2(i)= {'evs'};
conTable.bMode2(i)= 4; %9.6 kbit
i = i+1;


%OPUS@OPUS dual Tandem with 32kbit
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 32;
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 32;
i = i+1;

%OPUS@OPUS@OPUS tripple tandem
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 32;
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 32;
conTable.codec3(i) = {'opus'};
conTable.bMode3(i) = 32;
i = i+1;

%---------------%
%%Tandem references for opus at 13.2 kbit

% Tandem SWB evs 32bit and at  opus in 13.2kbit
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i)= {'evs'};
conTable.bMode1(i)= 8; %32kbit
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 13.2;
i = i+1;

% Tandem  evs 24.4 bit and at  opus in 13.2 kbit
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i)= {'evs'};
conTable.bMode1(i)= 7; % 24.4kbit
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 13.2;
i = i+1;

%%Tandem SWB evs 16.4 bit and at  opus 13.2kbit
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i)= {'evs'};
conTable.bMode1(i)= 6; %16.4kbit
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 13.2;
i = i+1;

% Tandem SWB evs 13.2 bit and at  opus 13.2kbit
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i)= {'evs'};
conTable.bMode1(i)= 5; %13.2 kbit
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 13.2;
i = i+1;

%% Tandem SWB evs 9.6 bit and opus in 13.2kbit
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i)= {'evs'};
conTable.bMode1(i)= 4; %9.6 kbit
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 13.2;
i = i+1;

%% Tandem opus in 13.2 kbit and SWB EVS 32bit 
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 13.2;
conTable.codec2(i)= {'evs'};
conTable.bMode2(i)= 8; %8 corresponds to 32kbit
i = i+1;

%% Tandem opus in 32 kbit and evs 24.4 bit 
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 13.2;
conTable.codec2(i)= {'evs'};
conTable.bMode2(i)= 7; % 24.4kbit
i = i+1;

%% Tandem opus in 13.2kbit and SWB evs 16.4 kbit 
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 13.2;
conTable.codec2(i)= {'evs'};
conTable.bMode2(i)= 6; %16.4kbit
i = i+1;

%% Tandem opus in 13.2kbit and SWB evs 13.2 kbit 
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 13.2;
conTable.codec2(i)= {'evs'};
conTable.bMode2(i)= 5; %5 13.2 kbit
i = i+1;

%% Tandem opus in 13.2kbit and SWB evs 9.6 kbit 
conTable.filter(i) = {'bandpass'};
conTable.bp_low(i) = 50;
conTable.bp_high(i) = 14000;
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 13.2;
conTable.codec2(i)= {'evs'};
conTable.bMode2(i)= 4; %9.6 kbit
i = i+1;

%OPUS@OPUS dual Tandem with 13.2 Kbit
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 13.2;
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 13.2;
i = i+1;

%OPUS@OPUS@OPUS tripple tandem with 13.2 Kbit
conTable.codec1(i) = {'opus'};
conTable.bMode1(i) = 13.2;
conTable.codec2(i) = {'opus'};
conTable.bMode2(i) = 13.2;
conTable.codec3(i) = {'opus'};
conTable.bMode3(i) = 13.2;
i = i+1;




%---------------------------------------------------------------%
%--------------------Conditons C--------------------------------%



for iLoop = 1:3
    for bLoop = 1:5
        conTable.codec1(i) = codec_list(1).codec;
        conTable.bMode1(i) = codec_list(1).bModes(bLoop);
        conTable.plcMode1(i) = {'bursty'};
        conTable.FER1(i) = codec_list(1).fer(iLoop);  
        i = i+1;
    end
    
end








conTable = conTable(1:i-1,:);
%% insert the conditions keys/Numbers in the condition table
conTable.con = (1:height(conTable))';

warning on
end
