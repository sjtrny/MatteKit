function [ alpha ] = get_matte( image, trimap_fore, trimap_back, opts )
%GET_MATTE
%   "The W-Penalty and its Application to Alpha Matting with Sparse Labels"
%   Stephen Tierney, Junbin Gao and Yi Guo
%   DICTA14
% 
%   Written by Stephen Tierney

lambda_w = opts.lambda_w;
lambda_m = opts.lambda_m;

iterations  = 10;

mu = 1;

lambda_w = lambda_w * mu;

[h, w, ~] = size(image);

trimap_fore = double(trimap_fore(:));
alpha = trimap_fore;

last_f_value = inf;
f_value_list = zeros(iterations, 1);

[D, W] = get_knn_L(image);
L = D - W;

u = zeros(size(L,1),1);
y = zeros(size(L,1), 1);

D_m = spdiags(trimap_fore(:) + trimap_back(:), 0, w*h, w*h);

A = lambda_m*D_m + L;
C = ichol(A);
b = lambda_m*D_m*trimap_fore;

alpha = pcg(A, b, 1e-10, 2000, C, C', alpha);

for k = 1 : iterations

    %% Step 1, fix u and solve for alpha

    if (k > 1)
        A = lambda_m*D_m + L + mu*speye(size(L));
        C = ichol(A);
        b = lambda_m*D_m*trimap_fore + mu*u + y;

        alpha = pcg(A, b, 1e-10, 2000, C, C', alpha);
    end

    %% Step 2, fix alpha and solve for u
    
    v = alpha - y/mu;
    
    u = w_shrink(v, lambda_w, mu, mean(alpha), 0.1);
    
    %% Step 3, update y
    
    y = y + mu * (u - alpha);
    
    %% Check function value
    
    f_value = alpha' * L * alpha + lambda_m * (alpha - trimap_fore)' * D_m * (alpha - trimap_fore) + lambda_w * w_func(alpha);
    
    f_value_list(k, 1) = f_value;
    
    if (abs(last_f_value - f_value) <= 10^-6)
        break;
    else
        last_f_value = f_value;
    end

end

alpha = reshape(alpha, h, w);

end
