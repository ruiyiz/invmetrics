%% MATLAB Portfolio Optimization Example
%
%%

%% Set up the data
load BlueChipStockMoments

mret = MarketMean;
mrsk = sqrt(MarketVar);
cret = CashMean;
crsk = sqrt(CashVar);

%% Create a portfolio object
p = Portfolio('AssetList', AssetList, 'RiskFreeRate', CashMean);
p = setAssetMoments(p, AssetMean, AssetCovar);
p = setInitPort(p, 1/p.NumAssets);
[ersk, eret] = estimatePortMoments(p, p.InitPort);

%%
clf;
portfolioexamples_plot('Asset Risks and Returns', ...
    {'scatter', mrsk, mret, {'Market'}}, ...
    {'scatter', crsk, cret, {'Cash'}}, ...
    {'scatter', ersk, eret, {'Equal'}}, ...
    {'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Set up a Portfolio Optimization Problem
p = setDefaultConstraints(p);
pwgt = estimateFrontier(p, 20);
[prsk, pret] = estimatePortMoments(p, pwgt);

%% Plot efficient frontier
clf;
portfolioexamples_plot('Efficient Frontier', ...
    {'line', prsk, pret}, ...
    {'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
    {'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Tangent portfolio
q = setBudget(p, 0, 1);
qwgt = estimateFrontier(q, 20);
[qrsk, qret] = estimatePortMoments(q, qwgt);

%% Plot efficient frontier with tangent line (0 to 1 cash)
clf;
portfolioexamples_plot('Efficient Frontier with Tangent Line', ...
    {'line', prsk, pret}, ...
    {'line', qrsk, qret, [], [], 1}, ...
    {'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
    {'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Obtain Range of Risks and Returns
[rsk, ret] = estimatePortMoments(p, estimateFrontierLimits(p));
disp(rsk);
disp(ret);

%% Find a Portfolio with a Targeted Return and Targeted Risk
TargetReturn = 0.2;
TargetRisk = 0.15;

% Obtain portfolios with targeted return and risk
awgt = estimateFrontierByReturn(p, TargetReturn/12);
[arsk, aret] = estimatePortMoments(p, awgt);

bwgt = estimateFrontierByRisk(p, TargetRisk/sqrt(12));
[brsk, bret] = estimatePortMoments(p, bwgt);

% Plot efficient frontier with targeted portfolios
clf;
portfolioexamples_plot('Efficient Frontier with Targeted Portfolios', ...
	{'line', prsk, pret}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', arsk, aret, {sprintf('%g%% Return',100*TargetReturn)}}, ...
	{'scatter', brsk, bret, {sprintf('%g%% Risk',100*TargetRisk)}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Set up 'blotters' that contains the portfolio weights and asset names
aBlotter = dataset({100*awgt(awgt > 0), 'Weight'}, 'obsnames', p.AssetList(awgt > 0));

fprintf('Portfolio with %g%% Target Return\n', 100 * TargetReturn);
disp(aBlotter);

bBlotter = dataset({100*bwgt(bwgt > 0), 'Weight'}, 'obsnames', p.AssetList(bwgt > 0));

fprintf('Portfolio with %g%% Target Risk\n', 100 * TargetRisk);
disp(bBlotter);

%% Transaction Costs
BuyCost = 0.0020;
SellCost = 0.0020;

q = setCosts(p, BuyCost, SellCost);

qwgt = estimateFrontier(q, 20);
[qrsk, qret] = estimatePortMoments(q, qwgt);

% Plot efficient frontiers with gross and net returns
clf;
portfolioexamples_plot('Efficient Frontier with and without Transaction Costs', ...
	{'line', prsk, pret, {'Gross'}, ':b'}, ...
	{'line', qrsk, qret, {'Net'}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Turnover Constraint
BuyCost = 0.0020;
SellCost = 0.0020;
Turnover = 0.2;

q = setCosts(p, BuyCost, SellCost);
q = setTurnover(q, Turnover);

[qwgt, qbuy, qsell] = estimateFrontier(q, 20);
[qrsk, qret] = estimatePortMoments(q, qwgt);

% Plot efficient frontier with turnover constraint
clf;
portfolioexamples_plot('Efficient Frontier with Turnover Constraint', ...
	{'line', prsk, pret, {'Unconstrained'}, ':b'}, ...
	{'line', qrsk, qret, {sprintf('%g%% Turnover', 100*Turnover)}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

fprintf('Sum of Purchases by Portfolio along Efficient Frontier (Max. Turnover %g%%)\n', ...
    100*Turnover);

disp(100*sum(qbuy));

fprintf('Sum of Sales by Portfolio along Efficient Frontier (Max. Turnover %g%%)\n', ...
    100*Turnover);

disp(100*sum(qsell));

%% Maximize the Sharpe Ratio
p = setInitPort(p, 0);

swgt = estimateMaxSharpeRatio(p);
[srsk, sret] = estimatePortMoments(p, swgt);

% Plot efficient frontier with portfolio that attains maximum Sharpe ratio
clf;
portfolioexamples_plot('Efficient Frontier with Maximum Sharpe Ratio Portfolio', ...
	{'line', prsk, pret}, ...
	{'scatter', srsk, sret, {'Sharpe'}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

% Set up a dataset object that contains the portfolio that maximizes the Sharpe ratio
Blotter = dataset({100*swgt(swgt > 0),'Weight'}, 'obsnames', AssetList(swgt > 0));

fprintf('Portfolio with Maximum Sharpe Ratio\n');
disp(Blotter);

%% Confirm the Maximum Sharpe Ratio is a Maximum
psratio = (pret - p.RiskFreeRate) ./ prsk;
ssratio = (sret - p.RiskFreeRate) / srsk;

clf;
subplot(2,1,1);
plot(prsk, pret, 'LineWidth', 2);
hold on
scatter(srsk, sret, 'g', 'filled');
title('\bfEfficient Frontier');
xlabel('Portfolio Risk');
ylabel('Portfolio Return');
hold off

subplot(2,1,2);
plot(prsk, psratio, 'LineWidth', 2);
hold on
scatter(srsk, ssratio, 'g', 'filled');
title('\bfSharpe Ratio');
xlabel('Portfolio Risk');
ylabel('Sharpe Ratio');
hold off

%% Illustrate that Sharpe is the Tangent Portfolio
q = setBudget(p, 0, 1);

qwgt = estimateFrontier(q, 20);
[qrsk, qret] = estimatePortMoments(q, qwgt);

% Plot that shows Sharpe ratio portfolio is the tangency portfolio

clf;
portfolioexamples_plot('Efficient Frontier with Maximum Sharpe Ratio Portfolio', ...
	{'line', prsk, pret}, ...
	{'line', qrsk, qret, [], [], 1}, ...
	{'scatter', srsk, sret, {'Sharpe'}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Dollar-Neutral Hedge-Fund Structure
Exposure = 1;

q = setBounds(p, -Exposure, Exposure);
q = setBudget(q, 0, 0);
q = setOneWayTurnover(q, Exposure, Exposure, 0);

[qwgt, qlong, qshort] = estimateFrontier(q, 20);
[qrsk, qret] = estimatePortMoments(q, qwgt);

[qswgt, qslong, qsshort] = estimateMaxSharpeRatio(q);
[qsrsk, qsret] = estimatePortMoments(q, qswgt);

% Plot efficient frontier for a dollar-neutral fund structure with tangency portfolio
clf;
portfolioexamples_plot('Efficient Frontier with Dollar-Neutral Portfolio', ...
	{'line', prsk, pret, {'Standard'}, 'b:'}, ...
	{'line', qrsk, qret, {'Dollar-Neutral'}, 'b'}, ...
	{'scatter', qsrsk, qsret, {'Sharpe'}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

% Set up a dataset object that contains the portfolio that maximizes the Sharpe ratio
Blotter = dataset({100*qswgt(abs(qswgt) > 1.0e-4), 'Weight'}, ...
	{100*qslong(abs(qswgt) > 1.0e-4), 'Long'}, ...
	{100*qsshort(abs(qswgt) > 1.0e-4), 'Short'}, ...
	'obsnames', AssetList(abs(qswgt) > 1.0e-4));

fprintf('Dollar-Neutral Portfolio with Maximum Sharpe Ratio\n');
disp(Blotter);

fprintf('Confirm Dollar-Neutral Portfolio\n');
fprintf('  (Net, Long, Short)\n');
disp([ sum(Blotter.Weight), sum(Blotter.Long), sum(Blotter.Short) ]);

%% 130/30 Fund Structure
Leverage = 0.3;

q = setBounds(p, -Leverage, 1 + Leverage);
q = setBudget(q, 1, 1);
q = setOneWayTurnover(q, 1 + Leverage, Leverage);

[qwgt, qbuy, qsell] = estimateFrontier(q, 20);
[qrsk, qret] = estimatePortMoments(q, qwgt);

[qswgt, qslong, qsshort] = estimateMaxSharpeRatio(q);
[qsrsk, qsret] = estimatePortMoments(q, qswgt);

% Plot efficient frontier for a 130-30 fund structure with tangency portfolio
clf;
portfolioexamples_plot(sprintf('Efficient Frontier with %g-%g Portfolio', ...
    100*(1 + Leverage),100*Leverage), ...
	{'line', prsk, pret, {'Standard'}, 'b:'}, ...
	{'line', qrsk, qret, {'130-30'}, 'b'}, ...
	{'scatter', qsrsk, qsret, {'Sharpe'}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

% Set up a dataset object that contains the portfolio that maximizes the Sharpe ratio
Blotter = dataset({100*qswgt(abs(qswgt) > 1.0e-4), 'Weight'}, ...
	{100*qslong(abs(qswgt) > 1.0e-4), 'Long'}, ...
	{100*qsshort(abs(qswgt) > 1.0e-4), 'Short'}, ...
	'obsnames', AssetList(abs(qswgt) > 1.0e-4));

fprintf('%g-%g Portfolio with Maximum Sharpe Ratio\n',100*(1 + Leverage),100*Leverage);
disp(Blotter);

fprintf('Confirm %g-%g Portfolio\n',100*(1 + Leverage),100*Leverage);
fprintf('  (Net, Long, Short)\n');
disp([ sum(Blotter.Weight), sum(Blotter.Long), sum(Blotter.Short) ]);


















































