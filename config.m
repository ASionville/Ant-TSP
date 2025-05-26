% Configuration des paramètres pour Ant Colony Optimization (gridsearch)
cfg.nAnts       = [100 1000];
cfg.maxIterations = [100];
cfg.alpha       = [1 2];
cfg.beta        = [1 2];
cfg.rho         = [0.1 0.5];
cfg.Q           = [1];
cfg.nCities     = [10 100 1000];
cfg.seed        = [42]; % Pour reproductibilité
cfg.visualization = 'best'; % 'all', 'best', 'none'
cfg.minImprovement = [1e-6]; % Amélioration minimale considérée
cfg.patience = [20]; % Nombre d'itérations sans amélioration avant arrêt anticipé
