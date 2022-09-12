%CfsFilePaths is a list of paths to cfs files
function nwb = cfsFiles2NWB(CfsFilePaths,AnimalDesc,cellTag)

    nwbIdentifier = getNwbIdentifier(AnimalDesc,cellTag);
    nwb = initNwb(nwbIdentifier,AnimalDesc);

    sweepAmps = [];
    stimDescs=[];
    sweepNumberEnds=[];
    
    sweepCount = 0;

    cellStartTime = -1;

    ic_elec = -1;

    for f = 1:length(CfsFilePaths)
        file_path = CfsFilePaths(f);
        cfsFile = readCfsCustom(file_path);

        if f==1 
            cellStartTime = datetime([cfsFile.param.fDate(1:end-3), ...
                '/20', cfsFile.param.fDate(end-1:end),' ', cfsFile.param.fTime]...
             ,'TimeZone', 'local');
        end
        ic_elec_name = loadIcElecName([file_path(1:end - 3), 'json']);
    
        [tmpSweepAmps,stimDesc,sweepCount,ic_elec,nwb] = cfsFile2NWB(cfsFile, nwb,ic_elec_name, sweepCount, cellStartTime);

        sweepAmps= [sweepAmps,tmpSweepAmps];
        stimDescs=[stimDescs,stimDesc];
        sweepNumberEnds = [sweepNumberEnds,sweepCount];
        
        
    end

    if (sweepCount>5)
        ic_rec_table = createIcRecTable(sweepCount, ic_elec,sweepAmps,stimDescs,sweepNumberEnds);
        nwb.general_intracellular_ephys_intracellular_recordings = ic_rec_table;
    end

end

function Protocols = createProtocols(stimDescriptions,sweepNumberEnds)
    Protocols = cell.empty;
    sweepNumber = 1;
    for file_i = 1:length(stimDescriptions)
        stimDesc = stimDescriptions(file_i);
        
        protocol = {'Unknown'};
        if(strcmp(stimDesc.name,'Long Pulse'))
            protocol = {'LP'};
        elseif(strcmp(stimDesc.name,'Short Pulse'))
            protocol = {'SP'};
        elseif(strcmp(stimDesc.name,'Ramp'))
            protocol = {'Ramp'};
        end
        
        sweepNumberStart = 1;
        if(file_i>1)
            sweepNumberStart = sweepNumberEnds(file_i-1)+1;
        end
        for tmp_ = sweepNumberStart:sweepNumberEnds(file_i)
            Protocols(sweepNumber) = protocol;
            sweepNumber=sweepNumber+1; 
        end
    end

end

function [sweep_series_objects_ch1,sweep_series_objects_ch2] = createSweepSeries(sweepNumberEnds)
    sweep_series_objects_ch1 = [];
    sweep_series_objects_ch2 = [];
    sweepNumber = 0;
    for file_i = 1:length(sweepNumberEnds)
        sweepNumberStart = 1;
        if(file_i>1)
            sweepNumberStart = sweepNumberEnds(file_i-1)+1;
        end
        for tmp_ = sweepNumberStart:sweepNumberEnds(file_i)
            sweep_ch2 = types.untyped.ObjectView(['/acquisition/', 'Sweep_', num2str(sweepNumber)]);
            sweep_ch1 = types.untyped.ObjectView(['/stimulus/presentation/', 'Sweep_', num2str(sweepNumber)]);
            sweep_series_objects_ch1 = [sweep_series_objects_ch1, sweep_ch1]; 
            sweep_series_objects_ch2 = [sweep_series_objects_ch2, sweep_ch2];
            sweepNumber=sweepNumber+1; 
        end
    end
end

function ic_rec_table = createIcRecTable(sweepCount, ...
        ic_elec, ...
        SweepAmps,...
        stimDescriptions,...
        sweepNumberEnds... %the end index of the sweepNumber for the individual files
)

    

    % Add protocol type as column of electrodes table

    Protocols = createProtocols(stimDescriptions,sweepNumberEnds);

    [sweep_series_objects_ch1,sweep_series_objects_ch2] = createSweepSeries(sweepNumberEnds);

    stimOn=[];
    stimCount = [];
    
    for file_i = 1:length(stimDescriptions)
        stimDesc = stimDescriptions(file_i);
        sweepNumberStart = 1;
        if(file_i>1)
            sweepNumberStart = sweepNumberEnds(file_i-1)+1;
        end
        for tmp_ = sweepNumberStart:sweepNumberEnds(file_i)
            stimOn = [stimOn,stimDesc.start_idx];
            stimCount = [stimCount,stimDesc.count];
        end
    end



    stimOn(isnan(stimOn)) = 0;
    SweepAmps(isnan(SweepAmps)) = 0;

    ic_rec_table = types.core.IntracellularRecordingsTable( ...
        'categories', {'electrodes', 'stimuli', 'responses'}, ...
        'colnames', {'recordings_tag'}, ...
        'description', [ ...
            'A table to group together a stimulus and response from a single ', ...
            'electrode and a single simultaneous recording and for storing ', ...
        'metadata about the intracellular recording.'], ...
        'id', types.hdmf_common.ElementIdentifiers( ...
        'data', int64([0:sweepCount - 1]) ...
    ) ...
    );

    ic_rec_table.electrodes = types.core.IntracellularElectrodesTable( ...
        'description', 'Table for storing intracellular electrode related metadata.', ...
        'colnames', {'electrode'}, ...
        'id', types.hdmf_common.ElementIdentifiers( ...
        'data', int64([0:sweepCount - 1]) ...
    ), ...
        'electrode', types.hdmf_common.VectorData( ...
        'data', repmat(types.untyped.ObjectView(ic_elec), sweepCount, 1), ...
        'description', 'Column for storing the reference to the intracellular electrode' ...
    ) ...
    );

    ic_rec_table.stimuli = types.core.IntracellularStimuliTable( ...
        'description', 'Table for storing intracellular stimulus related metadata.', ...
        'colnames', {'stimulus'}, ...
        'id', types.hdmf_common.ElementIdentifiers( ...
        'data', int64([0:sweepCount - 1]) ...
    ), ...
        'stimulus', types.core.TimeSeriesReferenceVectorData( ...
        'description', 'Column storing the reference to the recorded stimulus for the recording (rows)', ...
        'data', struct( ...
        'idx_start', [stimOn(stimOn ~= 0)'], ...
        'count', [stimCount(stimCount ~= 0)], ...
        'timeseries', [sweep_series_objects_ch1] ...
    ) ...
    ) ...
    );
    ic_rec_table.responses = types.core.IntracellularResponsesTable( ...
        'description', 'Table for storing intracellular response related metadata.', ...
        'colnames', {'response'}, ...
        'id', types.hdmf_common.ElementIdentifiers( ...
        'data', int64([0:sweepCount - 1]) ...
    ), ...
        'response', types.core.TimeSeriesReferenceVectorData( ...
        'description', 'Column storing the reference to the recorded response for the recording (rows)', ...
        'data', struct( ...
        'idx_start', [stimOn'], ...
        'count', [stimCount], ...
        'timeseries', [sweep_series_objects_ch2] ...
    ) ...
    ) ...
    );



    ic_rec_table.categories = [ic_rec_table.categories, {'protocol_type'}];
    ic_rec_table.dynamictable.set( ...
        'protocol_type', types.hdmf_common.DynamicTable( ...
        'description', 'category table for lab-specific recording metadata', ...
        'colnames', {'label'}, ...
        'id', types.hdmf_common.ElementIdentifiers( ...
        'data', int64([0:sweepCount - 2]) ...
    ), ...
        'label', types.hdmf_common.VectorData( ...
        'data', Protocols, ...
        'description', 'Abbreviated Stimulus type: LP= Long Pulse, SP= Short Pulse' ...
    ) ...
    ) ...
    );

    % Add Current amplitude as column of stimulus table
    ic_rec_table.stimuli.colnames = [ic_rec_table.stimuli.colnames {'current_amplitude'}];
    ic_rec_table.stimuli.vectordata.set('current_amplitude', types.hdmf_common.VectorData( ...
        'data', [SweepAmps'], ...
        'description', 'Current amplitude of injected square pulse' ...
    ) ...
    );

end


%% data = 1d array
%%struct StimDescription:
%%      name
%%      start_idx (was called on in early versions)
%%      end_idx (was called off in early versions)
%%      duration
function StimDescription = createStimDescription(data,x_scale,y_scale)
    StimDescription = struct;
    [start_i,end_i] = GetStimulusEpoch(data);

    duration = (end_i-start_i) * x_scale;



    %%Die gesamten daten sind 8 Sekunden lang
    %% Wolle immer mit 50 KHz sampeln x_scale 
    if (round(duration,0) == 1) && (length(data) == 400000) % length check needed to prevent misslabeling of capacitance recordings as LP
        StimDescription.name='Long Pulse';

    elseif round(duration,3) == 0.003
        StimDescription.name='Short Pulse';
    % 1,2 sind die Werte wenn das Signal zu noisy ist
    elseif (round(duration,3) ~= 1)  && (~(start_i==1 && end_i==2))
        start_i = GetRampStimulusEpoch(data,end_i,x_scale,y_scale);
        StimDescription.name='Ramp';
    else
        disp(['Unknown stimulus type with duration of '... includes ramp problem
        , num2str(round(duration,3)), ' s']);
        StimDescription.name='Unknown';
    end


    StimDescription.start_idx = start_i;
    StimDescription.end_idx = end_i;
    StimDescription.count = (end_i-start_i);

end

function amp = getStimAmplitude(data,stimDesc,xScale) % Stefan: Added xScale for bias calculation
    stim_on_data = data(stimDesc.start_idx:stimDesc.end_idx);
    %amp = round(mean(stim_on_data),-1); % orginal
    
    %added the following to correctly calculate the actual stimulus
    %amplitude with respect to the holding current
    
    start_test_pulse = stimDesc.start_idx-(0.45/xScale);
    end_test_pulse = stimDesc.start_idx;
    if start_test_pulse < 0
         % no testpulse or unknown protocols; pA
        start_test_pulse = 1;
    else
        start_test_pulse = ceil(start_test_pulse);
         % with test pulse; pA; ceil because matlab throws an error otherwise
    end

    bias = mean(data(start_test_pulse:end_test_pulse));

    
    
    amp = round(mean(stim_on_data)-bias,-1); %Substract bias to show stimulus relative to holding
end


%%a: Spannungs Kanal
%%b: Strom Kanal
function nwb = nwbAddSweep(nwb,sweep_number,electrode,stimulus_name,fTime,...
                     stimDesc,...
                     data_voltage,y_unit_voltage,x_scale_voltage,...
                     data_current,y_unit_current,x_scale_current)
    start_time_rate_voltage = round(1./x_scale_voltage);
    start_time_rate_current = round(1./x_scale_current);
    
     ccs = types.core.CurrentClampStimulusSeries( ...
            'electrode', electrode, ...
            'gain', NaN, ...
            'stimulus_description', stimulus_name, ...
            'data_unit', y_unit_current, ...
            'data', data_current, ... 
            'sweep_number', sweep_number,...
            'starting_time', seconds(duration(fTime)),...
            'starting_time_rate', start_time_rate_current...
            );
        
    nwb.stimulus_presentation.set(['Sweep_', num2str(sweep_number)], ccs);    
    

    start_test_pulse = stimDesc.start_idx-(0.45/x_scale_current);
    end_test_pulse = stimDesc.start_idx;
    if start_test_pulse < 0
         % no testpulse or unknown protocols; pA
        start_test_pulse = 1;
    else
        start_test_pulse = ceil(start_test_pulse);
         % with test pulse; pA; ceil because matlab throws an error otherwise
    end

    bias = mean(data_current(start_test_pulse:end_test_pulse));

    %%bias current = Stromspur vorm Testpuls zum richtigen Puls
    nwb.acquisition.set(['Sweep_', num2str(sweep_number)], ...
        types.core.CurrentClampSeries( ...
            'bias_current', bias, ... % Unit: Amp
            'bridge_balance', [], ... % Unit: Ohm
            'capacitance_compensation', [], ... % Unit: Farad
            'data', data_voltage, ...
            'data_unit', y_unit_voltage, ...
            'electrode', electrode, ...
            'stimulus_description', stimulus_name, ...   
            'sweep_number', sweep_number,...
            'starting_time', seconds(duration(fTime)),...
            'starting_time_rate', start_time_rate_voltage...
                ));
end



function ic_elec_name = loadIcElecName(json_path)
    %% load JSON from MCC get settings files if present
    if isfile(json_path)
        raw = fileread(json_path);
        settingsMCC = jsondecode(raw);
        cellsFieldnames = fieldnames(settingsMCC);
        ic_elec_name = cellsFieldnames{1, 1}(2:end);
    else
        ic_elec_name = 'unknown electrode';
    end
end

function [ic_elec,ic_elec_link,nwb] = nwbInitElectrode(nwb,ic_elec_name)

    corticalArea = 'NA'; % Location place holder

    device_name = 'CED digitizer Power 1401 mkII; Amplifier: SEC-05X';  % @Stefan: hier bitte die richtigen

    %% Getting run and electrode associated properties
    nwb.general_devices.set(device_name, types.core.Device());
    device_link = types.untyped.SoftLink(['/general/devices/' device_name]);
    ic_elec = types.core.IntracellularElectrode( ...
        'device', device_link, ...
        'description', 'Properties of electrode and run associated to it', ...
        'filtering', 'unknown', ...
        'initial_access_resistance', 'has to be entered manually', ...
        'location', corticalArea ...
    );
    nwb.general_intracellular_ephys.set(ic_elec_name, ic_elec);
    ic_elec_link = types.untyped.SoftLink(['/general/intracellular_ephys/' ic_elec_name]);
end

function [sweepAmps,stimDesc,sweepNumberEnd,ic_elec,nwb] = cfsFile2NWB(CfsFile, ...
        nwb, ...
        ic_elec_name, ...
        sweepNumberStart, ...
        cellStartTime)

    nwb.session_start_time = cellStartTime;

   
    stimDesc = createStimDescription(mean(CfsFile.data(:,:,2),2),CfsFile.param.xScale(2),CfsFile.param.yScale(2));

    sweepAmps = [];
    
    sweepNumber = sweepNumberStart;
         
    for s = 1:size(CfsFile.data, 2)

        [ic_elec,ic_elec_link,nwb] = nwbInitElectrode(nwb,ic_elec_name);
    
%        sweepAmps = [sweepAmps,getStimAmplitude(CfsFile.data(:,s,2),stimDesc)];
        sweepAmps = [sweepAmps,getStimAmplitude(CfsFile.data(:,s,2),stimDesc,CfsFile.param.xScale(1))]; % for correct sweet amp

        
        nwb=nwbAddSweep(nwb,...
                    sweepNumber,...
                    ic_elec_link,stimDesc.name,...
                    CfsFile.param.fTime,...
                    stimDesc,...
                    CfsFile.data(:,s,1), CfsFile.param.yUnits{1}, CfsFile.param.xScale(1),...
                    CfsFile.data(:,s,2), CfsFile.param.yUnits{2}, CfsFile.param.xScale(2));
        
        sweepNumber = sweepNumber+1;

    end
     sweepNumberEnd = sweepNumber;
end

function nwb = initNwb(nwbIdentifier,AnimalDesc)
    nwb = NwbFile(...
        'identifier', nwbIdentifier, ...
        'general_lab', 'Jochen Staiger', ...
        'general_institution', 'Institute for Neuroanatomy UMG', ...
        'general_experiment_description', 'Characterizing intrinsic biophysical properties of cortical NHP neurons.', ...
        'session_description', 'One experiment day' ...
    );

    nwb.general_subject = types.core.Subject( ...
        'description', AnimalDesc.name, ...
        'age', num2str(AnimalDesc.age), ...
        'sex', AnimalDesc.sex, ...
        'species', AnimalDesc.species, ...
        'weight', AnimalDesc.weight ...
    );

end

function ID = getNwbIdentifier(AnimalDesc,CellTag)
    switch AnimalDesc.patcher %Hardcoding initials for id
        case 'FELIX'
            initials = 'FP';
        case 'JENIFER'
            initials = 'JR';
        case 'ANDREAS'
            initials = 'AN';
        otherwise
            initials = 'XX';
    end
            

    MATFXID = ['M',num2str(AnimalDesc.number, '%02.f'),'_',initials, '_A1_C', CellTag,'_']; % ID for MatFX naming convention - needs to be expanded on
    ID = [MATFXID,'Goettingen', '_',AnimalDesc.Amp,'_Cell', CellTag];
end


