db_builder = DbBuilder('F:\uni\nebenjob\data\NPI Neuroanatomy - Raw Data CFS-Files');

db=db_builder.OpenCells('Jenifer');

data = db.request('Date',datetime('20.04.2022','format','dd.MM.yyyy'),...
                  'Monkey','Beatus', ...
                  'Depth',0);

