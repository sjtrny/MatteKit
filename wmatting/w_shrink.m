function [ x ] = w_solve( v, lambda, p, mid, safezone )

% Set the threshold
th = lambda / p;

x = zeros(size(v));

k = find(abs(v) < - th);
x(k) = v(k) + th; 

k = find(v >= -th & v <= th);
x(k) = 0;

k = find(v > th & v < (mid - safezone));
x(k) = v(k) -th; 

k = find(v > (mid + safezone) & v < (1 - th));
x(k) = v(k) + th; 

k = find(v >= (1 - th) & v <= (1 + th));
x(k) = 1;

k = find(v > (1 + th));
x(k) = v(k) - th;

k = find( v >= (mid - safezone) & v <= (mid + safezone) );
x(k) = v(k);

end

