% function descrambling
function descrambling_bits = de_scrambling_pdcch(codeword, n_RNTI, nID)
arguments
    codeword
    n_RNTI
    nID
end

descrambling_bits = scrambling_pdcch(codeword, n_RNTI, nID);
end

