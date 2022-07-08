
function AnimalDesc = getAnimalDesc(filepath)
    [filepath,foldername,t_] = fileparts(filepath);
    [filepath,foldername,t_] = fileparts(filepath);
    

    
    i = strfind(foldername,'_');
    if(isempty(i))
        error("Folder must be named as follows: <monkey name>_<ddMMyyyy>");
    end
    name = foldername(1:i-1);
    date = foldername(i+1:end);
    date = datetime(date,'InputFormat','ddMMyyyy');
   

    csv_path = [filepath,'/NHP_Overview.csv'];
    if(isfile(csv_path))
    
        opts = detectImportOptions(csv_path);
        opts = setvartype(opts,{'Number','Age',},'int32');
        opts  = setvartype(opts,{'Monkey','Sex','Species'},"string");
    
        csv = readtable(csv_path,opts);
    
    
        mask = (csv.Date == date) & (csv.Monkey == convertCharsToStrings(name));
    else
        mask = [0];
        csv = missing;
    end
    if(any(mask))
        if(sum(mask)~=1)
            error('The name and the date of the monkey is not unique');
        end
        AnimalDesc.number = num2str(csv.Number(mask));
        AnimalDesc.age = num2str(csv.Age(mask));
        AnimalDesc.name = name;
        AnimalDesc.sex = csv.Sex(mask);
        AnimalDesc.species = csv.Sex(mask);

        if(ismissing(AnimalDesc.sex))
            AnimalDesc.sex = '';
        end
        if(ismissing(AnimalDesc.species))
            AnimalDesc.species = '';
        end
    else
        AnimalDesc = DialogMonkey(name,date);
        %% add row to csv
        Row = table(date,str2num(AnimalDesc.number), ...
            convertCharsToStrings(AnimalDesc.name), ...
            str2num(AnimalDesc.age), ...
            convertCharsToStrings(AnimalDesc.sex), ...
            convertCharsToStrings(AnimalDesc.species), ...
            'VariableNames',{'Date','Number','Monkey','Age','Sex','Species'});

        if(ismissing(csv))
            csv = Row;
        else
            csv = [csv;Row];
        end
        writetable(csv,csv_path,"Delimiter",";");

    end

    csv_path = [filepath,'/Patcher_Overview.csv'];
    if(isfile(csv_path))
        opts = detectImportOptions(csv_path);
        opts  = setvartype(opts,{'Patcher','Amp','Monkey'},"string");
        csv = readtable(csv_path, opts);
        
        mask = (csv.Date == date) & (csv.Monkey == convertCharsToStrings(name));
    else
        mask = [0];
        csv = missing;
    end
    if(any(mask))
        AnimalDesc.Amp = convertStringsToChars(csv.Amp(mask));
        AnimalDesc.patcher = convertStringsToChars(csv.Patcher(mask));
        if(ismissing(AnimalDesc.Amp))
            AnimalDesc.Amp = '';
        end
        if(ismissing(AnimalDesc.patcher))
            AnimalDesc.patcher = '';
        end
    else
        AnimalDesc = DialogPatcher(AnimalDesc);
        Row = table(date, ...
        convertCharsToStrings(AnimalDesc.name), ...
        convertCharsToStrings(AnimalDesc.patcher), ...
        convertCharsToStrings(AnimalDesc.Amp), ...
        'VariableNames',{'Date','Monkey','Patcher','Amp'});
        if(ismissing(csv))
            csv = Row;
        else
            csv = [csv;Row];
        end
        writetable(csv,csv_path,"Delimiter",";");
    end


    
end


function AnimalDesc = DialogMonkey(name,date)
    width = 70;
    height = 1;
    num_lines = [height, width];
    defaultans = {'20','hsv'};
    title = ['General description for ', name ];
     % gets input for nwb file
   answer = inputdlg({'Monkey sequential number:', ...
             'Animal age:', 'Animal sex:',...
       'Animal species:'},title,num_lines);

   AnimalDesc.number = num2str(str2num(answer{1}), '%02.f');


   % capitalizes first letter
   % AnimalDesc.name = [upper(answer{4}(1)), lower(answer{4}(2:end))]; 
   AnimalDesc.name = name;
   AnimalDesc.age = num2str(answer{2}); %in year 
   AnimalDesc.sex = upper(answer{3});
   % capitalizes first letter
   AnimalDesc.species = [upper(answer{4}(1)), lower(answer{4}(2:end))]; 

end

function AnimalDesc = DialogPatcher(AnimalDesc)
    width = 70;
    height = 1;
    num_lines = [height, width];
    defaultans = {'20','hsv'};
    title = ['General description for ', AnimalDesc.name ];
     % gets input for nwb file
   answer = inputdlg({ 'Experimenter initials:',...
       'Amp (Heka or NPI):'},title,num_lines);

   AnimalDesc.patcher = upper(answer{1});
   AnimalDesc.Amp = upper(answer{2});

end