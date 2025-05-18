% the function of receiving pdcch bits
function symbols = get_pdcch_symbols( ...
    codeword, ...
    nID, ...
    n_RNTI ...
    )
arguments
        codeword (1,:) % encoded payload
        nID (1,1)      % cell identificator (0...1007)
        n_RNTI (1,1)   % CRC mask required to decode the DCI message
end

% use function scrambling_pdcch. Get scrambled_bits
scrambled_bits = scrambling_pdcch(codeword, n_RNTI, nID);

% getting scrambled sequence for matlab
len = length(codeword);
sequence_2 = nrPDCCHPRBS(nID, n_RNTI,len);
sequence_2_2 = sequence_2'; 

% getting the scrambling bits for matlab
scrambled_bits_2 = mod(codeword + sequence_2_2,2);
%scrambled_bits_2_2 = scrambled_bits_2';

isequal(scrambled_bits, scrambled_bits_2)

% modulation QPSK. qpskModulation - взято у Валентина
symbols = qpskModulation(scrambled_bits);

end