paths = 'common';
addpath(paths);

image = double(imread('GT01.png'))/255;

truth = double(imread('GT01_truth.png'))/255;
truth_slice = truth(:,:,1);

[F, B] = solve_FB(image, truth_slice);

figure, imshow(image .* truth);
figure, imshow(F);

figure, imshow(image .* (1 - truth));
figure, imshow(B);

rmpath(paths);