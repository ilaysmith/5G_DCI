function waveform = ofdmSignalGenerator(fs, resourceGrid, channelBandwidth, NGridStart, config, isCpExtended, resGridShift)
%ofdmSignalGenerator Creates time-continuous signal on subcarrier spacing
%configuration 'mu' for any physical channel or signal except PRACH [TS 38.211, clause 5.3.1]

arguments
    fs (1,1) {mustBeInteger, mustBePositive} % output signal sample rate
    resourceGrid % resource grid complex matrix
    channelBandwidth % channel bandwidth in MHz
    NGridStart
    config
    isCpExtended {mustBeMember(isCpExtended,[0 1])}
    resGridShift (1,1) {mustBeNonnegative} = 0 % resource grid subcarrier shift (may be fractional (1/2, 1/4 etc.))
end

% "timeSignal" is a matrix containing rows that represent time 't' 
% expressed in time units Tc = 1/(480e3*4096) [38.211, 4.1] and
% columns that represent symbols 'l'. "timeSignal" represents s_l_p,mu(t)
    
    % definition of constants
    Tc = 1 / (480e3 * 4096); % elementary time unit, s [38.211, 4.1]
    NscRB = 12; % number of subcarriers in one resource block [38.211, 4.4.4.1]
    NGridSize = length(resourceGrid(:, 1)) / NscRB;
    symbolsAmount = length(resourceGrid(1, :));

    mu0 = 1; % the largest mu value among SCS configurations in FR1 for downlink
    NGridStart0 = NGridStart * 2 ^ (config.mu - mu0);
    ResourceGridConstants;
    NGridSize0Seq = MaximumTransmissionBandwidthConfiguration(2 ^ mu0 * 15); % 2^mu*15 = SCS
    NGridSize0 = NGridSize0Seq(channelBandwidth);
    k0 = (NGridStart + NGridSize / 2) * NscRB - (NGridStart0 + NGridSize0 / 2) * NscRB * 2 ^ (mu0 - config.mu);
    
    Nu = 2048 * 64 * 2^-config.mu; % useful part length in Tc's
    
    symbolIndex = 0 : symbolsAmount-1;
    l = mod(symbolIndex, config.symbolsPerSubframe);
    
    Ncp = zeros(1, config.symbolsPerSubframe); % cyclic prefix part lengths in Tc's
    Ncp(l +1) = 64 * 2 ^ -config.mu * (isCpExtended * 512 + ~isCpExtended * 144) + ...
            16 * 64 * ~isCpExtended * bitor(l == 0 , l == 7 * 2 ^ config.mu);
    Nsymb = Nu + Ncp;
    
    Nstart = zeros(1, config.symbolsPerSubframe);
    for index = l
        if index ~= 0
        Nstart(index +1) = Nstart(index-1 +1) + Nsymb(index-1 +1);
        end
    end

    Ntotal = sum(Nsymb);
    signal = zeros(1, Ntotal);
    
    Nfft = 2 ^ (17 - config.mu);
    x = ifft([resourceGrid(:, symbolIndex +1); zeros(Nfft - NGridSize * NscRB, symbolsAmount)]);
    for symbolIndex = symbolIndex
        
        l = mod(symbolIndex, config.symbolsPerSubframe);
        subframeIndex = floor(symbolIndex / config.symbolsPerSubframe);
        t = (0 : Nsymb(l +1)-1)+ Nstart(l +1) + sum(Nsymb)*subframeIndex; % absolute time index

        % creating signal
        timeFactor = Nfft^-1 * (0 : Nu-1);
        signal(t(end - Nu + 1 : end) +1) = exp(1j * 2*pi * (k0 - NGridSize * NscRB / 2 + resGridShift) * timeFactor ) .* ...
            Nfft .* x((0 : Nu-1) +1,symbolIndex +1).';
        signal = signal.';
        
        % creating cyclic prefixes
        signal(t((0 : Ncp(l +1)-1) +1 ) +1) = signal(t(end - (Ncp(l +1) - 1) : end) +1);
                
    end
    waveform = resample(signal, fs, 1/Tc);
end