 % function scramble sequence 38.211 5.2.1 + 7.3.2.3
 function sequence = fun_pbrs(codeword, cinit)
arguments 
       codeword
       cinit
end

    % определим x1  - нули и одна единица и x2 - cinit
    L_bit = length(codeword); % длина входящей последовательности
    x1 = zeros(1,31);
    x1(1) = 1;

    x2 = zeros(1,31);

    for i = 0:30
        x2(i+1) = bitand(bitshift(cinit, -i), 1); % перевод cinit в биты
    end

    sequence = zeros(1,L_bit + 1600); % длина последовательности с учётом сдвига, который будем использовать дальше

    % генерация последовательности с начальным сдвигом Nc

    for n = 1:(L_bit + 1600 - 31)
        x1(n+31) = mod((x1(n+3) + x1(n)),2);
        x2(n+31) = mod((x2(n+3) + x2(n+2) + x2(n+1) + x2(n)),2);
    end

    % комбинируем последовательность 

    for n = 1:L_bit
        sequence(n) = mod((x1(n + 1600) + x2(n + 1600)),2);
    end

    sequence = sequence(1:L_bit); % убираем мусорные биты и оставляем только полезные

end