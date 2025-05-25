%% Initializing

clc; clear all; close all;

config = caseConfiguration('C',4,1,0);

channelBandwidth = 50;
startSFN = 6;
MIB = defineMib(startSFN ,0,0 , 0,[0 1 0 1 1 0 0 1] ,0 ,0);
NCRBSSB = 10; % number of common resource block containing first subcarrier of SS/PBCH block expressed in units assuming 15 kHz SCS (= offsetToPointA)
kSSB = 20; % offset to subcarrier 0 in NCRBSSB resource block expressed in subcarriers assuming 15 kHz SCS
NCellId = 250;
startHRF = 0;
fs = 50e6;
duration = 8e-3;

%param for dci from MIB
crc_type = 'crc24c';
% for DCI sequence
rbs_coreset = 48;   
ssb_offset_crst = 15; % from mib
duration_crst = 1; % for coreset 0 choose 1 or 2
AL = 4; % agregation level 
TDRA = 1;                        
VrbPrb = 0;                       
macs = 0;                        
rv = 0;                            
sII = 0b0;                        



coreset_config.start_symbol = 7; % начало с 4-го символа

%% Create halfframe (only for demonstration)
rg = createPbchHalfFrame('C', 4, channelBandwidth, NCellId, MIB, startSFN, startHRF, NCRBSSB, kSSB,[1 0.9 0.8 0.7]);

% Create PDCCH rg
rg_pdcch= createPdcchFrame(crc_type,rbs_coreset, TDRA, VrbPrb,macs,rv, sII, NCellId,ssb_offset_crst,duration_crst,AL);

% Сreate RG general
rg_general = rg + rg_pdcch.resourceGrid;

%% Resource grid painting
figure
plt = pcolor(abs(rg_general));
plt.EdgeColor = "none";
xlabel ('OFDM symbols');
ylabel  ("Subcarriers");

%% Signal generator

waveform = pbchSignalGenerator(fs,duration,mod(startSFN,16),0,'C',NCRBSSB,floor(mod(kSSB,16)/8),4,channelBandwidth,NCellId,MIB);

%% Signal painting
figure Name OFDM

samples = 1:length(waveform);
plot(samples, real(waveform));
tickShift = floor(length(waveform)/(50));
tickVals = tickShift * (0:floor(length(waveform)/tickShift));
xticks(tickVals)
xValsPrecision = 0.001;
xValsUnits = 1e-3; % for ms
xticklabels(num2str(ceil((tickVals/fs / xValsUnits / xValsPrecision).') * xValsPrecision))
xlabel('t, ms')
ylabel('Re[s(t)]');
disp('DONE');
