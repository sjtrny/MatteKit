function [ x ] = w_func( v )
%W_FUNC Summary of this function goes here
%   Detailed explanation goes here

% Find elements that are less than eq to 1/2
k = find(abs(v) <= 0.5);
x = sum(abs(v(k)));

% Find elements that are greater than 1/2
k = find(abs(v) > 0.5);
x = x + sum(abs(v(k) - 1)); 

end

