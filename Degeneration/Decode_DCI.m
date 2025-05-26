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

% rate recovery test (do not test)
Edci = length(dcicw);
Kout = 39;
nMax = 9; 
K = Kout+24;            % K includes CRC bits
N = nr5g.internal.polar.getN(K,Edci,nMax);
recBlk = nrRateRecoverPolar(dcicw.',K,N); %matlab function
isequal(recBlk, dcibitsRR.');

% polar decoding
dcibitsPD = polarDecoding(dcibitsRR); 

%polar decoding test
rnti = 1;
L = 8; %power of 2
padCRC = false;              % signifies input prepadding with ones
decBlk = nrPolarDecode(recBlk,K,Edci,L,padCRC, rnti); %matlab function
isequal(decBlk.', dcibitsPD) ;


%verify parity
[dcibits,verification_success] = verifyParity(dcibitsPD,crc_type);

%verify parity test
%[padDCIBits,mask] = nrCRCDecode([ones(24,1);decBlk],'24C',rnti);
[padDCIBits,mask] = nrCRCDecode(decBlk,'24C'); %matlab function
%dciBits = cast(padDCIBits(25:end,1),'int8'); % remove the prepadding
isequal(padDCIBits, dcibits.') ;

end