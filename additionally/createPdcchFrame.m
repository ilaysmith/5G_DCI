function resource_grid = createPdcchFrame(...
    crc_type,rbs_coreset, TDRA, VrbPrb,macs,rv, sII, NCellId, ssb_offset_crst,duration_crst, AL)
arguments 
    crc_type
    rbs_coreset         % for Frequence domain resource assigments
    TDRA                % Time domain resource assigments
    VrbPrb              % VRB-PRB mapping. Non-Interleaved for coreset 0
    macs                % modulation and coding scheme
    rv                  % redundancy Version.
    sII                 % System Information Indicator. SIB 1
    NCellId
    ssb_offset_crst
    duration_crst
    AL
end


FDRA = ceil(log2(rbs_coreset*(rbs_coreset+1)/2));
%FDRA = 11; % 10,19967 rounded up
reserved_bits = 0; % zeros(0,15) 

% get the bits dci for format 1_0 
DM = getDCI(FDRA, TDRA, VrbPrb,macs,rv,sII, reserved_bits);

% encode the payload bits 38.212 with use CRC attachment (7.3.2),
% Channel coding (7.3.3), Rate mathcing (7.3.4).
codeword = Encode_DCI(DM,crc_type);

% Get the PDCCH QPSK symbols nrPDCC
n_RNTI = 1; % set of standards 65535
symbols = get_pdcch_symbols(codeword, NCellId, n_RNTI);

%Get the resource grid for pdcch
resource_grid = fun_mapping(symbols, rbs_coreset,ssb_offset_crst,duration_crst,AL, NCellId);
  
  end