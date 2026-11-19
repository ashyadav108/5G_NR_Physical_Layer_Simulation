clc;
clear;
close all;

%% ===================================
% 5G NR PHYSICAL LAYER
% WIRELESS CHANNEL MODEL
% ====================================

%% Configuration
M = 16;                 % 16-QAM
Nfft = 64;              % FFT size
cpLength = 16;         % Cyclic prefix
numOFDMsymbols = 100;

SNR_dB = 10;            % Channel SNR

bitsPerSymbol = log2(M);

%% ===================================
% TRANSMITTER
% ====================================

numQAMSymbols = ...
    Nfft * numOFDMsymbols;

numBits = ...
    numQAMSymbols * bitsPerSymbol;

%% Generate random bits

txBits = randi([0 1], ...
    numBits, 1);

%% QAM modulation

bitGroups = reshape( ...
    txBits, ...
    bitsPerSymbol, []).';

symbolIndices = bi2de( ...
    bitGroups, 'left-msb');

txQAM = qammod( ...
    symbolIndices, ...
    M, ...
    'UnitAveragePower', true);

%% ===================================
% OFDM MODULATION
% ====================================

ofdmGrid = reshape( ...
    txQAM, ...
    Nfft, ...
    numOFDMsymbols);

ofdmTime = ifft( ...
    ofdmGrid, ...
    Nfft, 1);

%% Add cyclic prefix

cyclicPrefix = ...
    ofdmTime(end-cpLength+1:end, :);

ofdmWithCP = ...
    [cyclicPrefix; ofdmTime];

%% Serial signal

txSignal = ofdmWithCP(:);

%% ===================================
% RAYLEIGH FADING CHANNEL
% ====================================

% Generate complex Rayleigh fading coefficient

h = (randn + 1j*randn) / sqrt(2);

%% Apply fading

fadedSignal = h * txSignal;

%% ===================================
% AWGN CHANNEL
% ====================================

signalPower = mean(abs(fadedSignal).^2);

SNR_linear = ...
    10^(SNR_dB/10);

noisePower = ...
    signalPower / SNR_linear;

noise = sqrt(noisePower/2) * ...
    (randn(size(fadedSignal)) + ...
     1j*randn(size(fadedSignal)));

rxSignal = ...
    fadedSignal + noise;

%% ===================================
% DISPLAY RESULTS
% ====================================

fprintf('===================================\n');
fprintf('5G NR PHYSICAL LAYER\n');
fprintf('WIRELESS CHANNEL MODEL\n');
fprintf('===================================\n');

fprintf('Modulation order : %d-QAM\n', M);
fprintf('FFT size         : %d\n', Nfft);
fprintf('Cyclic prefix    : %d samples\n', cpLength);

fprintf('SNR               : %d dB\n', SNR_dB);

fprintf('\nChannel coefficient:\n');
fprintf('Real(h)           : %.4f\n', real(h));
fprintf('Imaginary(h)      : %.4f\n', imag(h));

fprintf('\nTransmit signal power : %.6e\n', ...
    signalPower);

fprintf('Noise power           : %.6e\n', ...
    noisePower);

fprintf('\nReceived signal generated successfully.\n');
fprintf('Rayleigh fading + AWGN channel completed.\n');