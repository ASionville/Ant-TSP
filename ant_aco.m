clear; close all; clc;
% Ant Colony Optimization for the Traveling Salesman Problem (TSP)

% Algorithm Parameters
nAnts = 100; % Number of ants
nIterations = 100; % Number of iterations
alpha = 1; % Influence of pheromone
beta = 1; % Influence of heuristic information
rho = 0.5; % Evaporation rate
Q = 1; % Pheromone deposit factor

% Cities coordinates
cities = -10 + 20 * rand(100, 2);
cities = [cities; 0 0]; % Adding the starting point (0,0)
nCities = size(cities, 1);
nRealCities = nCities - 1; % Exclure la ville virtuelle pour le chemin final


% Distance matrix
distMatrix = zeros(nCities, nCities);
for i = 1:nCities
    for j = 1:nCities
        distMatrix(i,j) = sqrt((cities(i,1) - cities(j,1))^2 + (cities(i,2) - cities(j,2))^2);
    end
end

% Intensity of pheromones
tau = ones(nCities, nCities);

% Heuristic information (inverse of distance)
eta = zeros(nCities, nCities);
for i = 1:nCities
    for j = 1:nCities
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

for iter = 1:nIterations
    % Initialize ants
    tours = zeros(nAnts, nRealCities); % Exclure la ville virtuelle du chemin stocké
    lengths = zeros(nAnts, 1);
    all_tours = zeros(nAnts, nRealCities);
    all_lengths = zeros(nAnts, 1);

    for ant = 1:nAnts
        visited = false(1, nCities);
        visited(nCities) = true; % Ville virtuelle (0,0) visitée
        currentCity = nCities; % Commencer à (0,0)
        tour = zeros(1, nRealCities);

        tourLength = 0;
        for step = 1:nRealCities
            % Probabilités pour les vraies villes non visitées
            prob = zeros(1, nCities);
            for j = 1:nRealCities
                if ~visited(j)
                    prob(j) = (tau(currentCity,j)^alpha) * (eta(currentCity,j)^beta);
                end
            end
            if sum(prob) == 0
                prob = ones(1, nCities) / nRealCities;
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
        tourLength = tourLength + distMatrix(currentCity, nCities);

        all_tours(ant, :) = tour;
        all_lengths(ant) = tourLength;

        % Mise à jour du meilleur chemin
        if tourLength < bestTourLength
            bestTourLength = tourLength;
            bestTour = tour;
        end
    end

    % Pheromone evaporation
    tau = (1 - rho) * tau;

    % Pheromone deposit
    for ant = 1:nAnts
        tour = all_tours(ant, :);
        Lk = all_lengths(ant);
        % Dépôt sur le chemin aller
        tau(nCities, tour(1)) = tau(nCities, tour(1)) + Q / Lk;
        % Dépôt sur les transitions entre villes réelles
        for i = 1:(nRealCities-1)
            tau(tour(i), tour(i+1)) = tau(tour(i), tour(i+1)) + Q / Lk;
        end
        % Dépôt sur le retour
        tau(tour(end), nCities) = tau(tour(end), nCities) + Q / Lk;
    end
end

% Affichage du meilleur chemin trouvé (sans la ville virtuelle)
disp('Best tour (city indices):');
disp(bestTour);
disp(['Best tour length: ', num2str(bestTourLength)]);

% Affichage graphique du meilleur chemin
figure;
plot(cities(:,1), cities(:,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
hold on;
% Chemin complet : (0,0) -> villes -> (0,0)
plot([cities(nCities,1); cities(bestTour,1); cities(nCities,1)], ...
     [cities(nCities,2); cities(bestTour,2); cities(nCities,2)], 'b-', 'LineWidth', 2);
title('Best Tour Found');
xlabel('X');
ylabel('Y');
grid on;
hold off;