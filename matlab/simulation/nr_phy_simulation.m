clc;
clear;
close all;

%% ===================================
% 5G NR PHYSICAL LAYER SIMULATION
% ====================================

%% Configuration

M = 16;                     % 16-QAM
Nfft = 64;                  % FFT size
cpLength = 16;              % Cyclic prefix
numOFDMsymbols = 100;       % OFDM symbols

SNR_dB = 0:5:20;            % SNR range
numRealizations = 50;       % Channel realizations

bitsPerSymbol = log2(M);

%% Result Storage

BER = zeros(size(SNR_dB));

%% ===================================
% DISPLAY CONFIGURATION
% ====================================

fprintf('===================================\n');
fprintf('5G NR PHYSICAL LAYER SIMULATION\n');
fprintf('===================================\n');

fprintf('Modulation       : %d-QAM\n', M);
fprintf('FFT size         : %d\n', Nfft);
fprintf('Cyclic prefix    : %d samples\n', cpLength);
fprintf('SNR range        : %d to %d dB\n', ...
    SNR_dB(1), SNR_dB(end));
fprintf('Channel model    : Rayleigh fading + AWGN\n');
fprintf('Channel runs     : %d per SNR\n', ...
    numRealizations);

%% ===================================
% MAIN SNR LOOP
% ====================================

for s = 1:length(SNR_dB)

    snr = SNR_dB(s);

    totalErrors = 0;
    totalBits = 0;

    fprintf('\n-----------------------------------\n');
    fprintf('SNR = %d dB\n', snr);
    fprintf('-----------------------------------\n');

    %% Channel Realizations

    for r = 1:numRealizations

        %% ===================================
        % TRANSMITTER
        % ====================================

        %% Generate random bits

        numQAMSymbols = ...
            Nfft * numOFDMsymbols;

        numBits = ...
            numQAMSymbols * bitsPerSymbol;

        txBits = randi([0 1], ...
            numBits, 1);

        %% ===================================
        % 16-QAM MODULATION
        % ====================================

        bitGroups = reshape( ...
            txBits, ...
            bitsPerSymbol, []).';

        symbolIndices = bi2de( ...
            bitGroups, ...
            'left-msb');

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

        %% Convert to serial signal

        txSignal = ofdmWithCP(:);

        %% ===================================
        % RAYLEIGH FADING CHANNEL
        % ====================================

        h = (randn + 1j*randn) / sqrt(2);

        fadedSignal = ...
            h * txSignal;

        %% ===================================
        % AWGN
        % ====================================

        signalPower = ...
            mean(abs(fadedSignal).^2);

        snrLinear = ...
            10^(snr/10);

        noisePower = ...
            signalPower / snrLinear;

        noise = sqrt(noisePower/2) * ...
            (randn(size(fadedSignal)) + ...
             1j*randn(size(fadedSignal)));

        rxSignal = ...
            fadedSignal + noise;

        %% ===================================
        % RECEIVER
        % ====================================

        %% Reshape OFDM symbols

        rxOFDM = reshape( ...
            rxSignal, ...
            Nfft + cpLength, ...
            numOFDMsymbols);

        %% Remove cyclic prefix

        rxWithoutCP = ...
            rxOFDM(cpLength+1:end, :);

        %% ===================================
        % OFDM DEMODULATION
        % ====================================

        rxQAMGrid = ...
            fft(rxWithoutCP, Nfft, 1);

        %% Convert to serial

        rxQAM = rxQAMGrid(:);

        %% ===================================
        % CHANNEL EQUALIZATION
        % ====================================

        % Compensate for Rayleigh fading

        rxEqualized = ...
            rxQAM / h;

        %% ===================================
        % 16-QAM DEMODULATION
        % ====================================

        rxSymbolIndices = ...
            qamdemod( ...
                rxEqualized, ...
                M, ...
                'UnitAveragePower', true);

        %% Convert symbols to bits

        rxBitGroups = ...
            de2bi( ...
                rxSymbolIndices, ...
                bitsPerSymbol, ...
                'left-msb');

        rxBits = ...
            rxBitGroups.';

        rxBits = rxBits(:);

        %% ===================================
        % BER
        % ====================================

        bitErrors = ...
            sum(txBits ~= rxBits);

        totalErrors = ...
            totalErrors + bitErrors;

        totalBits = ...
            totalBits + length(txBits);

    end

    %% Average BER

    BER(s) = ...
        totalErrors / totalBits;

    fprintf('Total bits   : %d\n', totalBits);
    fprintf('Bit errors   : %d\n', totalErrors);
    fprintf('BER          : %.6e\n', BER(s));

end

%% ===================================
% FINAL RESULTS
% ====================================

fprintf('\n\n===================================\n');
fprintf('FINAL BER RESULTS\n');
fprintf('===================================\n');

fprintf('\nSNR (dB)        BER\n');
fprintf('-------------------------\n');

for s = 1:length(SNR_dB)

    fprintf('%6d       %.6e\n', ...
        SNR_dB(s), BER(s));

end

%% ===================================
% BER PLOT
% ====================================

figure;

semilogy(SNR_dB, BER, '-o', ...
    'LineWidth', 1.5);

xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');

title('5G NR PHY BER Performance - 16-QAM OFDM');

grid on;

%% ===================================
% SAVE RESULTS
% ====================================

resultsDir = '../../results';

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

save(fullfile(resultsDir, ...
    'nr_phy_results.mat'), ...
    'SNR_dB', ...
    'BER', ...
    'M', ...
    'Nfft', ...
    'cpLength', ...
    'numOFDMsymbols', ...
    'numRealizations');

fprintf('\n===================================\n');
fprintf('SIMULATION COMPLETED SUCCESSFULLY\n');
fprintf('===================================\n');

fprintf('Results saved to:\n');
fprintf('%s\n', ...
    fullfile(resultsDir, ...
    'nr_phy_results.mat'));