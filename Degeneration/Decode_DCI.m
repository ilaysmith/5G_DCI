function dcibits = Decode_DCI(...
    dcicw,                         ... 
    crc_type                       ... % must be "crc<length><?letter>" letter is only necessary crc24_
    )

arguments
    dcicw (1,:) % vector string
    %bitstream
    crc_type string
    %attach_zeros=true

end

% rate recovery
dcibitsRR = rateRecovery(dcicw);

% polar decoding
dcibitsPD = polarDecoding(dcibitsRR); 

%verify parity
[dcibits,verification_success] = verifyParity(dcibitsPD,crc_type);

end
