clear; clc; close all;

config;

% If user want to specify cities, set use_random_cities to false
% and cities to the desired coordinates.
use_random_cities = false;
cities = [1 1; 1 -1; 0 -1; 0 1];

params = {cfg.nAnts, cfg.nIterations, cfg.alpha, cfg.beta, cfg.rho, cfg.Q, cfg.nCities, cfg.seed};
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
    nIterations= paramComb(i,2);
    alpha      = paramComb(i,3);
    beta       = paramComb(i,4);
    rho        = paramComb(i,5);
    Q          = paramComb(i,6);
    nCities    = paramComb(i,7);
    seed       = paramComb(i,8);

    if use_random_cities
        % Générer la liste des villes seulement si seed ou nCities change
        if isempty(cities) || seed ~= lastSeed || nCities ~= lastNCities
            rng(seed);
            cities = -10 + 20 * rand(nCities, 2);
            cities = [cities; 0 0]; % Ajouter (0,0)
            lastSeed = seed;
            lastNCities = nCities;
        end
    else
        % Utiliser les villes spécifiées par l'utilisateur
        if isempty(cities)
            error('Cities must be specified when use_random_cities is false.');
        end
        cities = [cities; 0 0]; % Ajouter (0,0)
        nCities = size(cities, 1);
    end

    configId = sprintf('Run %d/%d: nAnts=%d, nIterations=%d, alpha=%.2f, beta=%.2f, rho=%.2f, Q=%.2f, nCities=%d, seed=%d', ...
        i, nRuns, nAnts, nIterations, alpha, beta, rho, Q, nCities, seed);
    disp(configId);

    showPlot = false;
    if isfield(cfg, 'visualization')
        switch lower(cfg.visualization)
            case 'all'
                showPlot = true;
            case 'best'
                showPlot = false; % Sera affiché après la boucle
            case 'none'
                showPlot = false;
        end
    end

    [bestTour, bestTourLength, bestLengthHistory] = ant_aco(nAnts, nIterations, alpha, beta, rho, Q, cities, showPlot, configId);

    % Affichage du résultat dans la console
    disp(['Best tour length: ', num2str(bestTourLength)]);

    % Mise à jour du meilleur résultat global
    if bestTourLength < bestOverallLength
        bestOverallLength = bestTourLength;
        bestOverallTour = bestTour;
        bestOverallParams = [nAnts, nIterations, alpha, beta, rho, Q, nCities, seed];
        bestOverallHistory = bestLengthHistory;
        bestOverallId = configId;
        bestOverallCities = cities;
    end
end

% Affichage du meilleur résultat global et des paramètres associés
fprintf('\n=== BEST OVERALL SOLUTION ===\n');
disp('Best overall tour (city indices):');
disp(bestOverallTour);
disp(['Best overall tour length: ', num2str(bestOverallLength)]);
disp('Best parameters:');
disp(['nAnts = ', num2str(bestOverallParams(1)), ...
      ', nIterations = ', num2str(bestOverallParams(2)), ...
      ', alpha = ', num2str(bestOverallParams(3)), ...
      ', beta = ', num2str(bestOverallParams(4)), ...
      ', rho = ', num2str(bestOverallParams(5)), ...
      ', Q = ', num2str(bestOverallParams(6)), ...
      ', nCities = ', num2str(bestOverallParams(7)), ...
      ', seed = ', num2str(bestOverallParams(8))]);

% Affichage du plot pour la meilleure config si demandé
if isfield(cfg, 'visualization') && strcmpi(cfg.visualization, 'best')
    nAnts      = bestOverallParams(1);
    nIterations= bestOverallParams(2);
    alpha      = bestOverallParams(3);
    beta       = bestOverallParams(4);
    rho        = bestOverallParams(5);
    Q          = bestOverallParams(6);
    % nCities    = bestOverallParams(7); % déjà inclus dans bestOverallCities
    % seed       = bestOverallParams(8);
    ant_aco(nAnts, nIterations, alpha, beta, rho, Q, bestOverallCities, true, bestOverallId);
end
