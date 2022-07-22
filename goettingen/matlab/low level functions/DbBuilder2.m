
function [FelixCellDb,JeniferCellDb,StefanCellDb,MonkeyDb] = CreateDbs(directory)
%CREATEDBS Summary of this function goes here
%   Detailed explanation goes here



end

function db = OpenCells(path)

cellsCsvNames   ={'Date',    'Monkey','Cell' , 'Patcher Cell name','Depth (my m)','R pipette','R access cell start','R access cell end','R membrane (tot) start','R membrane (tot) end','VR Start','VR  End','VM'   ,'Holding current (pA)','Capacitance dial','bridge balance (Mohm)','Location','Area'  ,'Layer' ,'Comment'};
cellsCsvTypes   ={'datetime','string','int32','string'            ,'int32'       ,'double'   ,'int32'              ,'int32'            ,'int32'                 ,'int32'               ,'int32'   ,'int32'  ,'int32','int32'               ,'double'          ,'double'               ,'string'  ,'string','string','string' };
cellsStructNames={'data','monkey'    ,'cell' ,'patcherCellName'   ,'depth'       ,'R_pipette','R_access_cell_start','R_access_cell_end','R_membrane_start'      ,'R_membrance_end'     ,'vr_start','vr_end' ,'vm'   ,'holding_current'     ,'capacitance_dial','bride_balance'        ,'location','area'  ,'layer' ,'comment'};
csllsStructTypes=cellsCsvTypes;

defaults={datetime('today'),''       ,-1     ,''                  ,-1            ,-1.0       ,-1                   ,-1                 ,-1                      ,-1                    ,-1        ,-1       ,-1     ,-1                    ,-1.0               ,-1.0                  ,''        ,''      ,''      ,''       };

db = CsvDatabase(path,cellsCsvTypes,cellsCsvNames,cellsStructTypes,cellsStructNames,defaults,cellsCsvNames,';');

end

function db = 
