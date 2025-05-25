classdef SsSignals
    properties
    pss
    sss
    NCellId
    end
    % SsGenerator generates PSS and SSS
    methods
        function obj = SsSignals(NCellId)
            % returns sync signals for NCellId
            arguments
                NCellId (1,1)
                % physical layer cell identity; see [38.211,7.4.2.1]
            end
            obj.NCellId = NCellId;
            
            % generate PSS
            m_seq = mSequence(7, [0, 1, 1, 0, 1, 1, 1],[0,1,0,0,0,1,0,0]);
            obj.pss = zeros([1 127]); 
            for n = 0:126 
                m =  mod(n + 43 * mod(NCellId, 3), 127) + 1; 
                obj.pss(n+1) = 1 - 2 * m_seq(m);     
            end
            
            % generate SSS

            % computing M-seq.
            x0=mSequence(7,[1,0,0,0,0,0,0],[0,1,0,0,0,1,0,0]);
            x1=mSequence(7,[1,0,0,0,0,0,0],[0,1,1,0,0,0,0,0]);

            % extracting ID's from NCellID
            Nid2=mod(NCellId,3);
            Nid1=floor(NCellId/3);
            
            % memory allocation
            obj.sss=zeros(1,127);

            % computing array
            for n=0:126
                % index of shift for the 1st M-seq
                m0=15*floor(Nid1/112)+5*Nid2;
                % same for 2nd
                m1=mod(Nid1,112);
                
                % shifting indexes
                m0=mod(m0+n,127);
                m1=mod(m1+n,127);

                % computing code according to indexes
                obj.sss(n+1)=(1-2*x0(m0+1))*(1-2*x1(m1+1));
            end
        end
    end
end