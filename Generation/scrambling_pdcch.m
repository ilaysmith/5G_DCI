% function for scrambling.
function srcambling_bits = scrambling_pdcch(codeword, n_RNTI, nID)
arguments
    codeword
    n_RNTI
    nID
end

% 
cinit = mod(double(n_RNTI)*2^16 + double(nID),2^31);

% getting the scrambling sequence c(i)          
% 5.2.1 38.211 + 7.3.2.3
sequence = fun_pbrs(codeword, cinit);

% getting the scrambling bits 
srcambling_bits = mod(codeword + sequence,2);

end

