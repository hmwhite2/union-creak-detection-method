function lims = detect_all_speech_intervals( xlsname, blockname, audioname )
%
% DETECT_ALL_SPEECH_INTERVALS
%	estimate limits of a set of utterances from energy/amplitude thresholds
%	filenames and DMDX ids assumed to be listed in summary spreadsheet
%
% USAGE
%   lims = detect_all_speech_intervals( xlsname, blockname, audioname );
%
% INPUTS
%   xlsname (string)        name of spreadsheet listing targets and file IDs
%   blockname (string)      name of audio block to process (assumed Col 1 of <fname>)
%   audioname (string)      base filename of audio recordings
%
% OUTPUTS
%   lims (1xn cell arrray)	automatically estimated start and end times (ms)
%
% EXAMPLE USAGE
%   lims = detect_all_speech_intervals( './analysis/mope_30may17.xlsx', 'al_priming4', './dmdx/EMA-MOPE1b_repAL' );
%
% HISTORY
%   Created:  12-Sep-17	Michael Proctor (mike.i.proctor@gmail.com)
%

        
    % specify spreadsheet configuration
    wsheet      = 'acoust';         % name of worksheet in source spreadsheet
    rngBlock	= 'A1:A300';        % range of cells specifying block IDs
    rngAudio	= 'E1:E300';        % range of cells specifying audio file IDs
    rngTarget	= 'G1:G300';        % range of cells specifying targets

    % specify acoustic search parameters
    th_ener	= 0.002;                % energy threshold for acoustic boundary detection
    th_ampl	= 0.016;                % acoustic threshold for acoustic boundary detection
    thresh	= [th_ener th_ampl];
    
    % fetch targets and file IDs from source spreadsheet
    [~,blcks,~] = xlsread( xlsname, wsheet, rngBlock );
    [~,targs,~]	= xlsread( xlsname, wsheet, rngTarget );
    [~,~,audio]	= xlsread( xlsname, wsheet, rngAudio );
    
    rowix	= find( strcmpi(blcks,blockname) );
    target	= targs(rowix);
    id      = cell2mat(audio(rowix));

    for i = 1:length(target)
        fname	= sprintf( '%s%d.WAV', audioname, id(i) );
        tt	= detect_speech_interval_ms( fname, [], thresh, 3, 1 );
        lims{i} = sprintf( '\t%s\t%d\t%d', target{i}, round(tt(1)), round(tt(2)) );
        pause
    end
char(lims)

end
