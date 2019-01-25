
function spectrum_calc(t,y)

nt = length(t);
dt = (t(2)-t(1))*60;

Fs = 1/dt;                    % Sampling frequency
T = dt;                     % Sample time
L = nt;                     % Length of signal

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')