classdef DbBuilder
    %DBBUILDER Summary of this class goes here
    %   Detailed explanation goes here
    
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

            csvNames   ={'Date',    'Monkey','Cell' , 'Patcher Cell name','Depth (my m)','R pipette','R access cell start','R access cell end','R membrane (tot) start','R membrane (tot) end','VR Start','VR  End','VM'   ,'Holding current (pA)','Capacitance dial','bridge balance (Mohm)','Location','Area'  ,'Layer' ,'Comment'};
            csvTypes   ={'datetime','string','int32','string'            ,'int32'       ,'double'   ,'int32'              ,'int32'            ,'int32'                 ,'int32'               ,'int32'   ,'int32'  ,'int32','int32'               ,'double'          ,'double'               ,'string'  ,'string','string','string' };
            structNames={'data','monkey'    ,'cell' ,'patcherCellName'   ,'depth'       ,'R_pipette','R_access_cell_start','R_access_cell_end','R_membrane_start'      ,'R_membrance_end'     ,'vr_start','vr_end' ,'vm'   ,'holding_current'     ,'capacitance_dial','bride_balance'        ,'location','area'  ,'layer' ,'comment'};
            structTypes=cellsCsvTypes;
            
            defaults={datetime('today'),''       ,-1     ,''                  ,-1            ,-1.0       ,-1                   ,-1                 ,-1                      ,-1                    ,-1        ,-1       ,-1     ,-1                    ,-1.0               ,-1.0                  ,''        ,''      ,''      ,''       };
            
            db = CsvDatabase(path,csvTypes,csvNames,structTypes,structNames,defaults,cellsCsvNames,';');

        end

        function db = OpenMonkeys(obj)
            path = [obj.dir,'/','Monkeys.csv'];
            db = CsvDatabase(path, ...
                            {'string'         ,'int32','datetime'        ,'int32','string','string'}, ...
                            {'Monkey'         ,'Number','Date'           ,'Age','Sex'     ,'Species'}, ...
                            {'char'           ,'int32','datetime'        ,'int32','char'  ,'char'},...
                            {'Monkey'         ,'Number','Date'           ,'Age','Sex'     ,'Species'}, ...
                            {''               ,''      ,datetime("today"),''     ,''      ,''},...
                            {'Monkey'         ,'Number','Date'           ,'Age','Sex'     ,'Species'},...
                            ';'...
                            );
        end
    end
end

