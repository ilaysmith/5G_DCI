% encode dci - > codeword 

function codeword = Encode_DCI(...
    dci,                           ... 
    crc_type                       ... % must be "crc<length><?letter>" letter is only necessary crc24_
    )

arguments
    dci (1,:) % vector string
    %bitstream
    crc_type string
    %attach_zeros=true

end

% crc attachment
% CRC   use crc_type = 'crc24c', bitstream = dci 
codeword = attachParityBits(dci,crc_type);

% Channel coding
codeword = polarCoding(codeword); 

% Rate matching 
codeword = rateMatching(codeword);

end



