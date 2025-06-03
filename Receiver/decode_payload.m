% function to decode payload dci. blind search
function decode_dci = decode_payload ( ...
    NcellID, ...
    n_RNTI ...
    )
arguments
    NcellID (1,1)
    n_RNTI (1,1)
        
end

% Bandwidth part (BWP) configuration
bwp = [];
bwp.SubcarrierSpacing = 30;          % BWP Subcarrier spacing
bwp.NRB = 48;                        % Size of BWP in resource blocks
bwp.CyclicPrefix = 'normal';         % BWP cyclic prefix

% CORESET configuration
coreset = [];
coreset.AllocatedPRB = [1 1 1 0 1];        % frequencyDomainResources, each bit is 6RB
coreset.Duration = 1;                      % Symbol duration (1,2,3)
coreset.CCEREGMapping = 'nonInterleaved';  % Mapping: 'interleaved' or 'nonInterleaved'
coreset.REGBundleSize = 2;                 % L (2,6) or (3,6)
coreset.InterleaverSize = 3;               % R (2,3,6)
coreset.ShiftIndex = NcellID;              % default to NcellID, 0...274
coreset.PDCCHDMRSScramblingID = NcellID;   % default to NcellID, 0...65535

% Search Space configuration: multiple within a slot
ss = [];
ss.AllocatedSymbols = [0,4,8];    % first symbol of each monitoring occasion in slot, 0-based
ss.AllocatedSlots = 0;            % first slot, 0-based
ss.AllocatedPeriod = 1;           % over slots

% PDCCH instance configuration
pdcch = [];
pdcch.NumCCE = 4;                 % Number of CCE in PDCCH, in 6REG units (or AggregationLevel:1,2,4,8,16)
pdcch.AllocatedSearchSpace = 2;   % 0-based for now, scalar only, index into AllocatedSymbols
pdcch.RNTI = 0;                   % RNTI
pdcch.DataBlkSize = 64;           % DCI payload size
pdcch.BWP = bwp;                  % Associated bandwidth part
pdcch.CORESET = coreset;          % Associated CORESET
pdcch.SearchSpaces = ss;          % Associated SearchSpace


end
