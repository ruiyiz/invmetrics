function mad = meanabsolutedeviation(R)
%MEANABSOLUTEDEVIATION Summary of this function goes here
%   Detailed explanation goes here

if ismatrix(R)
    % input series is a matrix
    %
elseif istable(R)
    % input series is a table
    n = height(R);
    mu = mean(R);
elseif strcmpi(class(R), 'fints')
    %
end

%[EOF]
