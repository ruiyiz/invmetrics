function w = portoptlagrange(AssetList, AssetMean, AssetCovar, targetReturn)
%PORTOPTLAGRANGE Portfolio optimization using Lagrange Multiplier
% Mean-Variance portfolio optimization with equality constraints, solved by
% using Lagrange Multiplier method.

%% test data
%load BlueChipStockMoments

% TODO: input validation

n = length(AssetList);
A = [2 * AssetCovar; ones(1, n); transpose(AssetMean)];
b = [zeros(n, 1); 1; targetReturn];
w = A \ b;

totalWeight = sum(w);
assert(abs(totalWeight - 1) < 1e-5, ...
       'sum of weights of all assets must be 1');

portReturn = w' * AssetMean;
assert(abs(portReturn - targetReturn) < 1e-3, ...
       'weighted return must approximately be equal to the desired return');
end
