

foldername = 'E:\Image Analysis';
fname_G1Stable = ['DFB_170830_HMEC_1Giii_palbo_After analysis\DFB_170830_HMEC_1GFiii_palbo_After eyeballed G1S'];
fpath_G1Stable = [foldername '\' fname_G1Stable '.xlsx'];

t = readtable(fpath_G1Stable);

ancestorcells = zeros();
daughtercells = zeros();
birthframes = zeros();
G1Sframes = zeros();

ancestorcells = table2array(t(:,{'AncestorCell'}));
daughtercells = table2array(t(:,{'DaughterCell'}));
birthframes = table2array(t(:,{'BirthFrame'}));
G1Sframes = table2array(t(:,{'EyeballedG1S'}));


struct = struct('ancestorcellnum_array', ancestorcells,...
    'descendantcellnum_array', daughtercells,...
    'birthframes', birthframes,...
    'G1Sframes', G1Sframes);