

%% Load spreadsheet(s)


%% Construct data struct

% struct c has fields for metadata and a substruct data
% data(c) for each cell
% data(c) has fields: firstframe, lastframe, x, y, area, ch1_measurements, ch2_measurements, ch3_measurements,
% ch4_measurements, mother_id, sister_id, daughter1_id, daughter2_id

% HOW TO DO FLATFIELDING AND SUBTRACT BACKGROUND???


%% Apply filters to each cell

% data(c).is_born = true;
% data(c).divides = true;

% data(c).born_after_min_frame = true;
% data(c).born_before_max_frame = true;

% data(c).above_min_length = true;
% data(c).below_max_length = true;

% Some filters need to be computed based on measurements for other cells.
% The measurements that don't need that should be computed first, and then
% the secondary measurements should be computed in a separate FOR loop.

% One thing that often goes wrong in tracking is that two cells will merge
% and then allegedly divide. Presumably when this happens the daughters
% will be more dissimilar than they should be. Will want to check this
% assumption.
% data(c).sister_size_is_similar = true;
% data(c).daughters_sizes_are_similar = true;

% data(c).geminin_below_thresh_at_birth = true;
% data(c).sister_geminin_below_thresh_at_birth = true;
% data(c).geminin_above_thresh_at_division = true;
% data(c).daughters_geminin_below_thresh_at_birth =
% data(daughter1_id).geminin_below_thresh_at_birth &&
% data(daughter2_id).geminin_below_thresh_at_birth;

% data(c).birth_is_good = data(c).is_born && data(c).born_after_min_frame
% && data(c).born_before_max_frame && data(c).sister_is_similar &&
% data(c).geminin_below_thresh_at_birth &&
% data(c).sister_geminin_below_thresh_at_birth

% data(c).division_is_good = data(c).divides &&
% data(c).daughters_sizes_are_similar &&
% data(c).geminin_above_thresh_at_division &&
% data(c).daughters_geminin_below_thresh_at_birth;

% data(c).is_heuristically_good = data(c).birth_is_good &&
% data(c).division_is_good && data(c).above_min_length &&
% data(c).below_max_length;

% Good cells: 31 and 33. Daughters of cell 3 which starts at (1050, 1400).
% In more recent movie these may be called 2 and 32 and 34.