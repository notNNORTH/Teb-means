% code for F. Nie, J. Xue, D. Wu, R. Wang, H. Li, and X. Li,
%¡°Coordinate descent method for k-means,¡± IEEE Transactions on Pattern Analysis and Machine Intelligence, 2021


function [Y, minO, iter_num, obj, runtime] = CDKM(X, label, k)
% Input
%   X: data matrix (d*n)
%   label: the initial assignment label (n*1)
%   k: the number of clusters
% Output
%   Y: the final assignment label vector (n*1)
%   minO: the objective function value when converged
%   iter_num: the number of iteration
%   obj: the objective function value in each iteration
%   runtime: the total runtime of CDKM

fprintf("CDKM\n");
start_time = tic;

[~,n] = size(X);
F = sparse(1:n, label, 1, n, k, n);     % transform label into indicator matrix (n*k)
last = 0;
iter_num = 0;

%% compute Initial objective function value
for ii = 1:k
    idxi = find(label == ii);
    Xi = X(:, idxi);
    m = size(Xi, 2);
    ceni = mean(Xi, 2);     % the i-th centroid (d*1)
    center(:, ii) = ceni;   % the centroid matrix (d*k)
    c2 = ceni'*ceni;
    sse_i = sum(Xi.^2) + m*c2 - 2*ceni'*Xi;
    sse(ii, 1) = sum(sse_i);
end
obj(1)= sum(sse);       % initial objective function value

%% store once
for i = 1:n
    XX(i) = X(:,i)'* X(:,i);
end
BB = X*F;       % (d*k)
aa = sum(F,1);  % diag(F'*F) the data number in each cluster
FXXF = BB'*BB;  % F'*X'*X*F;

%% main loop
for iter = 1:200
    % while any(label ~= last)
    %     last = label;
    for i = 1:n
        p = label(i);
        if aa(p) == 1
            continue;
        end
        % calculate all delta and choose the max one
        for k = 1:k
            if k == p
               V1(k) = FXXF(k,k) - 2 * X(:,i)' * BB(:,k) + XX(i);
               delta(k) = FXXF(k,k) / aa(k) - V1(k) / (aa(k) - 1); 
            else
               V2(k) = FXXF(k,k) + 2 * X(:,i)' * BB(:,k) + XX(i);
               delta(k) = V2(k) / (aa(k) + 1) -  FXXF(k,k)  / aa(k); 
            end
        end
        [~, q] = max(delta);
        if p ~= q
             BB(:,q) = BB(:,q) + X(:,i);    % BB(:,p) = X*F(:,p);
             BB(:,p) = BB(:,p) - X(:,i);    % BB(:,m) = X*F(:,m);
             aa(q) = aa(q) + 1;     % FF(p,p) = F(:,p)'*F(:,p);
             aa(p) = aa(p) - 1;     % FF(m,m) = F(:,m)'*F(:,m)
             FXXF(p, p) = V1(p);
             FXXF(q, q) = V2(q);
             label(i) = q;
        end
    end

    iter_num = iter_num + 1;

    %% compute objective function value
    for ii = 1:k
        idxi = find(label == ii);
        Xi = X(:, idxi);
        m = size(Xi, 2);
        ceni = mean(Xi, 2);
        center1(:,ii) = ceni;
        c2 = ceni'*ceni;
        sse_i = sum(Xi.^2) + m*c2 - 2*ceni'*Xi;
        sse(ii, 1) = sum(sse_i);
    end
    obj(iter_num+1) = sum(sse) ;     %  objective function value
end
runtime = toc(start_time);

disp(['CDKM runtime: ', num2str(runtime)]);
minO = min(obj);
Y = label;
end
