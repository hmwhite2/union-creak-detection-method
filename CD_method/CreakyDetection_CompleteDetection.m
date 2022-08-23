function [Outs,Decs,t,H2H1,res_p] = CreakyDetection_CompleteDetection(wave,Fs, ANN_decision_threshold)

% Function to do automatic detection of creaky voice.
%
% INPUT:
%       wave - speech signal in samples
%       Fs  - Sampling frequency (Hz)
%
% OUTPUT:
%       Outs - Posterior probability of creak
%       Decs - Binary creak decision
%       t    - time index (samples) for Outs and Decs
%       H2H1 - H2H1 parameter
%       res_p - residual peak prominence parameter
%
%
% REFERENCE:
%       Drugman, T., Kane, J., Gobl, C., `Automatic Analysis of Creaky
%       Excitation Patterns', Submitted to Computer Speech and
%       Language.
%
%       Kane, J., Drugman, T., Gobl, C., (2013) `Improved automatic 
%       detection of creak', 27(4), pp. 1028-1047, Computer Speech and Language.
%
%       Drugman, T., Kane, J., Gobl, C., (2012) `Resonator-based creaky 
%       voice detection', Interspeech 2012, Portland, Oregon, USA.
%
% NOTES:
%       This version is a slightly later one than that described in the
%       above published 2013 CSL paper. The algorithm here rather than using binary
%       decision trees using artificial neural networks and combines the
%       features used in the CSL paper with those proposed in Ishi et al.
%       (2008). This updated version has been submitted to CSL for a special
%       issue on glottal source processing on April 14th 2013. Please note
%       also that this algorithm has been developed using speech signals
%       with a 16 kHz sampling frequency. Although the algorithm should be
%       sampling frequency independent, it is advised that users of the
%       algorithm resample their signals to 16 kHz before analysis.
%       Finally, note that Matlab version R2011a or later is required, with
%       the neural networks toolbox.

%% Load files
ANN.net=load('SystemNet_creak');
ANN.Maxis=load('Maxis_creak.mat');
ANN.Minis=load('Minis_creak.mat');

%% Do feature extraction
FeatMat = get_ALL_creak_features(wave,Fs);
H2H1=FeatMat(:,1);
res_p=FeatMat(:,2);

%% Do classification
[Outs,Decs] = CreakyDetection_DoClassification(FeatMat,ANN, ANN_decision_threshold);
t=(1:length(Outs))*10/1000;

