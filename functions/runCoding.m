function [deg, ref, errFlag, actualErrRate, t, fs, bitrate, optionsOutput] = runCoding(filePath, codec, plcMode, optionsInput, ii, varargin)
%runCoding
% Author:
%   Gabriel Mittag, Quality and Usability Labs
%
% Date: 10.07.2017

%% ini

% execute runPLC in folder which contains this function
path = strrep(which(mfilename),[mfilename '.m'],'');
oldFolder = cd(path);

%% input handling

% options
options.bMode = -1; % leave empty to use codec specific "standard" value
options.dtx = 1; % dtx on (1) / off (0)
options.maxBand = 'SWB'; % evs bandwidth
options.CA = 0; % evs channel aware mode
options.verbose = 0; % display codec verbose
options.tLossLocation = -1;
options.errorRate = -1;
options.nLostFrames = -1;
options.preSkip = -1;
options.useConceal = -1;
options.burstR = -1; % burstyness for thilos packet loss pattern function

fn = fieldnames(optionsInput);
for i=1:length(fn)
    if isfield(options, fn{i})
        options.(fn{i}) = optionsInput.(fn{i});
    end
end

%% handling of optional input arguments
% create input parser object
p = inputParser;
addParameter(p, 'doPlot', false, @islogical);

% parse input arguments
parserStart = 1;
p.parse(varargin{parserStart:end});

% copy input arguments to variables
doPlot = p.Results.doPlot;

% if ~( strcmp(plcMode, '<undefined>') || strcmp(plcMode, '') || strcmp(plcMode, 'location') || strcmp(plcMode, 'noloss') || strcmp(plcMode, 'pattern') || strcmp(plcMode, 'bursty') || strcmp(plcMode, 'random') )
%     error('plcMode not available');
% end   

%% codec processing
if strcmp(codec, 'amrnb')
    [deg, ref, errFlag, actualErrRate, fs, t, bitrate, optionsOutput] = processAMRNB_v03(filePath, plcMode, options, ii);
elseif strcmp(codec, 'amrwb')
    [deg, ref, errFlag, actualErrRate, fs, t, bitrate, optionsOutput] = processAMRWB_v03(filePath, plcMode, options, ii);
elseif strcmp(codec, 'evs')
    [deg, ref, errFlag, actualErrRate, fs, t, bitrate, optionsOutput] = processEVS_v03(filePath, plcMode, options, ii);
elseif strcmp(codec, 'opus')
    [deg, ref, errFlag, actualErrRate, fs, t, bitrate, optionsOutput] = processOPUS_v03(filePath, plcMode, options, ii);
elseif strcmp(codec, 'g722')
    [deg, ref, errFlag, actualErrRate, fs, t, bitrate, optionsOutput] = processG722_v03(filePath, plcMode, options, ii);
elseif strcmp(codec, 'g711')
    [deg, ref, errFlag, actualErrRate, fs, t, bitrate, optionsOutput] = processG711_v03(filePath, plcMode, options, ii);
elseif strcmp(codec, 'skip') || strcmp(codec, '<undefined>') || strcmp(codec, '-')
    [ref, fs] = audioread(filePath);
    deg = ref;
    errFlag = zeros(length(deg),1);
    actualErrRate = [];
    t = [];
    bitrate = [];
    optionsOutput = [];
else
    error('Specify codec!')
end


%%
if doPlot
    clf
    plot(t, ref)
    hold on
    plot(t, deg)
    plot(t, errFlag.*max(ref).*0.9)
    hold off
%     sound(deg, fs)
    axis([-inf inf -max(abs([ref(:);deg(:)])) max(abs([ref(:);deg(:)]))])
end

%% delete tmp files and go back to folder
cd(oldFolder);

end




