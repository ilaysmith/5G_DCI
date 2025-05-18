function data=qpskModulation(bits)
    % modulates bits to QPSK complex amplitudes
    % "bits" must be even-length
    data = (1-2*bits(2*(0:end/2-1)+1)+1j*(1-2*bits(2*(0:end/2-1)+2)))/sqrt(2);
end