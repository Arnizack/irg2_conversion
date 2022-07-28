



% for debugging
mainfolder = 'F:\uni\nebenjob\data\NPI Neuroanatomy - Raw Data CFS-Files';
outputfolder = 'F:\uni\nebenjob\output\cfs';

mainfolder = uigetdir('','Select main folder containing all monkey folders');
outputfolder = uigetdir(mainfolder,'Select output folder'); 


db_builder = DbBuilder(mainfolder);

monkey_db = db_builder.OpenMonkeys();

listing = dir(mainfolder);
listing = listing([listing.isdir]);
mask = contains({listing(:).name},'_');
monkeyFolders = {listing([mask]).name};


for monkey_idx=1:length(monkeyFolders)
    monkeyFolder = monkeyFolders{monkey_idx};
    monkeyName = extractBefore(monkeyFolder,'_');
    
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
        
            nwb = cfsFiles2NWB(pathList,desc,cellTag);
        
            nwb_savepath = fullfile([outputfolder , '\',nwb.identifier '.nwb']);
            nwbExport(nwb, nwb_savepath);
        
        end
    end
end



