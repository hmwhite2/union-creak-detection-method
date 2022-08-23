function features = get_ALL_creak_features(x,fs)

% Function to the full feature extraction required for the ANN-based creaky
% voice classification method used in the CSL special issue paper
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
%       Ishi, C., Sakakibara, K-I, Ishiguro, H., (2008) `A method for 
%       automatic detection of vocal fry', IEEE TASLP, 16(1), 47-56.

%% Extract Kane-Drugman features
[H2H1,res_p,ZCR,F0,F0mean,enerN,pow_std,creakF0] = get_KD_creak_features(x,fs);

%% Extract features from Ishi et al. (2008)
[PwP,IFP,IPS] = get_ishi_params_inter(x,fs);

%% Create feature matrix
time=round(linspace(1,length(x),length(H2H1)));
feat_stat=[H2H1(:) res_p(:) ZCR(:) IFP(time)' IPS(time)' PwP.fall(time)' PwP.rise(time)' ...
    F0(:) F0mean(:) enerN(:) pow_std(:) creakF0(:)];

%% Derive first and second derivatives of features
feat_d = get_delta_mat(feat_stat);
feat_dd = get_delta_mat(feat_d);

features=[feat_stat feat_d feat_dd];