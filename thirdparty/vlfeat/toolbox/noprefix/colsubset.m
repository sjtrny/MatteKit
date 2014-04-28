function varargout = colsubset(varargin)
% VL_COLSUBSET Select a given number of columns
%   Y = VL_COLSUBSET(X, N) returns a random subset Y of N columns of
%   X. The selection is order-preserving and without replacement. If N
%   is larger or equal to the number of columns of X (e.g. N=+Inf),
%   then the function returns Y = X.
%
%   If 0 < N < 1, then the function returns a fraction N of the
%   columns (rounded to the closest integer).
%
%   [Y, SEL] = VL_COLSUBSET(...) returns the indexes SEL of the
%   selected columns.
%
%   The function accepts the following options:
%
%   Beginning::
%     Causes the first N columns to be returned.
%
%   Ending::
%     Causes the last N columns to be returned.
%
%   Random::
%     Causes a random selection of columns to be returned (default).
%
%   Uniform::
%     Causes N equally spaced columns to be returned.
%
%  See also: VL_HELP().
[varargout{1:nargout}] = vl_colsubset(varargin{:});
