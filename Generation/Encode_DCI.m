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


% CRC   use crc_type = 'crc24c', bitstream = dci . attachParityBits - взято
% у Валентина
codeword = attachParityBits(dci,crc_type);

% Channel coding. polarCoding - взято у Валентина
codeword = polarCoding(codeword); 

% Rate matching - взято у Валентина
codeword = rateMatching(codeword);


end



