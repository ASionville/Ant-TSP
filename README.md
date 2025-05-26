# Ant Colony Optimization for Traveling Salesman Problem

## Authors:
- Aubin SIONVILLE
- Bastien DESCOS
- Matthieu BONNEAU

## Purpose

This project implements the Ant Colony Optimization (ACO) algorithm to solve the Traveling Salesman Problem (TSP). Developed as part of the **Metaheuristics** course at Télécom Saint-Étienne, this project explores a bio-inspired method for optimizing city tours.

The objective is to find the shortest path that visits all cities exactly once and returns to the starting point (origin (0,0)). The algorithm uses the collective behavior of ants that deposit pheromones to communicate and converge towards optimal solutions.

## Instructions

### Prerequisites
- MATLAB (R2018b or newer recommended)
- Parallel Computing Toolbox (optional, for acceleration with `parfor`)

### Usage

1. **Parameter configuration:**
   Modify the `config.m` file to adjust algorithm parameters:
   ```matlab
   cfg.nAnts         = [100 1000];        % Number of ants
   cfg.maxIterations = [100];             % Maximum number of iterations
   cfg.alpha         = [1 2];             % Pheromone importance
   cfg.beta          = [1 2];             % Heuristic information importance
   cfg.rho           = [0.1 0.5];         % Pheromone evaporation rate
   cfg.Q             = [1];               % Amount of pheromones deposited
   cfg.nCities       = [10 100 1000];     % Number of cities
   cfg.seed          = [42];              % Seed for reproducibility
   ```

2. **Execution:**
   ```matlab
   main
   ```

3. **Visualization modes:**
   - `'all'` : Display graphs for each tested configuration
   - `'best'` : Display only the graph of the best solution found
   - `'none'` : No visualization

4. **City configuration:**
   - **Automatic mode** (`use_random_cities = true`) : Cities are randomly generated
   - **Manual mode** (`use_random_cities = false`) : Specify your own coordinates in the `cities` variable

### Output example
```
Run 1/12: nAnts=100, maxIterations=100, alpha=1.00, beta=1.00, rho=0.10, Q=1.00, nCities=10, seed=42
Best tour length: 45.67

=== BEST OVERALL SOLUTION ===
Best overall tour (city indices): [3 7 2 9 1 8 4 6 5]
Best overall tour length: 42.31
Best parameters: nAnts = 100, maxIterations = 100, alpha = 1.00, beta = 2.00, rho = 0.50, Q = 1.00, nCities = 10, seed = 42
```

## Implementation Details

### Project Architecture

**main.m** : Main script that:
- Loads configuration from `config.m`
- Generates all parameter combinations (grid search)
- Executes the ACO algorithm for each combination
- Selects and displays the best overall solution
- Manages visualization according to preferences

**config.m** : Configuration file containing:
- All algorithm parameters as lists
- Visualization options
- Early stopping parameters (patience, minimum improvement)

**ant_aco.m** : Core of the ACO algorithm that implements:
- Probabilistic construction of tours by ants
- Pheromone update (evaporation and deposit)
- Early stopping criteria
- Results visualization

### ACO Algorithm

1. **Initialization:**   - Distance matrix between all cities
   - Pheromone matrix (initialized to 1)
   - Heuristic information $η = \frac{1}{\text{distance}}$

2. **Tour construction:**
   Each ant builds its tour by selecting the next city according to the probability:
$$
P(i,j) = \frac{[\tau(i,j)^\alpha \cdot \eta(i,j)^\beta]}{\sum_{k \in \text{allowed}} [\tau(i,k)^\alpha \cdot \eta(i,k)^\beta]}
$$
   where:
   - $τ(i,j)$ = pheromone intensity between cities i and j
   - $η(i,j)$ = heuristic information (1/distance)
   - $α$      = importance of pheromones
   - $β$      = importance of heuristic information

3. **Pheromone update:**
   - **Evaporation:** $τ(i,j) = (1-ρ) × τ(i,j)$
   - **Deposit:** $τ(i,j) = τ(i,j) + Q/L_k$ for each ant k that used edge $(i,j)$

4. **Implemented optimizations:**
   - Parallelization with `parfor` for simultaneous ant evaluation
   - Early stopping based on solution stagnation
   - Handling of degenerate cases (cities with same coordinates)

### Key Parameters

- **nAnts:** Number of ants per iteration (exploration/exploitation balance)
- **α (alpha):** Pheromone influence (collective memory)
- **β (beta):** Heuristic influence (local information)
- **ρ (rho):** Evaporation rate (gradual forgetting of bad solutions)
- **Q:** Pheromone deposit constant
- **patience:** Number of iterations without improvement before stopping
- **minImprovement:** Minimum improvement considered significant

## Notes

### Implementation Specifics

- **Fixed starting point:** All tours start and end at point (0,0)
- **Reproducibility management:** Use of fixed seeds for consistent results
- **Memory optimization:** City generation only when parameters change
- **Robustness:** Handling of edge cases (null distances, null probabilities)

### Visualizations

The project generates two types of graphs:
1. **Best tour map:** Spatial display of cities and optimal path
2. **Convergence:** Evolution of the best path length over iterations

### Performance

- **Small instances (≤50 cities):** Often optimal or very close solutions
- **Large instances (≥100 cities):** Good quality solutions with reasonable computation time
- **Parallelization:** Significant acceleration on multi-core machines

### Educational Use

This project illustrates:
- Bio-inspired metaheuristics
- Exploration/exploitation balance in optimization
- Impact of parameters on algorithm performance
- Combinatorial optimization techniques

The code is documented and structured to facilitate understanding of theoretical concepts and their practical implementation.