function [resourceGrid, resGridShift] = createPbchHalfFrame(caseLetter, absolutePointA, channelBandwidth, NCellId, MIB, SFN, HRF, NCRBSSB, kSSB, powerFactor)
% creates one halfframe transmission of Physical Broadcast Channel (PBCH)

            arguments
                caseLetter % freq. config case letter, see [38.213, 4.1]
                absolutePointA (1,1)  % absolute frequency Point A in GHZ
                channelBandwidth (1,1) % channel bandwidth in MHz
                NCellId (1,1) % cell identity number (0...1007)
                MIB (1,23) % 23 bit sequence
                SFN (1,1) % system frame number
                HRF (1,1) % half radio frame bit
                NCRBSSB(1,1) % frequency-domain offset from PointA in units of resource blocks assuming 15 kHz SCS
                kSSB (1,1) % frequency-domain offset from PointA in subcarriers assuming 15 kHz SCS (0...23)
                powerFactor (1,4) = [1 1 1 1] % power allocation scaling factor [<pss> <ss> <pbch> <dmrs>]
            end

            % Get resource grid configuration
            config = caseConfiguration(caseLetter,absolutePointA);

            % Create resource grid
            symbolsInHalfFrame = 2^config.mu * 14 * 5;
            symbolsAmount = symbolsInHalfFrame;
            rg=ResourceGrid(symbolsAmount, channelBandwidth, config.mu);

            % Create SS/PBCH burst
            ss = SsSignals(NCellId);
            ssPbchBurst = zeros(240, symbolsAmount);
            M = 864; % length of generated PBCH bit sequence
            c = pseudoRandomSequence(NCellId,M*config.Lmax_); % sequence for PBCH scrambling

            iSSB = 0; % = 0...Lmax_-1
            for shift = (config.blockIndexes) % for each block in one HRF

                % PBCH generation [38.212, 7.1]
                ssPbchParam = kSSB*(config.Lmax_~=64)+iSSB*(config.Lmax_==64); % selecting kSSB or iSSB
                pbch = generatePbch(MIB,SFN,HRF,config.Lmax_,ssPbchParam,NCellId);
                % PBCH scrambling [38.211, 7.3.3.1]
                pbch(1:M) = mod(pbch(1:M)+ c((1:M)+iSSB*M),2); % iSSB = nu
                % PBCH modulation [38.211, 7.3.3.2]
                pbch = qpskModulation(pbch);

                % Dm-Rs Generation
                iSSB_ = iSSB + 4*HRF*(config.Lmax_ == 4);
                dmrs = generatePbchDmRs(iSSB_,NCellId);

                % block creation
                ssPbchBurst(1:240,(1:4)+shift) = createSsPbchBlock(ss,pbch,dmrs,NCellId,powerFactor);
                iSSB=iSSB+1;

            end

            % mapping onto resource grid
            shift = 24 * (caseLetter == 'A'); % needed for bad solution of kSSB problem in case 'A'
            subcarrierOffset = (12 * NCRBSSB + kSSB - shift) * 2^(-config.mu);
            resGridShift = subcarrierOffset - floor(subcarrierOffset);
            rg.mapToResourceGrid(ssPbchBurst, 0, floor(subcarrierOffset));
            resourceGrid = rg.resourceGrid;
end
