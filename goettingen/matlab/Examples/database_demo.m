
db = CsvDatabase('F:\uni\nebenjob\data\NPI Neuroanatomy - Raw Data CFS-Files\Monkeys.csv', ...
    {'string'         ,'int32','datetime'        ,'int32'   ,'string','string'}, ...
    {'char'           ,'int32','datetime'        ,'int32'   ,'char'  ,'char'},...
    {'Monkey'         ,'Number','Date'           ,'Age'     ,'Sex'     ,'Species'}, ...
    ';'...
    );


data1 = db.request('Monkey','Eisenherz');


data2 = db.request('Age',3,'Sex','M');

datas = db.request('Sex','M');

fulltable = db.request();

data3 = db.requestMasked(db.table.Monkey=="Eisenherz");




