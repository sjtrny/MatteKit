paths = genpath('thirdparty');
paths = [paths, 'common:', 'wmatting'];
addpath(paths);

image = double(imread('GT01.png'))/255;

[h, w, ~] = size(image);

load('GT01_fore_ind.mat');
load('GT01_back_ind');
trimap_fore = zeros(h, w);
trimap_fore(fore_ind) = 1;
trimap_back = zeros(h, w);
trimap_back(back_ind) = 1;

opts.lambda_w = 0.1;
opts.lambda_m = 100;

alpha = get_matte(image, trimap_fore, trimap_back, opts);

imshow(alpha);

rmpath(paths);