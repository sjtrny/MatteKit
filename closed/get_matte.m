function [ alpha ] = get_matte( image, trimap_fore, trimap_back, opts )
%GET_MATTE
%   "A Closed-Form Solution to Natural Image Matting"
%   A. Levin, D. Lischinski and Y Weiss
%   Pattern Analysis and Machine Intelligence, IEEE Transactions on  (Volume:30 ,  Issue: 2 )
%   
%   Written by Stephen Tierney

[h, w, ~] = size(image);

D_m = spdiags(trimap_fore(:) + trimap_back(:), 0, w*h, w*h);

L = get_laplacian(image, trimap_fore + trimap_back);

A = opts.lambda_m * D_m + opts.lambda_1*L;
b = opts.lambda_m * D_m * trimap_fore(:);

alpha = A \ b;

alpha = reshape(alpha, h, w);

end

