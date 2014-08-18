% Script for testing the SSR MEX file

infilename = 'input.wav';
outfilename = 'output.wav';

positions = [0; 2];  % one column for each input channel
orientations = -90;  % row vector of angles in degree
mutes = false;  % row vector of logicals
models = { 'plane' };  % cell array of model strings

reference_position = [-1; 0]; % one column vector
reference_orientation = 90; % one angle in degree

params.block_size = 1024;
params.threads = 2;

% only for loudspeaker renderers:
params.reproduction_setup = '../data/reproduction_setups/circle.asd';

% only for binaural renderer:
params.hrir_file = '../data/impulse_responses/hrirs/hrirs_fabian.wav';

% only for WFS renderer:
params.prefilter_file = ...
    '../data/impulse_responses/wfs_prefilters/wfs_prefilter_120_1500_44100.wav';

% only for BRS renderer:
brirs = {'../data/impulse_responses/brirs/brirs_1.wav'};

% only for Generic renderer:
% TODO: provide example for generice renderer

% open
[sig, params.sample_rate] = wavread(infilename);
sig = single(sig);
sources = size(sig, 2);

prefix = 'ssr_';
% TODO: provide example for generice renderer
% suffix = {'binaural', 'brs', 'generic', 'wfs', 'nfc_hoa', 'vbap', 'aap'};
suffix = {'binaural', 'brs', 'wfs', 'nfc_hoa', 'vbap', 'aap'};
for idx = 1:length(suffix)
    renderer = [prefix, suffix{idx}];
    % check if MEX-file exists
    if exist(renderer, 'file') ~= 3
        continue;
    end
    
    % convert renderer to function handle
    ssr = str2func(renderer);
    
    % select suitable source information
    switch renderer
        case 'ssr_brs'
            sources = brirs;
            assert(length(sources) == size(sig,2));
        % TODO: provide example for generice renderer
        otherwise
            sources=size(sig, 2);  % just the number of sources (wo additional info)
    end
    
    % init renderer
    ssr('init', sources, params)
    
    % set some scene parameters (this does not effect all renderers)
    ssr('source_position', positions)
    ssr('source_orientation', orientations)
    ssr('source_mute', mutes)
    ssr('source_model', models{:})
    ssr('reference_position', reference_position)
    ssr('reference_orientation', reference_orientation)
    
    % try to get the loudspeaker positions
    try
        loudspeaker_position = ssr('loudspeaker_position');
        loudspeaker_orientation = ssr('loudspeaker_orientation');
        assert(ssr('out_channels') == size(loudspeaker_position, 2));
        assert(ssr('out_channels') == size(loudspeaker_orientation, 2));
        assert(size(loudspeaker_position, 1) == 2);
        assert(size(loudspeaker_orientation, 1) == 1);
    catch
        % if the request fails, this should be one a these two renderers
        assert(any(strcmp(renderer, {'ssr_binaural', 'ssr_brs'})));
        assert(ssr('out_channels') == 2);
    end
    
    % process input signal
    out = ssr_helper(sig, ssr);
    
    assert(ssr('out_channels') == size(out, 2));
    assert(ssr('block_size') == params.block_size);
    
    % clear the renderer
    ssr('clear');
    
    % save output to some file
    wavwrite(out, params.sample_rate, outfilename);
    
    % clear functions in order to free space allocated by mex functions
    clear functions
end
