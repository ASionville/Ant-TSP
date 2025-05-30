function [bestTour, bestTourLength, bestLengthHistory] = ant_aco(nAnts, maxIterations, alpha, beta, rho, Q, cities, showPlot, configId, patience, minImprovement)
% Ant Colony Optimization for the Traveling Salesman Problem (TSP)
if nargin < 8, showPlot = true; end
if nargin < 9, configId = ''; end
if nargin < 10, patience = 20; end
if nargin < 11, minImprovement = 1e-6; end

nCitiesTotal = size(cities, 1);
nRealCities = nCitiesTotal - 1; % Exclude the virtual city for the final path

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

% Pheromone intensity
tau = ones(nCitiesTotal, nCitiesTotal);

% Heuristic information (inverse of distance)
eta = zeros(nCitiesTotal, nCitiesTotal);
for i = 1:nCitiesTotal
    for j = 1:nCitiesTotal
        if i ~= j
            if distMatrix(i,j) == 0
                eta(i,j) = 1e6; % If two cities have the same coordinates, very high heuristic but not infinite
            else
                eta(i,j) = 1 / distMatrix(i,j);
            end
        else % Avoid division by zero
            eta(i,j) = 0;
        end
    end
end

% Initialize best solution
bestTour = [];
bestTourLength = inf;
bestLengthHistory = zeros(maxIterations,1);

% Early stopping parameters
no_improve_count = 0;
last_best = inf;

for iter = 1:maxIterations
    all_tours = zeros(nAnts, nRealCities);
    all_lengths = zeros(nAnts, 1);

    parfor ant = 1:nAnts
        visited = false(1, nCitiesTotal);
        visited(nCitiesTotal) = true; % Virtual city (0,0) is visited
        currentCity = nCitiesTotal; % Start at (0,0)
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
        % Return to (0,0)
        tourLength = tourLength + distMatrix(currentCity, nCitiesTotal);

        all_tours(ant, :) = tour;
        all_lengths(ant) = tourLength;
    end    % Find the best tour of this iteration
    [minLength, minIdx] = min(all_lengths);
    if minLength < bestTourLength - minImprovement
        bestTourLength = minLength;
        bestTour = all_tours(minIdx, :);
    end
    bestLengthHistory(iter) = bestTourLength;

    % Early stopping check
    if bestTourLength < last_best - minImprovement
        no_improve_count = 0;
        last_best = bestTourLength;
    else
        no_improve_count = no_improve_count + 1;
    end
    if no_improve_count >= patience
        bestLengthHistory = bestLengthHistory(1:iter);
        break;
    end

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
    % Plot the best path
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

    % Plot the best distance as a function of iterations
    figure;
    plot(1:length(bestLengthHistory), bestLengthHistory, 'Color', [0.5 0.7 0.9], 'LineWidth', 2);
    xlabel('Iteration');
    ylabel('Best Tour Length');
    title(['Best Tour Length vs Iteration - ' configId]);
    grid on;
end
end