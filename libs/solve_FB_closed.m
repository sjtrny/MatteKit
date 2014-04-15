function [ F, B ] = solve_FB_closed( image, alpha )
%SOLVE_FB_CLOSED
%
%   This function smoothly recovers the foreground and background from
%   a given image and alpha matte.
%   We use the method as outlined by closed form matting
%
%   min_x | R*x - I |_2^2 + x^T *L_dx* x + x^T *L_dy* x
%
%   where x = [F_1, F_2,..., F_N, B_1, B_2,..., B_N]^T;
%

    [h, w, c] = size(image);
    n = h*w;
    
    % Construct R matrix
    max_vals = n * 2;

    row_inds = zeros(max_vals, 1);
    col_inds = zeros(max_vals, 1);
    vals = zeros(max_vals, 1);
    
    count = 0;
    for k = 1 : n
        row_inds(1 + count : count + 2, 1) =    [k,         k];
        col_inds(1 + count : count + 2, 1) =    [k,         k + n];
        vals(1 + count : count + 2, 1) =        [alpha(k),  1 - alpha(k)];
        
        count = count + 2;
    end
    
    R = sparse(row_inds, col_inds, vals, n, n*2);
    
    % Construct L_dx matrix
    mask = (alpha>=0.0001).*(alpha<=0.9999);

    mask(:,w) = 0;
    mask(h,:) = 0;

    inds = find(mask);
    n_ind = size(inds, 1);
    
    row_inds = zeros(n_ind*4, 1);
    col_inds = zeros(n_ind*4, 1);
    vals = zeros(n_ind*4, 1);

    count = 0;
    for k = 1 : n_ind
        row_inds(1 + count : count + 4) = [inds(k)      , inds(k) + h , inds(k) + n       , inds(k) + h + n];
        col_inds(1 + count : count + 4) = [inds(k) + h  , inds(k)     , inds(k) + h + n   , inds(k) + n];
        g = alpha(inds(k)) - alpha(inds(k) + h);
        vals(1 + count : count + 4) = [g, g, g, g];
        
        count = count + 4;
    end
    
    vals = abs(vals);
    
    W = sparse(row_inds, col_inds, vals, n*2, n*2);
    D = spdiags(sum(W,2),0,n*2,n*2);
    L_dx = D - W;
    
    % Construct L_dy matrix
    row_inds = zeros(n_ind*4, 1);
    col_inds = zeros(n_ind*4, 1);
    vals = zeros(n_ind*4, 1);
    
    count = 0;
    for k = 1 : n_ind
        row_inds(1 + count : count + 4) = [inds(k)      , inds(k) + 1   , inds(k) + n       , inds(k) + 1 + n];
        col_inds(1 + count : count + 4) = [inds(k) + 1  , inds(k)       , inds(k) + 1 + n   , inds(k) + n];
        g = alpha(inds(k)) - alpha(inds(k) + 1);
        vals(1 + count : count + 4) = [g, g, g, g];
        
        count = count + 4;
    end
    
    vals = abs(vals);
    
    W = sparse(row_inds, col_inds, vals, n*2, n*2);
    D = spdiags(sum(W,2),0,n*2,n*2);
    L_dy = D - W;
    
    % Solve each layer seperately
    F = zeros(size(image));
    B = zeros(size(image));
    
    for k = 1 : c
        
        chan = reshape(image(:,:,k), n, 1);
        lhs = 2*(R' * R) + L_dx + L_dy;
        rhs = 2*R'*chan;
        x = lhs \ rhs;
        
        F(:,:,k) = reshape(x(1:n), h, w);
        B(:,:,k) = reshape(x(n+1:end), h,w );
        
    end
    
    F = F .* repmat(alpha, [1 1 3]);
    B = B .* repmat(1 - alpha, [1 1 3]);
    
end

