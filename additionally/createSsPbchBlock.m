function ssPbchBlock = createSsPbchBlock(ss, pbch, dmrs, NCellId, beta)
% creates 240x4 SS/PBCH block [TS 38.211, 7.4.3]           
    
    arguments
    ss % synchronisation signals object of SsSignals class
    pbch (1,432) % 432 bits of scrambled qpsk-modulated PBCH bit sequence
    dmrs (1,144) % PBCH Dm-Rs bit sequence
    NCellId (1,1) % cell identificator (0...1007)
    beta (1,4) = [1 1 1 1] % power allocation scaling factor [pssVal ssVal pbchVal dmrsVal]
    end
    
    ssPbchBlock = zeros(240,4);
    
    % SS mapping 
    ssPbchBlock(57:183,1) = beta(1) * ss.pss; % mapping PSS
    ssPbchBlock(57:183,3) = beta(2) * ss.sss; % mapping SSS
    
    % PBCH mapping
    nu=mod(NCellId,4); % nu parameter for shift of DM-RS
    
    % indexes reserved for Dm-Rs
    idxs13=(0:4:236)+nu; 
    idxs2=[(0:4:44)+nu, (192:4:236)+nu];
    r=0;
    for k=0:239
        if ~any(k==idxs13)
            ssPbchBlock(k+1,2)=pbch(r+1)*beta(3);
            r=r+1;
        end
    end
    for k=[0:47, 192:239]
        if  ~any(k==idxs2)
            ssPbchBlock(k+1,3)=pbch(r+1)*beta(3);
            r=r+1;
        end
    end
    for k=0:239
        if ~any(k==idxs13)
            ssPbchBlock(k+1,4)=pbch(r+1)*beta(3);
            r=r+1;
        end
    end
    
    
    % PBCH DM-RS MAPPING
    
    ssPbchBlock(idxs13+1,1+1) = dmrs(1:60)*beta(4);
    ssPbchBlock(idxs2+1,2+1) = dmrs(61:84)*beta(4);
    ssPbchBlock(idxs13+1,3+1) = dmrs(85:144)*beta(4);
    
end