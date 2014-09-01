function [ alpha, f_value_list ] = solve_w_matting( L, D_m, trimap_fore, lambda_w, lambda_m)
%SOLVE_L1_MATTING
%   This function solves the following problem via ADMM
%   
%   min_a || L a ||_1 + (a - m)^T D_m (a - m)
%

iterations  = 50;

u = zeros(size(L,1),1);
y = zeros(size(L,1), 1);

mu = 1;

lambda_w = lambda_w * mu;

trimap_fore = double(trimap_fore);
alpha = trimap_fore;

last_f_value = inf;
f_value_list = zeros(iterations, 1);

A = lambda_m*D_m + 0.001*L;
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
    
    imshow(reshape(alpha, 552, 800));
    
    v = alpha - y/mu;
    
    u = w_solve(v, lambda_w, mu, mean(alpha), 0.1);
    
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

end