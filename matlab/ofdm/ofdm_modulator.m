clc;
clear;
close all;

%% ===================================
% 5G NR PHYSICAL LAYER
% OFDM MODULATION
% ====================================

%% Configuration
M = 16;                 % 16-QAM
Nfft = 64;              % Number of OFDM subcarriers
cpLength = 16;         % Cyclic prefix length
numOFDMsymbols = 100;  % Number of OFDM symbols

bitsPerSymbol = log2(M);

%% Generate Random QAM Symbols
numQAMSymbols = Nfft * numOFDMsymbols;

numBits = numQAMSymbols * bitsPerSymbol;

txBits = randi([0 1], numBits, 1);

%% Convert Bits to QAM Symbols
bitGroups = reshape(txBits, bitsPerSymbol, []).';

symbolIndices = bi2de(bitGroups, 'left-msb');

txQAM = qammod(symbolIndices, M, ...
    'UnitAveragePower', true);

%% Arrange Symbols into OFDM Blocks
ofdmGrid = reshape(txQAM, Nfft, ...
    numOFDMsymbols);

%% ===================================
% IFFT
% ====================================

ofdmTime = ifft(ofdmGrid, Nfft, 1);

%% ===================================
% ADD CYCLIC PREFIX
% ====================================

cyclicPrefix = ...
    ofdmTime(end-cpLength+1:end, :);

ofdmWithCP = ...
    [cyclicPrefix; ofdmTime];

%% Convert to Serial Signal
txSignal = ofdmWithCP(:);

%% ===================================
% DISPLAY RESULTS
% ====================================

fprintf('===================================\n');
fprintf('5G NR PHYSICAL LAYER\n');
fprintf('OFDM MODULATION\n');
fprintf('===================================\n');

fprintf('Modulation order     : %d-QAM\n', M);
fprintf('FFT size             : %d\n', Nfft);
fprintf('Cyclic prefix length : %d samples\n', cpLength);
fprintf('OFDM symbols         : %d\n', ...
    numOFDMsymbols);

fprintf('QAM symbols          : %d\n', ...
    numQAMSymbols);

fprintf('Input bits           : %d\n', ...
    numBits);

fprintf('OFDM samples/symbol  : %d\n', ...
    Nfft + cpLength);

fprintf('Total transmitted samples: %d\n', ...
    length(txSignal));

fprintf('\nAverage OFDM signal power: %.4f\n', ...
    mean(abs(txSignal).^2));

fprintf('\nOFDM modulation completed successfully.\n');

%% ===================================
% TIME-DOMAIN OFDM SIGNAL
% ====================================

figure;

plot(real(txSignal(1:300)));

xlabel('Sample Index');
ylabel('Amplitude');

title('OFDM Time-Domain Signal');

grid on;