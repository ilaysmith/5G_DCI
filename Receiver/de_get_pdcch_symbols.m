% функция производящая демодуляцяю qpsk символов pdcch. А так же
% дескремблирование
function received_codeword = de_get_pdcch_symbols( ...
    symbols, ...
    nID, ...
    n_RNTI ...
    )
arguments
    symbols
    nID
    n_RNTI
end

% demodulation. Use function qpskDemodulate (Dimach24)

de_symbols = qpskDemodulate(symbols);

% descrambling. Use function de_scrambling_pdcch. 

descrambling_bits = de_scrambling_pdcch(de_symbols, n_RNTI, nID);

received_codeword = descrambling_bits;
end

