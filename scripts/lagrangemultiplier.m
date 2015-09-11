%% Portfolio optimization using Lagrange Multiplier
% Mean-Variance portfolio optimization with equality constraints, solved by
% using Lagrange Multiplier method.

%%
load BlueChipStockMoments
whos

%%
nAssets = length(AssetList);

%%
desiredReturn = 0.04;

%%
A = [2 * AssetCovar; ...
     ones(1, nAssets); ...
     transpose(AssetMean)];

b = [zeros(nAssets, 1); ...
     1; ...
     desiredReturn];

%%
x = A \ b;
bar(x);

%TODO research imposing inequality constraints to enforce a long-only portfolio

%%
totalWeight = sum(x);
assert(abs(totalWeight - 1) < 1e-5, 'sum of weights of all assets must be 1');

portReturn = x' * AssetMean;
assert(abs(portReturn - desiredReturn) < 1e-3, 'weighted return must approximately be equal to the desired return');

%TODO: portfolio variance

%%
