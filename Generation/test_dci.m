
% test 
%function resource_grid = test_dci(crc_type)
%arguments 
%    crc_type
%end

% введём параметры для функции getDCI   unit test matlab, общий гит с 3-мя
% папками. что то у ребят с ofdm как то встроить
% denote getDCI parameters
FDRA = 11;
TDRA = 1;
VrbPrb = 0;
modulation_and_coding_scheme = 0;
redundancy_Version = 0;
SII = 0;
ReservedBits = zeros(1,15);

% get dci format 1_0 according to the TS
DM = genDCI(FDRA, TDRA, VrbPrb,modulation_and_coding_scheme,redundancy_Version, SII,ReservedBits);

% закодируем биты полезной нагрузки 38.212 с использование CRC attachment (раздел 7.3.2),
% Channel coding (7.3.3), Rate mathcing (раздел 7.3.4).
crc_type = 'crc24c';

codeword = Encode_DCI(DM,crc_type);

% попытка сравнения с функция nrDCIEncode
bit_string = '10100001000000000000000000000000';
bit_vector = double(bit_string') - '0';  % Преобразуем в числовой вектор-столбец

% Get the PDCCH QPSK symbols nrPDCCH

nID = 2;  % задать у ребят 250
n_RNTI = 1; % задано стандартом 65535
symbols = get_pdcch_symbols(codeword, nID, n_RNTI);

%symbols_2 = nrDCIEncode(bit_vector,n_RNTI, 2*length(DM)); % третий параметр не такой!
%isequal(codeword, symbols_2) % пока неудачно


%%% ВПИШЕМ СЮДА МАППИНГ
rbs_coreset = 48;
ssb_offset_crst = 15;
duration_crst = 2;
AL =4;
[resource_grid,coreset_config] = fun_mapping(symbols,rbs_coreset,ssb_offset_crst,duration_crst,AL,nID);

    % Визуализация
   %figure
  %plt = pcolor(abs(resource_grid.resourceGrid));
  % plt.EdgeColor = "none";
   %xlabel ('OFDM symbols');
 % ylabel  ("Subcarriers");
  %end



%               ПОЛУЧИМ ИСХОДНЫЕ БИТЫ DCI
% Необходимо воплотить функцию nrPDCCHDecode и получить из qpsk символов
% codeword
% Для этого: 1 - демодуляция; 2 - дескремблирование 


%%% ВЫТАЩИМ QPSK SYMBOLS PDCCH 

pdcch_symbols_rev = de_mapping(resource_grid, nID, n_RNTI,coreset_config).';
isequal(symbols,pdcch_symbols_rev) % совпали №1



% вытащим закодированные биты из qpsk
received_codeword = de_get_pdcch_symbols(pdcch_symbols_rev, nID, n_RNTI);

% проверка на совпадение codeword - удачно
isequal(codeword, received_codeword) % совпали №2

%Произведём декодирование последовательности DCI.
get_DM = Decode_DCI(received_codeword, crc_type);

isequal(get_DM, DM) % ура совпадает #3


                 % Сделаем вид, что декодирование успешно
%any_bits = DM; % якобы получили то же самое - нет необходимости

any_bits= get_DM;
dci_block = parser_dci(any_bits); % parser_dci
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

% Необходимо произвести слепое декодирование битов DCI 
% ещё не готово
%decode_dci = decode_payload(nID, n_RNTI);

% генерация dci и маппирование dci. как действительно лежит pdcch и coreset
% 0





