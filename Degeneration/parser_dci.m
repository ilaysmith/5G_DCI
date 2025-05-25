% function for decomposition dci for pdsch 
function dci_block = parser_dci(DM)
arguments 
    DM
end

bit_string = num2str(DM);
bit_string = bit_string(bit_string ~= ' '); % Удаляем пробелы

FDRA_bit = bit_string(1:11);    % Первые 11 бит
TDRA_bit = bit_string(12:15);   % Следующие 4 бита
VrbPrb_bit = bit_string(16);    % 1 бит для vrbprb
MACS_bit = bit_string(17:21);   % Следующие 5 бит для modulation_and_coding_scheme
RV_bit = bit_string(22:23);     % 2 бита для redundancy_Version
sII_bit = bit_string(24);       % 1 бит для sII
RB_bit = bit_string(25:end);    % Последние 15 бит для reserved_bits

FDRA = bin2dec(FDRA_bit); % Переводим 11 бит в десятичное число
TDRA = bin2dec(TDRA_bit); % Переводим 4 бита в десятичное число

result.FDRA = FDRA;
result.TDRA = TDRA;
result.VrbPrb = VrbPrb_bit;
result.modulation_and_coding_scheme = MACS_bit;
result.redundancy_Version = RV_bit;
result.sII = sII_bit;
result.reserved_bits = RB_bit;

dci_block = result;
end
