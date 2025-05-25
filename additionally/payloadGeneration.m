function out_sequence = payloadGeneration(MIB,SFN,HRF, SSBParam, Lmax_)
%payloadGeneration [TS 38.212, 7.1.1]
    arguments
    MIB (1,23)
    SFN (1,1) % system frame number positive integer 
    HRF (1,1) % half frame bit
    SSBParam (1,1) % kSSB if Lmax_ =4|8 or iSSB if Lmax_ = 64
    Lmax_ (1,1) % = 4|8|64 maximum number of candidate SS/PBCH blocks in half frame [4.1, TS 38.213]
    end
    
    % processing SSB bits
    if Lmax_ == 64 % [<6th bit> <5th bit> <4th bit>] of iSSB
        biSSB = int2bit(SSBParam,6).';
        kSSBbits = [biSSB(1) biSSB(2) biSSB(3)];
    else % [<MSB of kSSB> 0 0] if Lmax_ =4|8 
        bkSSB=int2bit(SSBParam,5).';
        kSSBbits = [bkSSB(1) 0 0]; 
    end
    
    % sequence generation
    binSFN = int2bit(SFN,10).';
    sequence = [0 MIB binSFN((end-3):end) HRF kSSBbits];

    % interleaving
    A = length(sequence);
    A_ = A-8;
    G = [16 23 18 17 8 30 10 6 24 7 0 5 3 2 1 4 ...
    9 11 12 13 14 15 19 20 21 22 25 26 27 28 29 31]; %TS 38.212 table 7.1.1-1
    jSFN = 0;
    jHRF = 10;
    jSSB = 11;
    jOTHER = 14;
    out_sequence = zeros(1,32); 
    for i=1:A
        if (i >= 2 && i <= 7)||(i >= A_+1 && i <= A_+4) %SFN bits
            out_sequence(G(jSFN+1)+1)=sequence(i);
            jSFN = jSFN+1;
        elseif i == A_+5 %HRF
            out_sequence(G(jHRF+1)+1)=sequence(i);
        elseif i >= A_+6 && i<=A+8 % L_massive
            out_sequence(G(jSSB+1)+1)=sequence(i);
            jSSB = jSSB+1;
        else
            out_sequence(G(jOTHER+1)+1)=sequence(i);
            jOTHER = jOTHER+1;
        end
    end

end