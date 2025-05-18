
% test 

% введём параметры для функции getDCI   unit test matlab, общий гит с 3-мя
% папками. что то у ребят с ofdm как то встроить
FDRA = 10;
TDRA = 1;
VrbPrb = 0;
modulation_and_coding_scheme = 0;
redundancy_Version = 0;
sII = 0b0;
reserved_bits = 0; % zeros(0,15)

% получим биты dci для формата format 1_0 в соответствие со стандартом
DM = getDCI(FDRA, TDRA, VrbPrb,modulation_and_coding_scheme,redundancy_Version,sII, reserved_bits);


% закодируем биты полезной нагрузки 38.212 с использование CRC attachment (раздел 7.3.2),
% Channel coding (7.3.3), Rate mathcing (раздел 7.3.4).
crc_type = 'crc24c';

codeword = Encode_DCI(DM,crc_type);

bit_string = '10100001000000000000000000000000';
bit_vector = double(bit_string') - '0';  % Преобразуем в числовой вектор-столбец




% Get the PDCCH QPSK symbols nrPDCCH

nID = 2;  % задать у ребят 250
n_RNTI = 1; % задано стандартом 65535
symbols = get_pdcch_symbols(codeword, nID, n_RNTI);

symbols_2 = nrDCIEncode(bit_vector,n_RNTI, 2*length(DM));
isequal(codeword, symbols_2)
%               ПОЛУЧИМ ИСХОДНЫЕ БИТЫ DCI
% Необходимо воплотить функцию nrPDCCHDecode и получить из qpsk символов
% codeword
% Для этого: 1 - демодуляция; 2 - дескремблирование 

received_codeword = de_get_pdcch_symbols(symbols, nID, n_RNTI);

isequal(codeword, received_codeword)  % проверка на совпадение codeword

% Произведём декодирование последовательности DCI.
%get_DM = Decode_DCI(received_codeword, crc_type);

%isequal(get_DM, DM)

% Необходимо произвести слепое декодирование битов DCI 
% ещё не готово
%decode_dci = decode_payload(nID, n_RNTI);

