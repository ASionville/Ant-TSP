% Configuration des paramètres pour Ant Colony Optimization (gridsearch)
cfg.nAnts       = [1000];
cfg.maxIterations = [100];
cfg.alpha       = [2];
cfg.beta        = [2];
cfg.rho         = [0.5];
cfg.Q           = [1];
cfg.nCities     = [100];
cfg.seed        = [42]; % Pour reproductibilité
cfg.visualization = 'all'; % 'all', 'best', 'none'
cfg.minImprovement = [1e-6]; % Amélioration minimale considérée
cfg.patience = [20]; % Nombre d'itérations sans amélioration avant arrêt anticipé
