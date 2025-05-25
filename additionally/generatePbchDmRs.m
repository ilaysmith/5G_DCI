function dmrs=generatePbchDmRs(iSSB_,NCellId)
    % generates PBCH DM-RS according SSB index and BS ID
    arguments
        iSSB_ (1,1) % must be (4*HRF + 2 LSB of iSSB if Lmax_ = 4) or (3 LSB of iSSB if Lmax_ = (8 or 64) )
        NCellId (1,1) % cell identificator
    end
    iSSB_ = mod(iSSB_,8);
    cinit=2^11*(iSSB_+1)*(floor(NCellId/4)+1)+2^6*(iSSB_+1)+mod(NCellId,4);
    c = pseudoRandomSequence(cinit,288);
    dmrs=1/sqrt(2)*(1-2*c(1:2:end))+1j/sqrt(2)*(1-2*c(2:2:end));
end


