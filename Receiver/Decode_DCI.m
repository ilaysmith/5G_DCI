% function Decode_DCI for dci sequence 
function get_DM = Decode_DCI(received_codeword, crc_type)
arguments
    received_codeword
    crc_type
end

% CRC   use crc_type = 'crc24c', bitstream = received_codeword . rateRecovery - взято
% у Dimach24
received_codeword = rateRecovery(received_codeword); 

% Channel decoding. polarDecoding - взято у Dimach24
received_codeword = polarDecoding_2(received_codeword); 

% verifeParity - взято у Dimach24
get_DM = verifyParity(received_codeword, crc_type);

%get_DM = received_codeword;
end
