classdef BigGAN_CMAES < handle
% BigGAN_CMAES  Ask/tell version of Carlos/Ahyan's optimize_biggan.m
% (rank-one + rank-mu CMA-ES).
%
% WHY THIS EXISTS
%   optimize_biggan runs the whole evolution in one loop and calls a score
%   function that must return scores immediately. In MonkeyLogic the scores
%   only arrive after a full block of trials, and the userloop has to return
%   between trials. So the loop is split into two calls:
%       ask()  -> give me the next population of codes
%       tell() -> here are the scores of the population I showed
%   The update equations inside tell() are copied line by line from
%   optimize_biggan, so the evolution behaves exactly the same.
%
% USAGE
%   optim = BigGAN_CMAES(init_z, 0.7, 40);
%   optim.setPopulation(init_codes);   % block 1: use the fixed codes
%   ... show block, get 40 scores ...
%   optim.tell(codes, scores);         % update mean, step size, covariance
%   codes = optim.ask();               % 40 x 256 codes for the next block
%
% The optimizer always MAXIMIZES the score. Inhibition is handled in the
% userloop by the sign of the score (score = exc - inh).

    properties (SetAccess = private)
        % ---- fixed CMA-ES constants (set in the constructor) ----
        n           % dimension of the code (256 for BigGAN)
        lambda      % population size (images per block)
        mu          % number of parents (best half)
        w           % recombination weights (mu x 1)
        mueff       % variance-effective selection mass
        cc          % time constant for covariance path pc
        cs          % time constant for step-size path ps
        c1          % rank-one learning rate
        cmu         % rank-mu learning rate
        damps       % step-size damping
        chiN        % expected norm of N(0,I)

        % ---- evolving state ----
        xmean       % n x 1  current mean of the search distribution
        sigma       % current step size
        pc          % n x 1  evolution path for C
        ps          % n x 1  evolution path for sigma
        B           % eigenvectors of C
        D           % sqrt of eigenvalues of C
        C           % covariance matrix
        invsqrtC    % C^(-1/2)
        counteval = 0   % number of images scored so far
        eigeneval = 0   % counteval at the last eigen-decomposition
        gen = 0         % number of completed tell() updates

        arx = []        % n x lambda  population that was last handed out
        bestScore = -inf
        bestCode = []
    end

    methods
        function obj = BigGAN_CMAES(initialCode, sigma, population)
            arguments
                initialCode (1,:) double {mustBeReal,mustBeFinite}
                sigma (1,1) double {mustBePositive,mustBeFinite} = 0.7
                population (1,1) double {mustBeInteger,mustBeGreaterThanOrEqual(population,4)} = 40
            end
            n = numel(initialCode);
            assert(n >= 2, 'BigGAN_CMAES:Dimension', 'Use at least two dimensions.');

            % ---- constants (identical to optimize_biggan) ----
            obj.n      = n;
            obj.lambda = population;
            obj.mu     = floor(population/2);
            w = log(obj.mu+0.5) - log(1:obj.mu)';
            obj.w      = w / sum(w);
            obj.mueff  = 1 / sum(obj.w.^2);
            obj.cc     = (4+obj.mueff/n) / (n+4+2*obj.mueff/n);
            obj.cs     = (obj.mueff+2) / (n+obj.mueff+5);
            obj.c1     = 2 / ((n+1.3)^2+obj.mueff);
            obj.cmu    = min(1-obj.c1, 2*(obj.mueff-2+1/obj.mueff)/((n+2)^2+obj.mueff));
            obj.damps  = 1 + 2*max(0, sqrt((obj.mueff-1)/(n+1))-1) + obj.cs;
            obj.chiN   = sqrt(n)*(1-1/(4*n)+1/(21*n^2));

            % ---- initial state ----
            obj.xmean    = initialCode';
            obj.sigma    = sigma;
            obj.pc       = zeros(n,1);
            obj.ps       = zeros(n,1);
            obj.B        = eye(n);
            obj.D        = ones(n,1);
            obj.C        = eye(n);
            obj.invsqrtC = eye(n);
            obj.bestCode = initialCode;
        end

        function codes = ask(obj)
            % Sample a new population around the current mean:
            %   x = xmean + sigma * B * (D .* z),  z ~ N(0, I)
            % Returns lambda x n (one code per ROW, as generate_biggan expects).
            obj.arx = obj.xmean + obj.sigma*(obj.B*(obj.D.*randn(obj.n, obj.lambda)));
            codes = obj.arx';
        end

        function setPopulation(obj, codes)
            % Use a given population instead of ask(), e.g. the fixed block-1
            % codes from biggan_init.mat. They were drawn as init_z + sigma*N(0,I),
            % which is exactly what ask() would do at the start.
            assert(isequal(size(codes), [obj.lambda obj.n]), 'BigGAN_CMAES:Size', ...
                'Population must be %d x %d.', obj.lambda, obj.n);
            obj.arx = double(codes)';
        end

        function tell(obj, codes, scores)
            % codes  : lambda x n, the codes that were SHOWN (rows)
            % scores : lambda scores in the same order (higher = better)
            assert(isequal(size(codes), [obj.lambda obj.n]), 'BigGAN_CMAES:Size', ...
                'codes must be %d x %d.', obj.lambda, obj.n);
            fitness = double(scores(:));
            validateattributes(fitness, {'numeric'}, {'real','finite','numel',obj.lambda});

            % Safety check: the shown codes should be the ones we handed out
            if ~isempty(obj.arx) && max(abs(double(codes)' - obj.arx), [], 'all') > 1e-6
                warning('BigGAN_CMAES:CodesChanged', ...
                    'Codes passed to tell() differ from the last ask()/setPopulation().');
            end
            arx = double(codes)';                 % n x lambda

            % ---- rank the population ----
            [sorted, order] = sort(fitness, 'descend');
            if sorted(1) > obj.bestScore
                obj.bestScore = sorted(1);
                obj.bestCode  = arx(:, order(1))';
            end
            obj.counteval = obj.counteval + obj.lambda;

            % ---- move the mean toward the best half (weighted) ----
            xold = obj.xmean;
            obj.xmean = arx(:, order(1:obj.mu)) * obj.w;

            % ---- update evolution paths ----
            obj.ps = (1-obj.cs)*obj.ps + sqrt(obj.cs*(2-obj.cs)*obj.mueff) ...
                     * obj.invsqrtC*(obj.xmean-xold)/obj.sigma;
            hsig = norm(obj.ps)/sqrt(1-(1-obj.cs)^(2*obj.counteval/obj.lambda))/obj.chiN ...
                   < 1.4 + 2/(obj.n+1);
            obj.pc = (1-obj.cc)*obj.pc + hsig*sqrt(obj.cc*(2-obj.cc)*obj.mueff) ...
                     * (obj.xmean-xold)/obj.sigma;

            % ---- update covariance (rank-one + rank-mu) ----
            artmp = (arx(:, order(1:obj.mu)) - xold)/obj.sigma;
            obj.C = (1-obj.c1-obj.cmu)*obj.C ...
                    + obj.c1*(obj.pc*obj.pc' + (1-hsig)*obj.cc*(2-obj.cc)*obj.C) ...
                    + obj.cmu*(artmp.*obj.w')*artmp';

            % ---- update step size ----
            obj.sigma = obj.sigma*exp((obj.cs/obj.damps)*(norm(obj.ps)/obj.chiN - 1));

            % ---- occasionally re-decompose C (B, D, C^-1/2) ----
            if obj.counteval - obj.eigeneval > obj.lambda/(obj.c1+obj.cmu)/obj.n/10
                obj.eigeneval = obj.counteval;
                obj.C = (obj.C + obj.C')/2;
                [obj.B, eigenvalues] = eig(obj.C, 'vector');
                obj.D = sqrt(max(eigenvalues, eps));
                obj.invsqrtC = obj.B*diag(1./obj.D)*obj.B';
            end

            obj.gen = obj.gen + 1;
            fprintf('[CMA-ES] update %d | best %.3f | mean %.3f | sigma %.4f\n', ...
                obj.gen, sorted(1), mean(fitness), obj.sigma);
        end

        function s = getState(obj)
            % Full optimizer state as a struct (saved with every block, so a
            % session could later be inspected or resumed).
            p = properties(obj);
            s = struct();
            for i = 1:numel(p)
                s.(p{i}) = obj.(p{i});
            end
        end
    end
end
