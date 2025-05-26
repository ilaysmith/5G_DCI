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

% crc attachment test
%bitscrcPad = nrCRCEncode([ones(24,1,class(dci.'));dci.'],'24C');  % First prepend 1s
bitscrcPad = nrCRCEncode(dci.','24C');  %matlab function
%cVec = bitscrcPad(25:end,1); % Then, after calculating the CRC, remove the 1s
isequal(codeword, bitscrcPad.');
%isequal(codeword, cVec.') ;

% Channel coding
codeword = polarCoding(codeword); 

% Channel coding test
encOut = nrPolarEncode(bitscrcPad, 864); %matlab function
isequal(codeword, encOut.');

% Rate matching 
codeword = rateMatching(codeword);

% Rate matching test
K = length(bitscrcPad);
dciCW = nrRateMatchPolar(encOut,K,864); %matlab function
isequal(codeword, dciCW.');

end



