% Configuration parameters for Ant Colony Optimization (gridsearch)
cfg.nAnts       = [100 1000];
cfg.maxIterations = [100];
cfg.alpha       = [1 2];
cfg.beta        = [1 2];
cfg.rho         = [0.1 0.5];
cfg.Q           = [1];
cfg.nCities     = [10 100 1000];
cfg.seed        = [42]; % For reproducibility
cfg.visualization = 'best'; % 'all', 'best', 'none'
cfg.minImprovement = [1e-6]; % Minimum improvement considered
cfg.patience = [20]; % Number of iterations without improvement before early stopping
