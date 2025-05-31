function [pdcch_symbols] = de_mapping(resource_grid, nID,coreset_config)
    % 1. Извлечение RE PDCCH из CORESET

    pdcch_symbols = extract_pdcch_from_coreset(resource_grid, coreset_config);
  
end

function pdcch_symbols = extract_pdcch_from_coreset(resource_grid, coreset_config)

    pdcch_symbols = []; 
    reg_count = 0;
   % coreset_config.freq_range(1) = 40;
   % coreset_config.freq_range(2) = 63;
    %coreset_config.start_symbol = 7;
   % coreset_config.duration = 2;
    
    % Non-interleaved маппинг (для CORESET0)
    for rb = coreset_config.freq_range(1) : coreset_config.freq_range(2)
        for sym = coreset_config.start_symbol -1 : coreset_config.start_symbol + coreset_config.duration - 2
           
            % Извлечение 9 полезных RE из REG (исключая DM-RS)
            re_in_reg = [];
            for sc = 1:12
                if mod(sc-1, 4) ~= 0 % Не DM-RS
                    re_pos = rb * 12 + sc;
                    re_in_reg = [re_in_reg; resource_grid(re_pos, sym + 1)];
                end
            end
            pdcch_symbols = [pdcch_symbols; re_in_reg];
            reg_count = reg_count + 1;
        end
    end
end