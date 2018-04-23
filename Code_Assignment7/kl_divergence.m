function k = kl_divergence(H1n,H2n)
%KL_DIVERGENCE Computes the KL divergence between two 1-D histograms

    eta = .00001 * ones(size(H1n));
    H1n = H1n + eta;
    H2n = H2n + eta;
    temp = H1n .* log(H1n ./ H2n);
    temp(isnan(temp)) = 0;
    k = sum(temp);
