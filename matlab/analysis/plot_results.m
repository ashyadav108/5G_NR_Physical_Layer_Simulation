clc;
clear;
close all;

%% ===================================
% 5G NR PHY RESULT ANALYSIS
% ====================================

resultsFile = '../../results/nr_phy_results.mat';

%% Check result file

if ~exist(resultsFile, 'file')
    error('Results file not found. Run nr_phy_simulation.m first.');
end

%% Load results

load(resultsFile);

fprintf('===================================\n');
fprintf('5G NR PHY RESULT ANALYSIS\n');
fprintf('===================================\n');

fprintf('Results loaded successfully.\n');

%% ===================================
% DISPLAY BER RESULTS
% ====================================

fprintf('\nSNR (dB)        BER\n');
fprintf('-------------------------\n');

for s = 1:length(SNR_dB)

    fprintf('%6d       %.6e\n', ...
        SNR_dB(s), BER(s));

end

%% ===================================
% BER PERFORMANCE PLOT
% ====================================

figure;

semilogy(SNR_dB, BER, '-o', ...
    'LineWidth', 1.5);

xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');

title('5G NR PHY BER Performance - 16-QAM OFDM');

grid on;

%% ===================================
% PERFORMANCE OBSERVATION
% ====================================

fprintf('\n===================================\n');
fprintf('KEY PERFORMANCE OBSERVATIONS\n');
fprintf('===================================\n');

fprintf('\nBER decreases as SNR increases.\n');

fprintf('At 0 dB SNR  : BER = %.6e\n', ...
    BER(1));

fprintf('At 10 dB SNR : BER = %.6e\n', ...
    BER(3));

fprintf('At 15 dB SNR : BER = %.6e\n', ...
    BER(4));

fprintf('At 20 dB SNR : BER = %.6e\n', ...
    BER(5));

fprintf('\nThe simulation demonstrates improved\n');
fprintf('communication reliability at higher SNR.\n');

fprintf('\n===================================\n');
fprintf('ANALYSIS COMPLETED SUCCESSFULLY\n');
fprintf('===================================\n');