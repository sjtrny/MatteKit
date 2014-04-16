function [ F, B ] = solve_FB( image, alpha )
%SOLVE_FB
%
%   This function smoothly recovers the foreground and background from
%   a given image and alpha matte.
%   We use the improved method proposed by Tierney et al.
%
%   min_x | R*x - I |_2^2 + | L_dx*x - a_dx |_2^2 + | L_dy*x - a_dy |_2^2
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

    max_vals = n_ind * 4;
    
    row_inds = zeros(max_vals, 1);
    col_inds = zeros(max_vals, 1);
    vals = zeros(max_vals, 1);
    
    count = 0;
    for k = 1 : n_ind
        row_inds(1 + count : count + 4, 1) = [inds(k), inds(k)      , inds(k) + n , inds(k) + n];
        col_inds(1 + count : count + 4, 1) = [inds(k), inds(k) + h  , inds(k) + n , inds(k) + n + h ];
        vals(1 + count : count + 4, 1) = [1, -1, 1, -1];
        
        count = count + 4;
    end
    
    L_dx = sparse(row_inds, col_inds, vals, n*2, n*2);
    
    % Construct L_dy matrix
    
    row_inds = zeros(max_vals, 1);
    col_inds = zeros(max_vals, 1);
    vals = zeros(max_vals, 1);
    
    count = 0;
    for k = 1 : n_ind
        row_inds(1 + count : count + 4, 1) = [inds(k), inds(k)      , inds(k) + n , inds(k) + n];
        col_inds(1 + count : count + 4, 1) = [inds(k), inds(k) + 1  , inds(k) + n , inds(k) + n + 1 ];
        vals(1 + count : count + 4, 1) = [1, -1, 1, -1];
        
        count = count + 4;
    end
    
    L_dy = sparse(row_inds, col_inds, vals, n*2, n*2);
    
    % Solve each layer seperately
    F = zeros(size(image));
    B = zeros(size(image));
    
    [dx, dy] = imgradientxy(alpha, 'IntermediateDifference');
    
    dx(inds) = 0;
    dy(inds) = 0;
    
    a_dx = [dx(:); dx(:)];
    a_dy = [dy(:); dy(:)];
    
    for k = 1 : c
        
        chan = reshape(image(:,:,k), n, 1);
        lhs = (R' * R) + (L_dx' * L_dx) + (L_dy' * L_dy);
        rhs = (R' * chan) + (L_dx' * a_dx) + (L_dy' * a_dy);
        x = lhs \ rhs;
        
        F(:,:,k) = reshape(x(1:n), h, w);
        B(:,:,k) = reshape(x(n+1:end), h,w );
        
    end
    
    F = F .* repmat(alpha, [1 1 3]);
    B = B .* repmat(1 - alpha, [1 1 3]);
    
end

