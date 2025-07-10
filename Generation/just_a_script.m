clc;close;clear;

NRB=100;
%% Usefull
% Downlink configuration
cfgDL = nrDLCarrierConfig;
cfgDL.Label = 'Carrier1';
cfgDL.FrequencyRange = 'FR1';
cfgDL.ChannelBandwidth = 60;
cfgDL.NCellID = 17;
cfgDL.NumSubframes = 10;
cfgDL.InitialNSubframe = 0;
cfgDL.WindowingPercent = 0;
cfgDL.SampleRate = [];
cfgDL.CarrierFrequency = 4e9;

% SCS specific carriers
scscarrier = nrSCSCarrierConfig;
scscarrier.SubcarrierSpacing = 30;
scscarrier.NSizeGrid = NRB;
scscarrier.NStartGrid = 3;

cfgDL.SCSCarriers = {scscarrier};

% Bandwidth Parts
bwp = nrWavegenBWPConfig;
bwp.BandwidthPartID = 1;
bwp.Label = 'BWP1';
bwp.SubcarrierSpacing = 30;
bwp.CyclicPrefix = 'normal';
bwp.NSizeBWP = NRB;
bwp.NStartBWP = 3;

cfgDL.BandwidthParts = {bwp};

% Synchronization Signals Burst
ssburst = nrWavegenSSBurstConfig;
ssburst.Enable = true;
ssburst.Power = 0;
ssburst.BlockPattern = 'Case B';
ssburst.TransmittedBlocks = ones([1 8]);
ssburst.Period = 20;
ssburst.NCRBSSB = 19;
ssburst.KSSB = 0;
ssburst.DataSource = 'MIB';
ssburst.DMRSTypeAPosition = 2;
ssburst.CellBarred = false;
ssburst.IntraFreqReselection = false;
ssburst.PDCCHConfigSIB1 = 254;
ssburst.SubcarrierSpacingCommon = 15;

cfgDL.SSBurst = ssburst;
%% SUPER IMPORTANT
cfgDL.CSIRS{1}.Enable=false;
cfgDL.PDSCH{1}.Enable=false;
cfgDL.PDCCH{1}.Enable=false;
%% Generation
[toolbox_waveform,info] = nrWaveformGenerator(cfgDL);

Fs = info.ResourceGrids(1).Info.SampleRate;

%%

mib=struct();
mib.SFN=0;
mib.subCarrierSpacingCommon=nrCom.SCSCommon.scs15or60;
mib.dmrsTypeAPosition=nrCom.DmrsTypeAPosition.pos2;
mib.pdcch_ConfigSIB1=254;
mib.cellBarred=nrCom.CellBared.notBarred;
mib.intraFreqReselection=nrCom.IntraFreqReselection.notAllowed;
[rg,dbg]=createFrame( ...
    round(log2(scscarrier.SubcarrierSpacing/15)), ...
    NRB, ...
    ssburst.KSSB, ...
    bwp.NStartBWP, ...
    ssburst.NCRBSSB,...
    cfgDL.NCellID, ...
    ones(1,8), ...
    'B', ...
    cfgDL.CarrierFrequency,...
    mib, ...
    0);


% DCI
%param for dci from MIB
crc_type = 'crc24c';
% for DCI sequence
AL = 4; % agregation level     
NCellId = 17;
n_RNTI = 65535; % задано стандартом 65535
% param for sib1
LRbs_sib1 = 10; % length allocated resource blocks
RBstart_sib1 = 30; % Start RB for SIB1

dci_config = struct(); % size_rbs for Frequence domain resource assigments
dci_config.TDRA = 1; % Time domain resource assigments
dci_config.VrbPrb = 0; % VRB-PRB mapping. Non-Interleaved for coreset 0
dci_config.macs = 0; % modulation and coding scheme
dci_config.rv = 0; % redundancy Version.
dci_config.sII = 0; % System Information Indicator. SIB 1

coreset_config = struct(); % coreset config

% RG PDCCH
[rg_pdcch,symbols,coreset_config,dci_config] = createPdcchFrame(crc_type,coreset_config,dci_config,...
    NCellId, AL, mib.pdcch_ConfigSIB1,LRbs_sib1,RBstart_sib1);

% SIB1
dmrsTypeAPosition = 2; % pos2 (For Sib1 + TDRA)
codeword_sib1 = get_sib1_codeword(dci_config,coreset_config,dmrsTypeAPosition); % get sib1 codeword

sib1_config = struct(); % sib1 config

rg_pdsch = createPdschFrame(coreset_config,dci_config,sib1_config,codeword_sib1,...
    NCellId,n_RNTI,dmrsTypeAPosition);

% RG GENERAL
rg_general = rg + rg_pdcch.resource_grid + rg_pdsch.resource_grid;
%%
figure
subplot(1,2,2)
pcolor(abs(rg_general)); shading flat;
title("MODEL FRAME RG")
subplot(1,2,1)
pcolor(abs(nrOFDMDemodulate(toolbox_waveform,NRB,15,0))); shading flat;
title("MATLAB TOOLBOX RG")
%%

waveform=ofdmModulator(rg_general,bwp.NStartBWP,round(log2(scscarrier.SubcarrierSpacing/15)),0);

received=ofdmDemodulator( ...
    waveform, ...
    2048*15000*2^round(log2(scscarrier.SubcarrierSpacing/15)), ...
    NRB, ...
    round(log2(scscarrier.SubcarrierSpacing/15)), ...
    0);
% 
% received=ofdmDemodulator( ...
%     toolbox_waveform, ...
%     Fs, ...
%     NRB, ...
%     round(log2(scscarrier.SubcarrierSpacing/15)), ...
%     0);

% received=ofdmDemodulator( ...
%     load("waveStruct.mat","waveStruct").waveStruct.waveform, ...
%     Fs, ...
%     NRB, ...
%     round(log2(scscarrier.SubcarrierSpacing/15)), ...
%     0);



% received=nrOFDMDemodulate(toolbox_waveform,NRB,scscarrier.SubcarrierSpacing,0,"Nfft",2048);
%%

figure
subplot(1,2,1)
pcolor(abs(rg_general)); shading flat;
title("SOURCE RG")
subplot(1,2,2)
pcolor(abs(received)); shading flat;
title("DEMODULATED RG")
%%
% close
k0=79;
l0=5;
% ssb=received(k0:k0+239,l0:l0+4);
ssb=received(k0:k0+239,l0:l0+4-1);
%pdcch = received(k0+402:k0+689,l0+2:l0+4-1); % 481 - 768 + 1
%проверка на pdcch
pdcch = received(k0+402:k0+689,l0+2:l0+4-1);

%figure;pcolor(abs(rg_general(k0:k0+239,l0:l0+4)));shading flat;xlim([1,5])
%title("SSB");
% PDCCH
%figure;pcolor(abs(rg_general(k0+239:k0+780,l0+1:l0+5)));shading flat;xlim([1,5])
%title("PDCCH");
%%
[~,Lbarmax]=nrCom.blocksByCase('B',cfgDL.CarrierFrequency,0);
[sym,dmrs]=parseSsb(ssb,0,0,cfgDL.NCellID);

pbch=qpskDemodulate(sym);

ibarSsb=extractBlockIndex(dmrs,cfgDL.NCellID);
pbch=scramblePbch(pbch,cfgDL.NCellID,Lbarmax,ibarSsb);
pbch=rateRecovery(pbch);
pbch=polarDecoding(pbch);
[pbch,validation_success]=verifyParity(pbch,nrCom.CrcType.crc24c);
pbch=scramblePbchPayload(pbch,cfgDL.NCellID,Lbarmax);
pbch=deinterleavePbchPayload(pbch);
pld=parsePayload(pbch,Lbarmax);
disp(pld);

% parse for pdcch
%[sym_p, dmrs_p] = parsePdcch(pdcch, 0, 0,cfgDL.NCellID);
[pdcch_symbols_rev,dmrs_symbols_pdcch] = de_mapping(received, coreset_config);
symbols_received = pdcch_symbols_rev.'; % 432
%isequal(symbols,symbols_received) % почему ноль? 
% dmrs pdcch
dmrs_pdcch = dmrs_symbols_pdcch.'; % 144
% 48rbs = 48 * 12 = 576. 576 - 144 = 432 -> каждый 4-ый

% вытащим закодированные биты из qpsk
received_codeword = de_get_pdcch_symbols(symbols_received, cfgDL.NCellID, n_RNTI);

% Произведём декодирование последовательности DCI.
get_DM = Decode_DCI(received_codeword, crc_type);

dci_block = parser_dci(get_DM); % parser_dci
%disp(dci_block)

% SIB1
%de_mapping sib1
%de_get_pdcch_symbols_sib1
%decode_sib1
% parser_sib1


%% %
% corr=xcorr(waveform,toolbox_waveform,'normalized');
% 
% plot(abs(corr))
% 
% 
