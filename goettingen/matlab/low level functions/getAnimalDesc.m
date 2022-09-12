
function AnimalDesc = getAnimalDesc(monkey_db,patcher,monkey)
    data = monkey_db.request('Monkey',monkey);

    AnimalDesc = struct;
    AnimalDesc.number = data.Number;
    AnimalDesc.patcher = patcher;
    AnimalDesc.Amp = getAmpForPatcher(patcher);
    AnimalDesc.name = data.Monkey;
    AnimalDesc.age = data.Age;
    AnimalDesc.sex =  upper(data.Sex);
    AnimalDesc.species = data.Species;
    AnimalDesc.weight = data.Weight;
    AnimalDesc = AnimalDescPostprocess(AnimalDesc);


    
end

function Amp = getAmpForPatcher(patcher)
    patcher = lower(patcher);
    if(strcmp(patcher,'stefan'))
        Amp = 'HEKA';
    elseif(strcmp(patcher,'felix'))
        Amp = 'NPI';
    elseif(strcmp(patcher,'jenifer'))
        Amp = 'NPI';
    else
        Amp = 'HEKA';
    end
end

function AnimalDesc = AnimalDescPostprocess(AnimalDesc)
    AnimalDesc.sex = upper(AnimalDesc.sex);
    AnimalDesc.patcher = upper(AnimalDesc.patcher);
    AnimalDesc.Amp = upper(AnimalDesc.Amp);
    AnimalDesc.species = [upper(AnimalDesc.species(1)), lower(AnimalDesc.species(2:end))];
    AnimalDesc.weight = num2str(AnimalDesc.weight/1000);
end
