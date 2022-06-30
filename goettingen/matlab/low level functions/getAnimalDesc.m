
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

    csv = readtable(csv_path, 'Delimiter', ';');


    mask = (csv.Date == date) & (csv.Monkey == convertCharsToStrings(name));
    if(any(mask))
        if(sum(mask)~=1)
            error('The name and the date of the monkey is not unique');
        end
        AnimalDesc.number = num2str(csv.Number(mask));
        AnimalDesc.age = num2str(csv.Age(mask));
        AnimalDesc.name = name;
        AnimalDesc.patcher = num2str(csv.Patcher(mask));
        AnimalDesc.Amp = csv.Amp(mask);
        AnimalDesc.sex = csv.Sex(mask);
        AnimalDesc.species = csv.Sex(mask);

        if(isnan(AnimalDesc.patcher))
            AnimalDesc.patcher = '';
        end
        if(isnan(AnimalDesc.Amp))
            AnimalDesc.Amp = '';
        end
        if(isnan(AnimalDesc.sex))
            AnimalDesc.sex = '';
        end
        if(isnan(AnimalDesc.species))
            AnimalDesc.species = '';
        end
    else
        AnimalDesc = Dialog(name,date);
        
    end


    

    
end


function AnimalDesc = Dialog(name,date)
    width = 70;
    height = 1;
    num_lines = [height, width];
    defaultans = {'20','hsv'};
    title = ['General description for ', name ];
     % gets input for nwb file
   answer = inputdlg({'Monkey sequential number:', 'Experimenter initials:',...
       'Amp (Heka or NPI):', 'Animal age:', 'Animal sex:',...
       'Animal species:'},title,num_lines);

   AnimalDesc.number = num2str(str2num(answer{1}), '%02.f');
   AnimalDesc.patcher = upper(answer{2});
   AnimalDesc.Amp = upper(answer{3});
   % capitalizes first letter
   % AnimalDesc.name = [upper(answer{4}(1)), lower(answer{4}(2:end))]; 
   AnimalDesc.name = name;
   AnimalDesc.age = [num2str(answer{4}), ' y'];
   AnimalDesc.sex = upper(answer{5});
   % capitalizes first letter
   AnimalDesc.species = [upper(answer{6}(1)), lower(answer{6}(2:end))]; 

end