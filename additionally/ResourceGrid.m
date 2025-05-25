classdef ResourceGrid<handle
    properties
        resourceGrid
        % main grid
        mu
        % subcarrier spacing cofiguration (Δf=2^mu*15 [kHz])
    end
    methods 
        function obj = ResourceGrid(symbolsAmount, channelBandwidth,mu)
            % createResourceGrid
            % creates empty Resource grid for this
            % configuration [38.211, 4.3.2] or wipes
            % all data in the grid
            arguments
                symbolsAmount (1,1) % length of resource grid in time domain
                channelBandwidth (1,1) % channel bandwidth, MHz see [38.101-1: Table 5.3.2-1]
                mu % case configuration structure, see [38.213, 4.1]
            end
            obj.mu = mu;
            ResourceGridConstants;
            NRBSeq=MaximumTransmissionBandwidthConfiguration(2^mu*15); % 2^mu*15 = SCS
            NRB=NRBSeq(channelBandwidth);
            if NRB == 0
                error("Incorrect channel bandwidth value.")
            end
            obj.resourceGrid=zeros(12*NRB, symbolsAmount);
        end
        function mapToResourceGrid(obj, dataMatrix, symbOfs, scOfs)
            arguments
                obj
                dataMatrix % input data matrix
                symbOfs (1,1) {mustBeInteger, mustBeNonnegative} = 0 % time domain offset expressed in number of OFDM symbols
                scOfs (1,1) {mustBeInteger, mustBeNonnegative} = 0 % frequency domain offset expressed in number of subcarriers
            end
            symb = 0:length(dataMatrix(1,:))-1;
            sc = 0:length(dataMatrix(:,1))-1;
            obj.resourceGrid(scOfs + sc +1, symbOfs + symb +1) = dataMatrix;
        end
    end
end