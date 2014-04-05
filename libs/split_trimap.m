function [ trimap_fore, trimap_back ] = split_trimap( trimap )
%SPLIT_TRIMAP Summary of this function goes here
%   Detailed explanation goes here

trimap_fore = trimap > 0.99;

trimap_back = trimap < 0.01;

end

