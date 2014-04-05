function [ alpha ] = get_matte( image, trimap_fore, trimap_back, opts )
%GET_MATTE
%   "KNN Matting" in CVPR12 by Qifeng Chen, Dingzeyu Li and Chi-Keung Tang
% 
%   Written by Stephen Tierney

[h, w, ~] = size(image);

[D, W] = get_knn_L(image);
L = D - W;

D_m = spdiags(trimap_fore(:) + trimap_back(:), 0, w*h, w*h);

A = opts.lambda_m * D_m + opts.lambda_1*L;
C = ichol(A);

b = opts.lambda_m * D_m * trimap_fore(:);

x = pcg(A, b, 1e-10, 2000, C, C');

alpha = reshape(x, h, w);


end