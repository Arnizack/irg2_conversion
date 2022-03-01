function nwb = makeICtab(nwb, CS, ic_elec)
   if CS.swpCt > 5
    CS.BinaryLP(isnan(CS.BinaryLP)) = 0;
    CS.BinarySP(isnan(CS.BinarySP)) = 0;
    CS.StimOn(isnan(CS.StimOn)) = 0;
    CS.StimOff(isnan(CS.StimOff)) = 0;
    CS.SweepAmp(isnan(CS.SweepAmp)) = 0;
    CS.StimDuration = CS.StimOff - CS.StimOn;   

    ic_rec_table = types.core.IntracellularRecordingsTable( ...
        'categories', {'electrodes', 'stimiuli', 'responses'}, ...
        'colnames', {'recordings_tag'}, ...
        'description', [ ...
            'A table to group together a stimulus and response from a single ', ...
            'electrode and a single simultaneous recording and for storing ', ...
            'metadata about the intracellular recording.'], ...
        'id', types.hdmf_common.ElementIdentifiers( ...
            'data', int64([0:CS.swpCt-1]) ...
        ) ...
    );
    if types.untyped.ObjectView(ic_elec).has_path
      ic_rec_table.electrodes = types.core.IntracellularElectrodesTable( ...
        'description', 'Table for storing intracellular electrode related metadata.', ...
        'colnames', {'electrode'}, ...
        'id', types.hdmf_common.ElementIdentifiers( ...
            'data', int64([0:CS.swpCt-1]) ...
        ), ...
        'electrode', types.hdmf_common.VectorData( ...
            'data', repmat(types.untyped.ObjectView(ic_elec), CS.swpCt-1, 1), ...
            'description', 'Column for storing the reference to the intracellular electrode' ...
        ) ...
      );
    else
     ic_rec_table.electrodes = types.core.IntracellularElectrodesTable( ...
        'description', 'Table for storing intracellular electrode related metadata.', ...
        'colnames', {'electrode'}, ...
        'id', types.hdmf_common.ElementIdentifiers( ...
            'data', int64([0:CS.swpCt-1]) ...
        ), ...
        'electrode', types.hdmf_common.VectorData( ...
            'data', repmat(types.untyped.ObjectView('general_intracellular_ephys/unknown'), CS.swpCt-1, 1), ...
            'description', 'Column for storing the reference to the intracellular electrode' ...
        ) ...
      );
    end

    ic_rec_table.stimuli = types.core.IntracellularStimuliTable( ...
        'description', 'Table for storing intracellular stimulus related metadata.', ...
        'colnames', {'stimulus'}, ...
        'id', types.hdmf_common.ElementIdentifiers( ...
            'data', int64([0:CS.swpCt-1])  ...
        ), ...
        'stimulus', types.core.TimeSeriesReferenceVectorData( ...
            'description', 'Column storing the reference to the recorded stimulus for the recording (rows)', ...
            'data', struct( ...
                'idx_start', [CS.StimOn(CS.StimOn~=0)], ...
                'count', [CS.StimDuration(CS.StimDuration~=0)], ...
                'timeseries', [CS.sweep_series_objects_ch1] ...
            )...
        )...
    );
    ic_rec_table.responses = types.core.IntracellularResponsesTable( ...
        'description', 'Table for storing intracellular response related metadata.', ...
        'colnames', {'response'}, ...
        'id', types.hdmf_common.ElementIdentifiers( ...
            'data', int64([0:CS.swpCt-1]) ...
        ), ...
        'response', types.core.TimeSeriesReferenceVectorData( ...
            'description', 'Column storing the reference to the recorded response for the recording (rows)', ...
            'data', struct( ...
                'idx_start', [CS.StimOn], ...
                'count', [CS.StimDuration], ...
                'timeseries', [CS.sweep_series_objects_ch2]...
            )...
        )...
    );

% Add protocol type as column of electrodes table

Protocols = cell.empty;

for s = 1:length(CS.BinaryLP)
    if CS.BinaryLP(s)
      Protocols(s) = {'LP'};
    elseif CS.BinarySP(s)
      Protocols(s) = {'SP'};   
    else
      Protocols(s) = {'unknown'};          
    end
end

ic_rec_table.categories = [ic_rec_table.categories, {'protocol_type'}];
ic_rec_table.dynamictable.set( ...
    'protocol_type', types.hdmf_common.DynamicTable( ...
        'description', 'category table for lab-specific recording metadata', ...
        'colnames', {'label'}, ...
        'id', types.hdmf_common.ElementIdentifiers( ...
            'data', int64([0:CS.swpCt-1]) ...
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
    'data', [CS.SweepAmp'], ...
    'description', 'Current amplitude of injected square pulse' ...
    ) ...
);

nwb.general_intracellular_ephys_intracellular_recordings = ic_rec_table;


end