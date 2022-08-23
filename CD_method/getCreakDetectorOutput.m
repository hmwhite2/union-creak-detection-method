%% Outputs creak detector binary creak decision from multiple .wav files
% this script reads in all .wav files from a given directory, runs them
% through creak detector and outputs textfiles with timestamps at 0.01s
% intervals and a binary decision (1 = creak detected) at each time. wav
% files must have a 16 kHz sampling frequency for creak detector. textfiles
% are outputted to a new directory.

% created by Hannah White 20200730, with help from Josh Penney and Jidde
% Jacobi
% using creak detector coded by Drugman and Kane (2013)
%% get directory and files set up
myFolder = 'C:\Users\46065202\Documents\test_cd';
filePattern = fullfile(myFolder, '*.wav'); % get a list of all files in the folder with the .wav pattern
theFiles = dir(filePattern);

%% set threshold
thresh = 0.3:0.01:0.3;

%% loop
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    for i = 1 : length(thresh)
    [wave,Fs]=audioread(fullFileName);
    [Outs,Decs,t,H2H1,res_p] = CreakyDetection_CompleteDetection(wave,Fs, thresh(i)); % this is the creak detector function that make decisions about creak presence/absence
    crk_output = [t(:), Decs(:)]; % get time and decision vectors
    crk_output = num2cell(crk_output);
    str = baseFileName; % edit filename so files save with .txt extension
    expression = '.wav';
    replace = '';
    newStr = regexprep(str,expression,replace);
    newStr2 = [newStr '_' num2str(thresh(i))];
    newStr3 = strrep(newStr2,'.','_');
    txtName = fullfile('C:\Users\46065202\Documents\test_cd', newStr3); % specify new directory for files to save to
    writecell(crk_output,txtName) % write textfiles to folder
    end
end
