function [w, pstd, pret] = portoptlagrange(ExpectedReturn, AssetCovar, targetReturn)
%PORTOPTLAGRANGE Portfolio optimization using Lagrange Multiplier
% Mean-Variance portfolio optimization with equality constraints, solved by
% using Lagrange Multiplier method.

%% test data
%load BlueChipStockMoments

% TODO: input validation

er = ExpectedReturn;
M = AssetCovar;

n = length(er);
A = [2 * M; ones(1, n); transpose(er)];
b = [zeros(n, 1); 1; targetReturn];
w = A \ b;

twgt = sum(w);
assert(abs(twgt - 1) < 1e-5, ...
       'sum of weights of all assets must be 1');

ret = w' * er;
assert(abs(ret - targetReturn) < 1e-3, ...
       'weighted return must approximately be equal to the desired return');

if nargout >= 2, pstd = sqrt(w' * M * w); end
if nargout >= 3, pret = ret; end

end
