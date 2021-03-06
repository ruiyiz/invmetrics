load BlueChipStockMoments
%%
%targetReturns = linspace(0.005, 0.03, 10);
%%
% pwgtl = arrayfun(@(x) portoptlagrange(AssetList, AssetMean, AssetCovar, x), ...
%                  targetReturns, ...
%                  'UniformOutput', false);

[w, pstd, pret] = portoptlagrange(AssetMean, AssetCovar, 0.01);

%% Use Portfolio object to estimate weights
p = Portfolio;
p = setAssetMoments(p, AssetMean, AssetCovar);
p = setDefaultConstraints(p);
p = setBounds(p, -1.5, 1.5);
pwgt = estimateFrontierByReturn(p, desiredReturn);
bar(pwgt)
