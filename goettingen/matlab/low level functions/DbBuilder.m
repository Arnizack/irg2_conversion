classdef DbBuilder
    %Constructs from the directory, where the csv files are, the csv
    %databases
    
    properties
        dir;
    end
    
    methods
        function obj = DbBuilder(directory)
            obj.dir = directory;
        end
        
        function db = OpenCells(obj,patcher)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            path = [obj.dir,'/',patcher,'_Cells.csv'];

            csvTypes   ={'datetime','string','int32','string'            ,'int32'       ,'double'   ,'int32'              ,'int32'            ,'int32'                 ,'int32'               ,'int32'   ,'int32'  ,'int32','int32'               ,'double'          ,'double'               ,'string'  ,'string','string','string' };
            structNames={'Date','Monkey'    ,'Cell' ,'PatcherCellName'   ,'Depth'       ,'R_pipette','R_access_cell_start','R_access_cell_end','R_membrane_start'      ,'R_membrance_end'     ,'VR_start','VR_end' ,'VM'   ,'Holding_current'     ,'Capacitance_dial','Bride_balance'        ,'Location','Area'  ,'Layer' ,'Comment'};
            structTypes=csvTypes;
            
            
            db = CsvDatabase(path,csvTypes,structTypes,structNames,';');

        end

        function db = OpenMonkeys(obj)
            path = [obj.dir,'/','Monkeys.csv'];
            db = CsvDatabase(path, ...
                            {'string'         ,'int32','datetime'        ,'int32','string','string'}, ...
                            {'char'           ,'int32','datetime'        ,'int32','char'  ,'char'},...
                            {'Monkey'         ,'Number','Date'           ,'Age','Sex'     ,'Species'}, ...
                            ';'...
                            );
        end
    end
end

