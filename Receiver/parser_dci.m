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

RIV = bin2dec(FDRA_bit); % Переводим 11 бит в десятичное число
FDRA = length(FDRA_bit);
TDRA = bin2dec(TDRA_bit); % Переводим 4 бита в десятичное число

result.FDRA = FDRA;
result.TDRA = TDRA;
result.VrbPrb = VrbPrb_bit;
result.modulation_and_coding_scheme = MACS_bit;
result.redundancy_Version = RV_bit;
result.sII = sII_bit;
result.reserved_bits = RB_bit;

dci_block = result;

disp(dci_block)

if dci_block.VrbPrb == '0'
    disp('VrbPrb = 0. Non_interleaved');
else 
    disp('VrbPrb = 1. interleaved');
end

if dci_block.sII == '0'
    disp('sII = 0. SIB 1');
else
    disp('sII = 1. SI messages');
end
end
