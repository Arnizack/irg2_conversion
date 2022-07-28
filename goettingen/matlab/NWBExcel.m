db_builder = DbBuilder("F:\uni\nebenjob\data\NPI Neuroanatomy - Raw Data CFS-Files");

jenifer_cells_db = db_builder.OpenCells("Jenifer");

datas = jenifer_cells_db.request('Monkey','Beatus');

data(1).date;
data(1).monkey;