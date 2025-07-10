% функция coreset pdcch mapping 
function [resource_grid,coreset_config] = fun_mapping(coreset_config, symbols,...
    AL,NCellId)
arguments
    coreset_config
    symbols % qpsk pdcch 
    AL
    NCellId
    % можно будет добавить данные из SSB
end
    % 1. Для coreset 0 необходимы параметры из MIB

    %coreset_config.rbs = rbs_coreset; 
    %coreset_config.ssb_offset = ssb_offset_crst; 
    %coreset_config.duration = duration_crst; 
    %coreset_config.num_cces = AL;

    %coreset_config.start_symbol = 7; % начало с 4-го символа

    % 2. Произведём маппирование coreset 
    ssb_end_rb = 25; % отыскать! ПОКА ЧТО КОСТЫЛЬ

    coreset0_pos = calculate_coreset0_pos(coreset_config.ssb_offset_crst, coreset_config.size_rbs,ssb_end_rb);
    % расчёт позиции coreset на ресурсной сетке
    coreset_config.freq_range = [coreset0_pos(1),coreset0_pos(length(coreset0_pos))]; % берём первый и последний символ

    % 3. Зададим параметры SSB - заменить на параметры ребят
    slot_num = 1;
    symbol_num = 7;
    num_rb = coreset_config.freq_range(2) - coreset_config.freq_range(1) + 1;    

    % 4. Получим ресурсную сетку
    resource_grid = map_pdcch(symbols, coreset_config,NCellId,slot_num,symbol_num,num_rb); % маппирование PDCCH на ресурсную сетку 
end

% Функция расчёта позиции coreset в частотной области
function coreset_rbs = calculate_coreset0_pos(ssb_offset_crst, size_rbs,ssb_end_rb)
    % ssb_offset: смещение поднесущих SSB (из MIB)
    % coreset_rbs: число RB в CORESET0 
    % CORESET0 начинается после смещения
    coreset_start_rb = floor((ssb_offset_crst + ssb_end_rb)); % Смещение в RB 
    coreset_rbs = coreset_start_rb : coreset_start_rb + (size_rbs)/1- 1;
end

% Функция dmrs
function dmrs = generate_pdcch_dmrs(NCellId, slot_num, symbol_num,num_rb)
    c_init = mod(2^17 * (14 * slot_num + symbol_num + 1) * (2 * NCellId + 1) + 2*NCellId,2^31);
    % 2. Генерация последовательности для всех REG в символе
    num_reg_per_rb = 1; % 1 REG на RB в частотной области
    total_dmrs = 3 * num_rb * num_reg_per_rb; % 3 DM-RS на REG

    % Генерация псевдослучайной последовательности (6 бит для 3 QPSK-символов)
    c = get_sequence(zeros(1, 2*total_dmrs), c_init); % 2 бита на qpsk символ
    dmrs = (1/sqrt(2)) * ((1 - 2 * c(1:2:end)) + 1i * (1 - 2 * c(2:2:end)));
end


% Функция маппирования на ресурсную сетку PDCCH
function resource_grid = map_pdcch(symbols, coreset_config,NCellId,slot_num,symbol_num,num_rb)
           % Create resource grid
            NGridSize = 100;
            mu =1;
            resource_grid = ResourceMapper(NGridSize,nrCom.Nsymb_slot*nrCom.Nslot_frame(mu));
            
    % 2. Генерация DM-RS для каждого символа в CORESET
    for sym = coreset_config.start_symbol -1 : coreset_config.start_symbol + coreset_config.duration - 2
        % 2.1. Рассчитываем c_init для DM-RS (TS 38.211 Sec. 7.4.1.3.1)
        dmrs_symbols = generate_pdcch_dmrs(NCellId, slot_num, symbol_num,num_rb);

        % 2.4. Размещение DM-RS в ресурсной сетке
        dmrs_idx = 1;
        for rb = coreset_config.freq_range(1) : coreset_config.freq_range(2)
            for k = 1:12
                if mod(k-1, 4) == 0 % Позиции DM-RS: k = 1, 5, 9
                    re_pos = rb * 12 + k;
                    resource_grid.resource_grid(re_pos, sym + 1) = dmrs_symbols(dmrs_idx);
                    dmrs_idx = dmrs_idx + 1;
                end
            end
        end
    end


    % 3. Заполнение PDCCH в CORESET
    reg_idx = 0;
    for rb = coreset_config.freq_range(1) : coreset_config.freq_range(2)
        for sym = coreset_config.start_symbol -1 : coreset_config.start_symbol + coreset_config.duration - 2
            
            % Размещение 9 QPSK-символов на REG (исключая DM-RS)
            re_in_reg = 1;
            for k = 1:12
                if mod(k-1, 4) ~= 0 % Не DM-RS
                    re_pos = rb * 12 + k;
                    resource_grid.resource_grid(re_pos, sym + 1) = symbols(reg_idx * 9 + re_in_reg);
                    re_in_reg = re_in_reg + 1;
                end
            end
            reg_idx = reg_idx + 1;
        end
    end
end