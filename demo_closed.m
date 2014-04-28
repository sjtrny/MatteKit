paths = genpath('common');
paths = [paths, 'closed'];
addpath(paths);

image = double(imread('GT01.png'))/255;

trimap = double(imread('GT01_tri.png'))/255;

scale = 1;

image = imresize(image, scale);
trimap = imresize(trimap, scale);

[trimap_fore, trimap_back] = split_trimap(trimap); 

opts.lambda_1 = 1;
opts.lambda_m = 1;

alpha = get_matte(image, trimap_fore, trimap_back, opts);

imshow(alpha);

rmpath(paths);