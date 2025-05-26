clear; clc; close all;

config;

% If user wants to specify cities, set use_random_cities to false
% and cities to the desired coordinates.
use_random_cities = true;
cities = [1 -1  1 -1       1    1 1;
          1  1 -0.8 -0.8  -0.8  1 1];
cities = cities';

params = {cfg.nAnts, cfg.maxIterations, cfg.alpha, cfg.beta, cfg.rho, cfg.Q, cfg.nCities, cfg.seed, cfg.patience, cfg.minImprovement};
[paramGrid{1:numel(params)}] = ndgrid(params{:});
paramComb = cell2mat(cellfun(@(x) x(:), paramGrid, 'UniformOutput', false));

nRuns = size(paramComb,1);

bestOverallLength = inf;
bestOverallTour = [];
bestOverallParams = [];
bestOverallHistory = [];
bestOverallId = 0;

lastSeed = NaN;
lastNCities = NaN;

for i = 1:nRuns
    nAnts      = paramComb(i,1);
    maxIterations= paramComb(i,2);
    alpha      = paramComb(i,3);
    beta       = paramComb(i,4);
    rho        = paramComb(i,5);
    Q          = paramComb(i,6);
    nCities    = paramComb(i,7);
    seed       = paramComb(i,8);    patience   = paramComb(i,9);
    minImprovement = paramComb(i,10);

    if use_random_cities
        % Generate city list only if seed or nCities changes
        if isempty(cities) || seed ~= lastSeed || nCities ~= lastNCities
            rng(seed);
            cities = -10 + 20 * rand(nCities, 2);
            cities = [cities; 0 0]; % Add (0,0)
            lastSeed = seed;
            lastNCities = nCities;
        end
    else
        % Use user-specified cities
        if isempty(cities)
            error('Cities must be specified when use_random_cities is false.');
        end
        cities = [cities; 0 0]; % Add (0,0)
        nCities = size(cities, 1); 
    end

    configId = sprintf('Run %d/%d: nAnts=%d, maxIterations=%d, alpha=%.2f, beta=%.2f, rho=%.2f, Q=%.2f, nCities=%d, seed=%d', ...
        i, nRuns, nAnts, maxIterations, alpha, beta, rho, Q, nCities, seed);
    disp(configId);

    showPlot = false;
    if isfield(cfg, 'visualization')
        switch lower(cfg.visualization)
            case 'all'
                showPlot = true;
            case 'best'
                showPlot = false; % Will be displayed after the loop
            case 'none'
                showPlot = false;
        end
    end

    [bestTour, bestTourLength, bestLengthHistory] = ant_aco(nAnts, maxIterations, alpha, beta, rho, Q, cities, showPlot, configId, patience, minImprovement);    % Display result in console
    disp(['Best tour length: ', num2str(bestTourLength)]);

    % Update best overall result
    if bestTourLength < bestOverallLength
        bestOverallLength = bestTourLength;
        bestOverallTour = bestTour;
        bestOverallParams = [nAnts, maxIterations, alpha, beta, rho, Q, nCities, seed];
        bestOverallHistory = bestLengthHistory;
        bestOverallId = configId;
        bestOverallCities = cities;
    end
end

% Display best overall result and associated parameters
fprintf('\n=== BEST OVERALL SOLUTION ===\n');
disp('Best overall tour (city indices):');
disp(bestOverallTour);
disp(['Best overall tour length: ', num2str(bestOverallLength)]);
disp('Best parameters:');
disp(['nAnts = ', num2str(bestOverallParams(1)), ...
      ', maxIterations = ', num2str(bestOverallParams(2)), ...
      ', alpha = ', num2str(bestOverallParams(3)), ...
      ', beta = ', num2str(bestOverallParams(4)), ...
      ', rho = ', num2str(bestOverallParams(5)), ...
      ', Q = ', num2str(bestOverallParams(6)), ...
      ', nCities = ', num2str(bestOverallParams(7)), ...
      ', seed = ', num2str(bestOverallParams(8))]);

% Display plot for best config if requested
if isfield(cfg, 'visualization') && strcmpi(cfg.visualization, 'best')
    nAnts      = bestOverallParams(1);
    maxIterations= bestOverallParams(2);
    alpha      = bestOverallParams(3);
    beta       = bestOverallParams(4);
    rho        = bestOverallParams(5);
    Q          = bestOverallParams(6);
    % nCities    = bestOverallParams(7); % already included in bestOverallCities
    % seed       = bestOverallParams(8);
    ant_aco(nAnts, maxIterations, alpha, beta, rho, Q, bestOverallCities, true, bestOverallId, cfg.patience, cfg.minImprovement);
end
