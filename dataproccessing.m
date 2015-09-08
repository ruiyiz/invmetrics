%% Prepare test data
% This script converts sample data files into multiple MATLAB data types
% and save the variables in a MAT file.

%% Convert sample data to 
managers_tbl = readtable('data/managers.csv', 'Delimiter', ' ', ...
                         'TreatAsEmpty', 'NA');
managers_tbl.Index = datenum(managers_tbl{:, 1});

%%
managers_mat = table2array(managers_tbl);

%%
managers_fts = fints(managers_tbl);

%% Save variables to a MAT file
