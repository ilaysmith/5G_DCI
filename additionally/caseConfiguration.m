function out = caseConfiguration(caseLetter, carrierFrequency, isSpectrumOperationPaired, isSpectrumAccessShared)
% defines resource grid configuration via case identificator letter
% in cases without cyclic prefix
    arguments
        caseLetter % freq. config case letter, see [38.213, 4.1]
        carrierFrequency (1,1) % carrier frequency in GHz
        isSpectrumOperationPaired = 0; % defines paired spectrum operation cases
        isSpectrumAccessShared = 0; % defines shared spectrum channel acces cases
    end
    switch caseLetter
        case 'A'
            if isSpectrumAccessShared
                n = [0 1 2 3 4];
                out.Lmax_ = 10;
            else
                n = [0 1];
                out.Lmax_ = 4;
                if (carrierFrequency > 3)
                    n = [0 1 2 3];
                    out.Lmax_ = 8;
                end
            end
            out.blockIndexes=reshape([2 8]+14*n.',1,[]);
            out.mu = 0;
        case 'B'
            n = 0;
            out.Lmax_ = 4;
            if carrierFrequency > 3
                n = [0 1];
                out.Lmax_ = 8;
            end
            out.blockIndexes=reshape([4 8 16 20]+28*n.',1,[]);
            out.mu = 1;
        case 'C'
            if isSpectrumAccessShared
                n = [0 1 2 3 4 5 6 7 8 9];
                out.Lmax_ = 20;
            else
                n = [0 1];
                out.Lmax_ = 4;
                if ((carrierFrequency > 3)&&isSpectrumOperationPaired||(carrierFrequency >= 1.88)&&~isSpectrumOperationPaired)
                    n = [0 1 2 3];
                    out.Lmax_ = 8;
                end
            end
            out.blockIndexes=reshape([2,8]+14*n.',1,[]);
            out.mu = 1;
        case 'D'
            n = [0 1 2 3 5 6 7 8 10 11 12 13 15 16 17 18];
            out.blockIndexes=reshape([8,12,16,20]+28*n.',1,[]);
            out.mu = 3;
            out.Lmax_ = 64;
        case 'E'
            n = [0 1 2 3 5 6 7 8];
            out.blockIndexes=reshape([(8:4:20),(32:4:44)]+56*n.',1,[]);
            out.mu = 4;
            out.Lmax_ = 64;
        case 'F'
            n = 0:31;
            out.blockIndexes=reshape([2,9]+14*n.',1,[]);
            out.mu = 5;
            out.Lmax_ = 64;
        case 'G'
            n = 0:31;
            out.blockIndexes=reshape([2,9]+14*n.',1,[]);
            out.mu = 6;
            out.Lmax_ = 64;
        otherwise
            error("Freq case must be uppercase letter A, B, C, D, E, F or G!")
    end
    out.blockIndexes=sort(out.blockIndexes); % indexing from 1
    out.scs = 2^out.mu * 15;
    out.slotsPerSubframe = 2^out.mu;
    out.symbolsPerSubframe = out.slotsPerSubframe * 14;
    out.symbolsPerSecond = out.symbolsPerSubframe * 1000;
end
