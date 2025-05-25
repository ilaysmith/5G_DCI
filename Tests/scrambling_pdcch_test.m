function tests=scrambling_pdcch_test
    tests = functiontests(localfunctions);
end
function setupOnce(~)
    cd ../
end
function teardownOnce(~)
    cd Tests
end


function randTest(tc)
nID = 2;  
n_RNTI = 1; 
    for i=1:100
        data=randi([0,1],1,864);
        recovered=de_scrambling_pdcch(scrambling_pdcch(data,n_RNTI,nID),n_RNTI,nID);
        verifyEqual(tc,recovered,data);
    end
end