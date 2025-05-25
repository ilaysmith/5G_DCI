function tests=get_pdcch_symbols_test
    tests = functiontests(localfunctions);
end
function setupOnce(~)
    cd ../
end
function teardownOnce(~)
    cd Tests
end


function randTest(tc)
nID = 2;  % задать у ребят 250
n_RNTI = 1; % задано стандартом 65535
    for i=1:100
        data=randi([0,1],1,864);
        recovered=de_get_pdcch_symbols(get_pdcch_symbols(data,1,2),1,2);
        verifyEqual(tc,recovered,data);
    end
end