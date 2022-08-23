function [] = CreakyDetection_DEMO()

% Please note
%       that this algorithm has been developed using speech signals
%       with a 16 kHz sampling frequency. Although the algorithm should be
%       sampling frequency independent, it is advised that users of the
%       algorithm resample their signals to 16 kHz before analysis.

[wave,Fs]=audioread('arctic_bdl_a0001.wav');

[Outs,Decs,t,H2H1,res_p] = CreakyDetection_CompleteDetection(wave,Fs);

plot(0.95*wave/max(abs(wave)))
hold on
plot(t*Fs,Outs,'g')
plot(t*Fs,Decs,'r')
xlabel('Time (samples)')
ylabel('Amplitude')
legend('Speech waveform','Creaky probability','Creaky binary decision')