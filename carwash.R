# This example was adapted from the Python package 'SimPy', [here](https://simpy.readthedocs.io/en/latest/examples). 
# Users familiar with SimPy may find these examples helpful for transitioning to `simmer`
# 
# by Iñaki Ucar, https://r-simmer.org/articles/simmer-05-simpy.html

library(simmer)

NUM_MACHINES <- 1  # Number of machines in the carwash
WASHTIME <- 5      # Minutes it takes to clean a car
T_INTER <- 7       # Create a car every ~7 minutes
SIM_TIME <- 20     # Simulation time in minutes

# setup
set.seed(42)
env <- simmer()

car <- trajectory() %>%
  # log_("arrives at the carwash") %>%
  seize("wash", 1) %>%
  # log_("enters the carwash") %>%
  timeout(WASHTIME) %>%
  set_attribute("dirt_removed", function() sample(50:99, 1)) %>%
  # log_(function() 
    #paste0(get_attribute(env, "dirt_removed"), "% of dirt was removed")) %>%
  release("wash", 1) %>%
  log_("leaves the carwash")


env %>%
  add_resource("wash", NUM_MACHINES) %>%
  # feed the trajectory with 4 initial cars
  add_generator("car_initial", car, at(rep(0, 4))) %>%
  # new cars approx. every T_INTER minutes
  add_generator("car", car, function() sample((T_INTER-2):(T_INTER+2), 1)) %>%
  # start the simulation
  run(SIM_TIME)