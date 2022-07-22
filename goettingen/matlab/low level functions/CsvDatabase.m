%Database DbOptions
%   csvTypes
%   csvNames
%   structTypes
%   structNames
%   deliminater
classdef CsvDatabase < handle
    %CSVDATABASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        datatable;
        csvTypes
        csvNames
        structTypes
        structNames
        deliminater;
        defaults;
        descriptions;
        path;
        importOptions;
        title;
    end
    
    methods
        function obj = CsvDatabase(path,csvTypes,csvNames,structTypes,structNames,defaults, descriptions, deliminater)
            %CSVDATABASE Construct an instance of this class
            %   - csvTypes are the types of the table in the csv file
            %   - csvNames are the names of the columns in the csv file
            %   - structTypes and structNames are types and names of the 
            %     struct returned by the request method
            %   - defaults are the default values to use when there is no 
            %     entry in the table
            %   - the descriptions describe each column in the csv file
            %     this is used for the input dialog

            obj.csvTypes = csvTypes;
            obj.csvNames = csvNames;
            obj.structTypes = structTypes;
            obj.structNames = structNames;
            obj.defaults = defaults;
            obj.deliminater=deliminater;
            
            obj.descriptions = descriptions;
            obj=obj.open(path);
            [~,filename,~] = fileparts(path);
            obj.title = filename;

        end
        
        function data = defaultStruct(obj)
            data = struct;
            for i =1:length(obj.structNames)
                value = obj.defaults{i};
                % dynamic field name
                data.(obj.structNames{i}) = value;
            end
        end


        function obj = open(obj,path)
            obj.path = path;
            obj.importOptions = detectImportOptions(path);
            obj.importOptions = setvartype(obj.importOptions,obj.csvNames,obj.csvTypes);
            obj.importOptions.Delimiter = {obj.deliminater};
            obj.datatable = readtable(obj.path,obj.importOptions);
            
        end

        

        function data = inputDialog(obj,defaultanswer)
            width = 70;
            height = 1;
            num_lines = [height,width];

            
            answers = inputdlg(obj.descriptions,obj.title,num_lines,defaultanswer);
            data = obj.defaultStruct();
            for i =1:length(obj.structNames)
                % dynamic field name
                if(~strcmp(answers{i},''))
                    data.(obj.structNames{i}) = convertstr(convertCharsToStrings(answers{i}),obj.structTypes{i});
                end
            end
        end

        function data = request(obj,structName,value)
            field_i = find(strcmp(obj.structNames,structName));
            field_n = length(obj.structTypes);
            
            columnName = obj.csvNames{field_i};
            value_type = obj.structTypes{field_i};
            
            csv_value = convertType(value,obj.structTypes{field_i},obj.csvTypes{field_i});
            
            row_i = find(obj.datatable.(columnName)==csv_value);

            if(length(row_i)==1)
                data = struct;
                for i=1:field_n
                    val = obj.datatable.(obj.csvNames{i})(row_i);
                    val = convertType(val,obj.csvTypes{i},obj.structTypes{i});
                    data.(obj.structNames{i}) = val;
                end
            elseif(isempty(row_i))

                defaultans = cell(1,length(obj.descriptions));
                [defaultans{:}] = deal('');
                defaultans{field_i} = convertType(value,value_type,'char');
                data = obj.inputDialog(defaultans);
                obj.push(data);
                
                

            else
                error(['the column ', columnName, ' has multiple rows with the value', csv_value, ...
                    '. The value shell be unique.'])
            end

        end

        function obj = push(obj,data)
            
            field_n = length(obj.structTypes);
            row = cell(1,field_n);
            for i=1:field_n
                val =  data.(obj.structNames{i});
                val = convertType(val,obj.structTypes{i},obj.csvTypes{i});
                row{i} = val;
            end
            obj.datatable = [obj.datatable;row];
        end

        function save(obj)
            writetable(obj.datatable,obj.path,'Delimiter',obj.deliminater);
        end

         
    end
end

function b = isTypeNameNumeric(typename)
    b = strcmp(typename,'int8')||strcmp(typename,'int16') ...
        ||strcmp(typename,'int32')||strcmp(typename,'int64')...
        ||strcmp(typename,'uint8')||strcmp(typename,'uint16') ...
        ||strcmp(typename,'uint32')||strcmp(typename,'uint64')...
        ||strcmp(typename,'double')||strcmp(typename,'single');

end

function value = convertstr(str,typename)
    if(isTypeNameNumeric(typename))
        value = cast(str2num(str),typename);
    elseif(strcmp(typename,'datetime'))
        value = datetime(str,'InputFormat','dd.MM.yyyy');
    elseif(strcmp(typename,'char'))
        value = convertStringsToChars(str);
    else
        value = str;
    end
end

function value = convertType(value,value_type,dst_type)
    % converts a value of type value_type to a value of type dst_type
    if(strcmp(value_type,dst_type))
        value = value;
    elseif(strcmp(value_type,'string'))
        value = convertstr(value,dst_type);
    elseif(strcmp(value_type,'char'))
        value = convertstr(convertCharsToStrings(value),dst_type);
    elseif(isTypeNameNumeric(value_type) && strcmp(dst_type,'string'))
        value = num2str(value);
    elseif(isTypeNameNumeric(value_type) && strcmp(dst_type,'char'))
        value = convertstr(num2str(value));
    elseif(strcmp(value_type,'datetime') && strcmp(dst_type,'char'))
        value = convertStringsToChars(datestr(value,'dd.MM.yyyy'));

    elseif(strcmp(value_type,'datetime') && strcmp(dst_type,'string'))
        value = datestr(value,'dd.MM.yyyy');
    else
        value = cast(value,dst_type);
    end


end

