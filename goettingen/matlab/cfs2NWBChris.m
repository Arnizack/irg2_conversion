



% for debugging
mainfolder = 'F:\uni\nebenjob\data\NPI Neuroanatomy - Raw Data CFS-Files';
outputfolder = 'F:\uni\nebenjob\output\cfs';

mainfolder = uigetdir('E:\Data\MonkeyData\Monkeys','Select main folder containing all monkey folders');
outputfolder = uigetdir(mainfolder,'Select output folder'); 


db_builder = DbBuilder(mainfolder);

monkey_db = db_builder.OpenMonkeys();

listing = dir(mainfolder);
listing = listing([listing.isdir]);
%Hier Maske für den Unterstrich bei dem Ordnernamen <Monkey Name>_<Datum>
% mask = contains({listing(:).name},'_');
% monkeyFolders = {listing([mask]).name};
listing = listing(~ismember({listing(:).name},{'.','..'})); %NEcessary without mask
monkeyFolders = {listing.name};

for monkey_idx=1:length(monkeyFolders)
    monkeyFolder = monkeyFolders{monkey_idx};
    %monkeyName = extractBefore(monkeyFolder,'_'); % for mask
    monkeyName = monkeyFolder; % added without mask
    
    monkeyDirectory = [mainfolder,'/',monkeyFolder];

    listing = dir(monkeyDirectory);
    listing = listing([listing.isdir]);
    mask = contains({listing(:).name},'.');
    patcherFolders = {listing(~mask).name};

    for patcher_idx = 1:length(patcherFolders)

        patcher = patcherFolders{patcher_idx};
        desc = getAnimalDesc(monkey_db,patcher,monkeyName);

        patcherDirectory = [monkeyDirectory,'/',patcher];
        
        cellList = getCellNames(patcherDirectory);
        

        for n = 1:length(cellList)
            cellID = cellList(n).name;
            disp(cellID);
            cellTag = num2str(n, '%02.f');
            fileList = dir([patcherDirectory,'/',cellList(n,1).name,'/*.cfs']);
        
            pathList = strcat({fileList.folder},{'/'},{fileList.name});
            
            pathList = string(pathList);
         if isempty(fileList)
             break
         end
            nwb = cfsFiles2NWB(pathList,desc,cellTag);
        
            nwb_savepath = fullfile([outputfolder , '\',nwb.identifier '.nwb']);
            nwbExport(nwb, nwb_savepath);
        
        end
    end
end



