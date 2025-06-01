function [resource_grid,symbols,coreset_config] = createPdcchFrame(...
    crc_type,coreset_config, dci_config,NCellId,AL,pdcch_ConfigSIB1)
arguments 
    crc_type            % type crc
    coreset_config      % config coreset
    dci_config          % config dci
    NCellId             % NCellId
    AL                  % Agrigation level
    pdcch_ConfigSIB1    % Information from MIB
end


%dci_config.TDRA;
%dci_config.VrbPrb;
%dci_config.macs;
%dci_config.rv;
%dci_config.sII;

b_pdcch_ConfigSIB1 = dec2bin(pdcch_ConfigSIB1);
b_inf_13_4 = b_pdcch_ConfigSIB1(1:4);
b_inf_13_11 = b_pdcch_ConfigSIB1(5:8);

inf_13_4 = bin2dec(b_inf_13_4);
inf_13_11 = bin2dec(b_inf_13_11);

if inf_13_11 == 14
    coreset_config.start_symbol = 1; % symb
end

if inf_13_4 == 15
    coreset_config.start_symbol = 1; % symb
    coreset_config.duration = 1; % symb
    coreset_config.ssb_offset_crst = 16; % RBs
    coreset_config.size_rbs = 48; % RBs
end

dci_config.FDRA = ceil(log2(coreset_config.size_rbs*(coreset_config.size_rbs+1)/2));
%FDRA = 11; % 10,19967 rounded up
dci_config.reserved_bits = 0; % zeros(0,15) 


% get the bits dci for format 1_0 
DM = getDCI(dci_config.FDRA, dci_config.TDRA, dci_config.VrbPrb,dci_config.macs,...
    dci_config.rv,dci_config.sII,dci_config.reserved_bits);

% encode the payload bits 38.212 with use CRC attachment (7.3.2),
% Channel coding (7.3.3), Rate mathcing (7.3.4).
codeword = Encode_DCI(DM,crc_type);

% Get the PDCCH QPSK symbols nrPDCC
n_RNTI = 65535; % set of standards 65535
symbols = get_pdcch_symbols(codeword, NCellId, n_RNTI);

%Get the resource grid for pdcch
[resource_grid,coreset_config] = fun_mapping(coreset_config, symbols, AL, NCellId);
  
  end