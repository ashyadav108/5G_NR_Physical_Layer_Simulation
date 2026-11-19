clc;
clear;
close all;

%% ===================================
% 5G NR PHYSICAL LAYER
% OFDM DEMODULATION
% ====================================

%% Configuration
M = 16;                 % 16-QAM
Nfft = 64;              % FFT size
cpLength = 16;         % Cyclic prefix
numOFDMsymbols = 100;

bitsPerSymbol = log2(M);

%% ===================================
% GENERATE TRANSMITTED QAM SYMBOLS
% ====================================

numQAMSymbols = Nfft * numOFDMsymbols;

numBits = numQAMSymbols * bitsPerSymbol;

txBits = randi([0 1], numBits, 1);

%% QAM Modulation

bitGroups = reshape(txBits, ...
    bitsPerSymbol, []).';

symbolIndices = bi2de( ...
    bitGroups, 'left-msb');

txQAM = qammod(symbolIndices, M, ...
    'UnitAveragePower', true);

%% ===================================
% OFDM MODULATION
% ====================================

ofdmGrid = reshape(txQAM, ...
    Nfft, numOFDMsymbols);

ofdmTime = ifft(ofdmGrid, Nfft, 1);

%% Add Cyclic Prefix

cyclicPrefix = ...
    ofdmTime(end-cpLength+1:end, :);

ofdmWithCP = ...
    [cyclicPrefix; ofdmTime];

%% Serial transmission signal

txSignal = ofdmWithCP(:);

%% ===================================
% OFDM DEMODULATION
% ====================================

% Reshape received signal into OFDM symbols

rxOFDM = reshape(txSignal, ...
    Nfft + cpLength, ...
    numOFDMsymbols);

%% Remove Cyclic Prefix

rxWithoutCP = ...
    rxOFDM(cpLength+1:end, :);

%% FFT

rxQAMGrid = ...
    fft(rxWithoutCP, Nfft, 1);

%% Convert to Serial

rxQAM = rxQAMGrid(:);

%% ===================================
% QAM DEMODULATION
% ====================================

rxSymbolIndices = qamdemod( ...
    rxQAM, M, ...
    'UnitAveragePower', true);

%% Convert Symbols to Bits

rxBitGroups = de2bi( ...
    rxSymbolIndices, ...
    bitsPerSymbol, ...
    'left-msb');

rxBits = rxBitGroups.';
rxBits = rxBits(:);

%% ===================================
% BER CALCULATION
% ====================================

numBitErrors = sum(txBits ~= rxBits);

BER = numBitErrors / length(txBits);

%% ===================================
% DISPLAY RESULTS
% ====================================

fprintf('===================================\n');
fprintf('5G NR PHYSICAL LAYER\n');
fprintf('OFDM DEMODULATION\n');
fprintf('===================================\n');

fprintf('Modulation order     : %d-QAM\n', M);
fprintf('FFT size             : %d\n', Nfft);
fprintf('Cyclic prefix length : %d samples\n', cpLength);
fprintf('OFDM symbols         : %d\n', ...
    numOFDMsymbols);

fprintf('\nTransmitted bits     : %d\n', ...
    length(txBits));

fprintf('Received bits        : %d\n', ...
    length(rxBits));

fprintf('Bit errors           : %d\n', ...
    numBitErrors);

fprintf('BER                  : %.6f\n', ...
    BER);

if BER == 0
    fprintf('\nOFDM modulation and demodulation verified successfully.\n');
else
    fprintf('\nBit errors detected.\n');
end