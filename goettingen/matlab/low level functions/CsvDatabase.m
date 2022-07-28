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
        table;
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
        function obj = CsvDatabase(path,csvTypes,structTypes,structNames, deliminater)
            %CSVDATABASE Construct an instance of this class
            %   - csvTypes are the types of the table in the csv file.
            %     the csvTypes shell not contain char. Use string instead.
            %   - structTypes and structNames are types and names of the 
            %     struct returned by the request method

            obj.csvTypes = csvTypes;
            
            obj.structTypes = structTypes;
            obj.structNames = structNames;
            obj.deliminater=deliminater;
            
            obj=obj.open(path);
            [~,filename,~] = fileparts(path);
            obj.title = filename;

        end
        


        function obj = open(obj,path)
            obj.path = path;
            obj.importOptions = detectImportOptions(path);
            obj.csvNames = obj.importOptions.VariableNames;
            obj.importOptions = setvartype(obj.importOptions,obj.csvNames,obj.csvTypes);
            obj.importOptions.Delimiter = {obj.deliminater};
            obj.table = readtable(obj.path,obj.importOptions);
            
        end

        

     

        function datas = request(obj,varargin)
            %The length of the varargin must be even
            %varargin should be column_1,value_1, column_2,value_2, ...
            %The result will be all rows of the csv where 
            %csv.column_1 == value_1 && csv.column_2 == value_2 && ...
            %EG:
            %
            %CSV:
            %   Sex, Age, Name
            %   M  , 3  , Peter
            %   M  , 2  , Olaf
            %   F  , 3  , Esther
            %   F  , 1  , Elisa
            %   M  , 3  , Hans
            %
            %Struct
            %   sex
            %   age
            %   name
            %
            % db.request('sex','M','age',3)
            %   struct(sex: 'M', age: 3, name: 'Peter')
            %   struct(sex: 'M', age: 3, name: 'Hans')
            %
            %
            %db.request('Sex','M','Age',3) would be an error because 
            % 'Sex' is not a field name of the struct
            


            mask = obj.getMask(varargin{:});
            datas=obj.requestMasked(mask);
            
        end

        function mask = getMask(obj,varargin)
            if(mod(length(varargin),2)~=0)
                error("An even number of arguments musst be provided");
            end
            mask = zeros(height(obj.table),1);
            mask(:) = true;
            for argument_i=1:2:length(varargin)
                structName = varargin{argument_i};
                structValue = varargin{argument_i+1};

                field_i = find(strcmp(obj.structNames,structName));

                columnName = obj.csvNames{field_i};
                
                csv_value = convertType(structValue,obj.structTypes{field_i},obj.csvTypes{field_i});

                mask = mask & obj.table.(columnName)==csv_value;
            end
        end

        function datas = requestMasked(obj,mask)
            row_ids = find(mask);
            field_n = length(obj.structTypes);

            datas = struct([]);

            for j=1:length(row_ids)
                row_i = row_ids(j);
                
                for i=1:field_n
                    val = obj.table.(obj.csvNames{i})(row_i);
                    val = convertType(val,obj.csvTypes{i},obj.structTypes{i});
                    datas(j).(obj.structNames{i}) = val;
                end
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
            obj.table = [obj.table;row];
        end

        function save(obj)
            writetable(obj.table,obj.path,'Delimiter',obj.deliminater);
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

