function [bestTour, bestTourLength, bestLengthHistory] = ant_aco(nAnts, nIterations, alpha, beta, rho, Q, cities, showPlot, configId)
% Ant Colony Optimization for the Traveling Salesman Problem (TSP)
if nargin < 8, showPlot = true; end
if nargin < 9, configId = ''; end

nCitiesTotal = size(cities, 1);
nRealCities = nCitiesTotal - 1; % Exclure la ville virtuelle pour le chemin final

% Pastel colors for visualization
cityColor = [0.3 0.5 0.8];
startColor = [0.2 0.6 0.2];
tourColor = [1 0.7 0.4];

% Distance matrix
distMatrix = zeros(nCitiesTotal, nCitiesTotal);
for i = 1:nCitiesTotal
    for j = 1:nCitiesTotal
        distMatrix(i,j) = sqrt((cities(i,1) - cities(j,1))^2 + (cities(i,2) - cities(j,2))^2);
    end
end

% Intensity of pheromones
tau = ones(nCitiesTotal, nCitiesTotal);

% Heuristic information (inverse of distance)
eta = zeros(nCitiesTotal, nCitiesTotal);
for i = 1:nCitiesTotal
    for j = 1:nCitiesTotal
        if i ~= j
            eta(i,j) = 1 / distMatrix(i,j);
        else % Avoid division by zero
            eta(i,j) = 0;
        end
    end
end

% Initialize best solution
bestTour = [];
bestTourLength = inf;
bestLengthHistory = zeros(nIterations,1);

for iter = 1:nIterations
    all_tours = zeros(nAnts, nRealCities);
    all_lengths = zeros(nAnts, 1);

    for ant = 1:nAnts
        visited = false(1, nCitiesTotal);
        visited(nCitiesTotal) = true; % Ville virtuelle (0,0) visitée
        currentCity = nCitiesTotal; % Commencer à (0,0)
        tour = zeros(1, nRealCities);

        tourLength = 0;
        for step = 1:nRealCities
            prob = zeros(1, nCitiesTotal);
            for j = 1:nRealCities
                if ~visited(j)
                    prob(j) = (tau(currentCity,j)^alpha) * (eta(currentCity,j)^beta);
                end
            end
            if sum(prob) == 0
                prob = ones(1, nCitiesTotal) / nRealCities;
            else
                prob = prob / sum(prob);
            end
            nextCity = find(rand <= cumsum(prob), 1);
            tour(step) = nextCity;
            visited(nextCity) = true;
            tourLength = tourLength + distMatrix(currentCity, nextCity);
            currentCity = nextCity;
        end
        % Retour à (0,0)
        tourLength = tourLength + distMatrix(currentCity, nCitiesTotal);

        all_tours(ant, :) = tour;
        all_lengths(ant) = tourLength;

        if tourLength < bestTourLength
            bestTourLength = tourLength;
            bestTour = tour;
        end
    end
    bestLengthHistory(iter) = bestTourLength;

    % Pheromone evaporation
    tau = (1 - rho) * tau;

    % Pheromone deposit
    for ant = 1:nAnts
        tour = all_tours(ant, :);
        Lk = all_lengths(ant);
        tau(nCitiesTotal, tour(1)) = tau(nCitiesTotal, tour(1)) + Q / Lk;
        for i = 1:(nRealCities-1)
            tau(tour(i), tour(i+1)) = tau(tour(i), tour(i+1)) + Q / Lk;
        end
        tau(tour(end), nCitiesTotal) = tau(tour(end), nCitiesTotal) + Q / Lk;
    end
end

if showPlot
    % Affichage graphique du meilleur chemin
    figure;
    hold on;
    scatter(cities(1:nRealCities,1), cities(1:nRealCities,2), 60, 'o', 'MarkerEdgeColor', cityColor, 'MarkerFaceColor', cityColor, 'LineWidth', 1.5);
    scatter(cities(nCitiesTotal,1), cities(nCitiesTotal,2), 100, 'o', 'MarkerEdgeColor', startColor, 'MarkerFaceColor', startColor, 'LineWidth', 2);
    plot([cities(nCitiesTotal,1); cities(bestTour,1); cities(nCitiesTotal,1)], ...
         [cities(nCitiesTotal,2); cities(bestTour,2); cities(nCitiesTotal,2)], '-', ...
         'Color', tourColor, 'LineWidth', 2);
    title(['Best Tour Found - ' configId]);
    xlabel('X');
    ylabel('Y');
    grid on;
    hold off;

    % Affichage de la meilleure distance en fonction des itérations
    figure;
    plot(1:nIterations, bestLengthHistory, 'Color', [0.5 0.7 0.9], 'LineWidth', 2);
    xlabel('Iteration');
    ylabel('Best Tour Length');
    title(['Best Tour Length vs Iteration - ' configId]);
    grid on;
end
end