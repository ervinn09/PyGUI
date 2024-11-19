function tLoop = makeFilelist(t, srcFolder)

nCons = size(t,1);

shuffle_filelist = false;

%%
listing = dir( fullfile(srcFolder, '*.wav') );
nFiles = size(listing,1);

%%
filelist = cell(2,1);
for i = 1:size(listing,1)
    filelist(i) = {listing(i).name}; 
end

if shuffle_filelist
    filelist = filelist(randperm(numel(filelist)));
end
%%
warning off
ii = 1;
iiFile = 1;
tLoop = table;
for iCon = 1:nCons
    
    for iFile = 1:nFiles
        
        filename = filelist{iFile};
        tLoop.filename(ii) = {filename};
        tLoop.con(ii) = iCon;
        ii = ii+1;
        
        
%         filename = filelist{iiFile};
%         tLoop.filename(ii) = {filename};
%         tLoop.con(ii) = iCon;
%         ii = ii+1;
%         
%         iiFile = iiFile+1;
%         if iiFile > size(listing,1)
%             if shuffle_filelist
%                 filelist = filelist(randperm(numel(filelist)));
%             end
%             iiFile = 1;
%         end
        
    end
end
warning on
end