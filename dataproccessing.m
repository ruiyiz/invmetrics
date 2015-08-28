%% convert data to different formats
%

%% convert data to different formats
managersTable = readtable('data/managers.csv', 'Delimiter', ' ', 'TreatAsEmpty', 'NA');
managersTable.Index = datenum(managersTable{:, 1});
%%
managersMat = table2array(managersTable);
%%
fints(managersTable)
%% save to MAT file
