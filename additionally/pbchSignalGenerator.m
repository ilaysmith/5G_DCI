function waveform = pbchSignalGenerator(...
    fs, duration, startFrame, startHRF, caseLetter, NCRBSSB, kSSBbit, ...
    absolutePointA, channelBandwidth, NCellId, MIB, isCpExtended, powerFactor...
    )
%PBCHSIGNALGENERATOR The function creates time-domain 5G NR PBCH complex signal

    arguments
        fs (1,1) {mustBePositive} % sample rate in Hz
        duration (1,1) {mustBePositive} % output waveform's duration in seconds
        startFrame (1,1) {mustBeMember(startFrame,0:15)} % four LSB of the start SFN expressed as integer number                                  
        startHRF (1,1) {mustBeMember(startHRF, [0 1])} % start half frame bit
        caseLetter (1,1) {mustBeMember(caseLetter,{'A','B','C'})} % frequency config case letter
        NCRBSSB (1,1) % number of common resource block containing first subcarrier of SS/PBCH block expressed in units assuming 15 kHz SCS (offsetToPointA)
        kSSBbit (1,1) % 5th least significant bit of kSSB needed for Lmax_ = 4 or 8
        absolutePointA (1,1) % ARFCN (absolute radio frequency channel number) frequency in GHz
        channelBandwidth (1,1) % channel bandwidth in MHz
        NCellId (1,1) {mustBeMember(NCellId, 0:1007)} % cell identificator (0...1007)
        MIB  (1,23) {mustBeMember(MIB, [0 1])} % master information block [38.331, 6.2.2] (binary sequence)
        isCpExtended = 0 % logical, defines whether the cyclic prefix is extended or not
        powerFactor {mustBeVector} = [1 1 1 1] % vector of four power allocation factors for [pss sss pbch dmrs]
    end
    
    startFrame = startFrame + bit2int([MIB(1:6) 0 0 0 0].',10);
    config = caseConfiguration(caseLetter, absolutePointA);
    kSSB = bit2int([MIB(8:11)].',4);
    if ismember(config.Lmax_, [4 8])
        kSSB = kSSB + kSSBbit * 2^4;
    end

    HRF_DURATION = 5e-3;
    HRFsAmount = ceil(duration / HRF_DURATION);
    wavetable = zeros(floor(HRF_DURATION * fs), HRFsAmount);
    for absoluteHRFindex = 0:HRFsAmount-1
        HRF = mod(absoluteHRFindex + startHRF,2);
        SFN = startFrame + floor((absoluteHRFindex + startHRF) / 2);
        [rg, rgShift] = createPbchHalfFrame(caseLetter, absolutePointA, channelBandwidth, NCellId, MIB, SFN, HRF, NCRBSSB, kSSB,powerFactor);
        wavetable(:, absoluteHRFindex +1) = ofdmSignalGenerator(fs, rg, channelBandwidth, 0, config, isCpExtended, rgShift).';
    end
    
    buffer = reshape(wavetable,[1 length(wavetable(:,1))*length(wavetable(1,:))]);
    waveform = buffer(1:floor(duration * fs)); % deleting not requested samples
end

