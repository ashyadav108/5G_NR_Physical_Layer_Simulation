# 5G NR Physical Layer Simulation and Performance Analysis

## Overview

This project implements a MATLAB-based 5G NR-inspired physical layer simulation to evaluate wireless communication performance under different signal-to-noise ratio (SNR) conditions.

The simulation includes **16-QAM modulation, OFDM modulation/demodulation, cyclic prefix insertion/removal, Rayleigh fading, AWGN, channel equalization, and BER analysis**.

The system performance is evaluated for SNR values from **0 dB to 20 dB** using multiple independent channel realizations.

---

## Objectives

- Implement 16-QAM digital modulation and demodulation.
- Implement OFDM using IFFT/FFT.
- Add and remove the cyclic prefix.
- Model a wireless channel using Rayleigh fading.
- Add AWGN noise at different SNR levels.
- Perform channel equalization at the receiver.
- Calculate BER for different SNR conditions.
- Analyze communication reliability as SNR increases.

---

## System Configuration

| Parameter | Value |
|---|---:|
| Modulation | 16-QAM |
| Bits per symbol | 4 |
| FFT size | 64 |
| Cyclic Prefix | 16 samples |
| OFDM Symbols | 100 |
| SNR Range | 0–20 dB |
| SNR Step | 5 dB |
| Channel Model | Rayleigh Fading + AWGN |
| Channel Realizations | 50 per SNR |

---

## Communication System

The implemented physical-layer chain is:

```text
Random Bits
     │
     ▼
16-QAM Modulation
     │
     ▼
OFDM Symbol Mapping
     │
     ▼
64-Point IFFT
     │
     ▼
Cyclic Prefix Addition
     │
     ▼
Rayleigh Fading Channel
     │
     ▼
AWGN Noise
     │
     ▼
Cyclic Prefix Removal
     │
     ▼
64-Point FFT
     │
     ▼
Channel Equalization
     │
     ▼
16-QAM Demodulation
     │
     ▼
Recovered Bits
     │
     ▼
BER Calculation
```

---

## 1. 16-QAM Modulation

The transmitter generates random binary data and groups the bits into 4-bit symbols.

Since:

```text
log2(16) = 4 bits/symbol
```

each group of four bits is mapped to one complex 16-QAM symbol.

The constellation is normalized using MATLAB's:

```matlab
qammod(..., 'UnitAveragePower', true)
```

This provides approximately unit average symbol power.

---

## 2. OFDM Modulation

The QAM symbols are divided into OFDM symbols containing **64 subcarriers**.

A 64-point IFFT converts the frequency-domain QAM symbols into time-domain OFDM samples.

```matlab
ofdmTime = ifft(ofdmGrid, Nfft, 1);
```

A cyclic prefix of **16 samples** is then added to every OFDM symbol.

```text
OFDM Symbol:

┌──────────────┬──────────────────────────────┐
│ Cyclic Prefix│      OFDM Time Samples       │
│   16 samples │          64 samples          │
└──────────────┴──────────────────────────────┘
```

Therefore, each transmitted OFDM symbol contains:

```text
64 + 16 = 80 samples
```

---

## 3. Wireless Channel

The transmitted OFDM signal is passed through a Rayleigh fading channel.

A complex fading coefficient is generated as:

```matlab
h = (randn + 1j*randn) / sqrt(2);
```

The transmitted signal is then affected by the channel:

```matlab
fadedSignal = h * txSignal;
```

AWGN is subsequently added according to the selected SNR.

The simulation uses:

```text
SNR = 0, 5, 10, 15, 20 dB
```

---

## 4. Receiver

At the receiver, the received signal is first divided into OFDM symbols.

The cyclic prefix is removed:

```matlab
rxWithoutCP = rxOFDM(cpLength+1:end, :);
```

The remaining samples are converted back to the frequency domain using a 64-point FFT:

```matlab
rxQAMGrid = fft(rxWithoutCP, Nfft, 1);
```

---

## 5. Channel Equalization

Since the simulation uses a known Rayleigh channel coefficient, channel equalization is performed by compensating for the fading coefficient:

```matlab
rxEqualized = rxQAM / h;
```

This compensates for the channel attenuation and phase rotation before QAM demodulation.

---

## 6. 16-QAM Demodulation

The equalized symbols are demodulated back into symbol indices:

```matlab
rxSymbolIndices = qamdemod( ...
    rxEqualized, M, ...
    'UnitAveragePower', true);
```

The recovered symbol indices are then converted back into binary data.

---

## 7. BER Analysis

The transmitted and received bit streams are compared to calculate the Bit Error Rate:

```text
BER = Number of Bit Errors / Total Number of Transmitted Bits
```

For every SNR value, the simulation performs **50 channel realizations**.

The BER results from all realizations are combined to obtain the final BER for that SNR.

---

## Results

The simulation produced the following BER results:

| SNR (dB) | BER |
|---:|---:|
| 0 | 2.865164e-01 |
| 5 | 1.638273e-01 |
| 10 | 5.898047e-02 |
| 15 | 4.383594e-03 |
| 20 | 0.000000e+00 |

### Performance Observation

The results show that BER decreases as SNR increases.

At low SNR, the received signal is significantly affected by noise, resulting in a higher number of bit errors.

As SNR increases, the effect of noise becomes smaller and the receiver is able to recover the transmitted symbols more reliably.

The simulation achieved:

```text
BER = 2.865164e-01  at 0 dB
BER = 1.638273e-01  at 5 dB
BER = 5.898047e-02  at 10 dB
BER = 4.383594e-03  at 15 dB
BER = 0              at 20 dB
```

The zero BER at 20 dB means that no bit errors were observed within the simulated bit samples for the 50 channel realizations.

---

## Project Structure

```text
5G_NR_Physical_Layer_Simulation/
│
├── README.md
│
├── matlab/
│   │
│   ├── modulation/
│   │   └── qam_modulation.m
│   │
│   ├── ofdm/
│   │   ├── ofdm_modulator.m
│   │   └── ofdm_demodulator.m
│   │
│   ├── channel/
│   │   └── wireless_channel.m
│   │
│   ├── simulation/
│   │   └── nr_phy_simulation.m
│   │
│   └── analysis/
│       └── plot_results.m
│
└── results/
    └── nr_phy_results.mat
```

---

## MATLAB Files

### `qam_modulation.m`

Implements and verifies 16-QAM modulation.

Main operations:

- Random bit generation
- Bit grouping
- Binary-to-symbol conversion
- 16-QAM modulation
- Constellation visualization

### `ofdm_modulator.m`

Implements the OFDM transmitter.

Main operations:

- 16-QAM symbol generation
- 64-point IFFT
- Cyclic prefix insertion
- Serial signal generation

### `ofdm_demodulator.m`

Verifies the OFDM receiver without channel impairments.

Main operations:

- OFDM symbol extraction
- Cyclic prefix removal
- FFT
- 16-QAM demodulation
- BER calculation

The modulation/demodulation chain was verified with:

```text
BER = 0
```

in the ideal channel case.

### `wireless_channel.m`

Implements the wireless channel model.

The channel includes:

- Rayleigh fading
- AWGN
- Configurable SNR

### `nr_phy_simulation.m`

This is the **main simulation script**.

It integrates the complete transmitter, channel, and receiver chain.

It performs simulations for:

```text
SNR = 0, 5, 10, 15, 20 dB
```

with:

```text
50 channel realizations per SNR
```

The BER results are saved into:

```text
results/nr_phy_results.mat
```

### `plot_results.m`

Loads the saved simulation results and generates the BER performance analysis.

It reads:

```text
SNR_dB
BER
```

from:

```text
nr_phy_results.mat
```

and displays the BER versus SNR performance.

---

## How to Run

### Step 1: Open MATLAB

Open the project folder:

```text
5G_NR_Physical_Layer_Simulation
```

### Step 2: Run the main simulation

Navigate to:

```text
matlab/simulation/
```

and run:

```matlab
nr_phy_simulation
```

This executes the complete physical-layer simulation.

### Step 3: Check the results

The simulation creates:

```text
results/nr_phy_results.mat
```

This file contains the calculated BER and simulation parameters.

### Step 4: Analyze the results

Navigate to:

```text
matlab/analysis/
```

and run:

```matlab
plot_results
```

This loads the saved results and generates the BER performance plot.

---

## Tools and Technologies

- **MATLAB**
- Digital Communications
- 16-QAM
- OFDM
- IFFT / FFT
- Cyclic Prefix
- Rayleigh Fading
- AWGN
- Channel Equalization
- BER Analysis

---

## Key Concepts Demonstrated

This project demonstrates practical understanding of:

- Digital modulation
- Quadrature Amplitude Modulation
- Orthogonal Frequency Division Multiplexing
- Frequency-domain to time-domain conversion
- Cyclic prefix
- Wireless channel modeling
- Rayleigh fading
- AWGN
- Channel equalization
- Receiver processing
- BER-based performance evaluation
- SNR-dependent communication performance

---

## Conclusion

The 5G NR physical-layer simulation successfully implemented and evaluated an end-to-end wireless communication system using **16-QAM, OFDM, cyclic prefix, Rayleigh fading, AWGN, and channel equalization**.

The BER analysis demonstrated that system performance improves significantly as SNR increases, with fewer bit errors observed under better channel conditions. The project provides practical understanding of **5G physical-layer processing, wireless channel effects, receiver equalization, and BER-based performance evaluation**.

The implemented framework also provides a foundation for future extensions such as **MIMO, channel coding, pilot-based channel estimation, resource-grid mapping, and more advanced 5G NR physical-layer features**.