function result = optimize_biggan(scoreCodes, initialCode, generations, population, sigma)
%OPTIMIZE_BIGGAN Maximize one finite scalar per row of latent codes.
% scoreCodes receives population-by-D codes and returns population scores.
% Extracted from Ahyan's V2 demo: rank-one + rank-mu CMA-ES updates.
% The callback can generate images and score them with any fixed objective.
arguments
    scoreCodes (1,1) function_handle
    initialCode (1,:) double {mustBeReal,mustBeFinite}
    generations (1,1) double {mustBeInteger,mustBePositive} = 20
    population (1,1) double {mustBeInteger,mustBeGreaterThanOrEqual(population,4)} = 28
    sigma (1,1) double {mustBePositive,mustBeFinite} = 0.5
end
n = numel(initialCode);
assert(n>=2,'CMAES:Dimension','Use at least two dimensions.');
xmean = initialCode';
mu = floor(population/2);
w = log(mu+0.5)-log(1:mu)'; w = w/sum(w);
mueff = 1/sum(w.^2);
cc = (4+mueff/n)/(n+4+2*mueff/n);
cs = (mueff+2)/(n+mueff+5);
c1 = 2/((n+1.3)^2+mueff);
cmu = min(1-c1,2*(mueff-2+1/mueff)/((n+2)^2+mueff));
damps = 1+2*max(0,sqrt((mueff-1)/(n+1))-1)+cs;
chiN = sqrt(n)*(1-1/(4*n)+1/(21*n^2));
pc = zeros(n,1); ps = pc;
B = eye(n); D = ones(n,1); C = eye(n); invsqrtC = C;
counteval = 0; eigeneval = 0;
result.bestScore = -inf;
result.bestCode = initialCode;
result.bestHistory = zeros(generations,1);
result.meanHistory = zeros(generations,1);
result.codes = zeros(population,n,generations);
result.scores = zeros(population,generations);
for gen = 1:generations
    arx = xmean + sigma*(B*(D.*randn(n,population)));
    fitness = scoreCodes(arx');
    validateattributes(fitness,{'numeric'},{'real','finite','vector','numel',population});
    fitness = double(fitness(:));
    result.codes(:,:,gen) = arx'; result.scores(:,gen) = fitness;
    [sorted,order] = sort(fitness,'descend');
    if sorted(1)>result.bestScore
        result.bestScore = sorted(1); result.bestCode = arx(:,order(1))';
    end
    result.bestHistory(gen) = result.bestScore;
    result.meanHistory(gen) = mean(fitness);
    fprintf('Generation %d/%d | best %.4f | mean %.4f\n', ...
        gen,generations,sorted(1),mean(fitness));
    counteval = counteval+population;
    xold = xmean; xmean = arx(:,order(1:mu))*w;
    ps = (1-cs)*ps+sqrt(cs*(2-cs)*mueff)*invsqrtC*(xmean-xold)/sigma;
    hsig = norm(ps)/sqrt(1-(1-cs)^(2*counteval/population))/chiN < 1.4+2/(n+1);
    pc = (1-cc)*pc+hsig*sqrt(cc*(2-cc)*mueff)*(xmean-xold)/sigma;
    artmp = (arx(:,order(1:mu))-xold)/sigma;
    C = (1-c1-cmu)*C+c1*(pc*pc'+(1-hsig)*cc*(2-cc)*C) ...
        +cmu*(artmp.*w')*artmp';
    sigma = sigma*exp((cs/damps)*(norm(ps)/chiN-1));
    if counteval-eigeneval > population/(c1+cmu)/n/10
        eigeneval = counteval;
        C = (C+C')/2;
        [B,eigenvalues] = eig(C,'vector');
        D = sqrt(max(eigenvalues,eps));
        invsqrtC = B*diag(1./D)*B';
    end
end
end
