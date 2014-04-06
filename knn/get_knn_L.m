function [ D, A ] = get_knn_L( im )

run('../libs/vlfeat-0.9.13/toolbox/vl_setup');

[m, n, d] = size(im);

[a, b] = ind2sub([m n],1:m*n);
feature = [reshape(im,m*n,d)';[a;b]/sqrt(m*m+n*n)+rand(2,m*n)*1e-6];

ind_1 = vl_kdtreequery(vl_kdtreebuild(feature),feature,feature,'NUMNEIGHBORS',10,'MAXNUMCOMPARISONS',10*2);

feature(d+1:d+2,:)=feature(d+1:d+2,:)/100;

ind_2 = vl_kdtreequery(vl_kdtreebuild(feature),feature,feature,'NUMNEIGHBORS',2,'MAXNUMCOMPARISONS',2*2);

ind = [ind_1; ind_2];

a = reshape(repmat(uint32(1:m*n),12,1),[],1);
b = reshape(ind,[],1);

feature(d+1:d+2,:) = feature(d+1:d+2,:)/100;

% Repeat feature out 12 times for each pixel index

pixelFeats = feature(1:d+2,a);

% Repeat feature out 12 times for neighbours

neighbourFeats = feature(1:d+2,b);

value = max(1-sum(abs(pixelFeats - neighbourFeats))/(d+2),0);

A = sparse(double(a),double(b),value,m*n,m*n);
A = A + A';
D = spdiags(sum(A,2),0,n*m,n*m);


end

