function result = demo_biggan(generations, population, showFigure)
%DEMO_BIGGAN Load BigGAN, generate an image, then optimize an image score.
% result = demo_biggan()                  % 10 generations, 12 images each
% result = demo_biggan(2,4,false)          % short CPU smoke test
% result.bestCode reproduces result.bestImage with generate_biggan.
arguments
    generations (1,1) double {mustBeInteger,mustBePositive} = 10
    population (1,1) double {mustBeInteger,mustBeGreaterThanOrEqual(population,4)} = 12
    showFigure (1,1) logical = true
end
rng(1,'twister');
net = load_biggan();
useGPU = false; % Change to true for a supported GPU.
batchSize = 2;
initialCode = [0.7*randn(1,128),0.05*randn(1,128)];
initialImage = generate_biggan(net,initialCode,useGPU,batchSize);

% A simple objective that needs no second network: mean red-channel value.
% Replace scoreImages with your own function returning one score per image.
scoreImages = @(imgs) reshape(mean(mean(double(imgs(:,:,1,:)),1),2),[],1)/255;
scoreCodes = @(codes) scoreImages(generate_biggan(net,codes,useGPU,batchSize));
result = optimize_biggan(scoreCodes,initialCode,generations,population,0.5);
result.initialCode = initialCode;
result.initialScore = scoreImages(initialImage);
result.bestImage = generate_biggan(net,result.bestCode,useGPU,batchSize);
if showFigure
    figure('Name','BigGAN optimization');
    subplot(1,3,1); image(initialImage); axis image off; title('Initial code');
    subplot(1,3,2); image(result.bestImage); axis image off; title('Best evolved image');
    subplot(1,3,3); plot(result.bestHistory,'LineWidth',1.5);
    xlabel('Generation'); ylabel('Best score so far'); grid on;
end
end
