# This example was adapted from the Python package 'SimPy', [here](https://simpy.readthedocs.io/en/latest/examples). 
# Users familiar with SimPy may find these examples helpful for transitioning to `simmer`
# 
# by Iñaki Ucar, https://r-simmer.org/articles/simmer-05-simpy.html

library(simmer)

NUM_MACHINES <- 1  # Number of machines in the carwash
WASHTIME <- 5      # Minutes it takes to clean a car
T_INTER <- 1       # Create a car every ~7 minutes
# SIM_TIME <- 90 * 24 * 60     # Simulation time in minutes (90 days)

# setup
set.seed(42)


car <- trajectory() %>%
  # log_("arrives at the carwash") %>%
  seize("wash", 1) %>%
  # log_("enters the carwash") %>%
  timeout(WASHTIME) %>%
  set_attribute("dirt_removed", function() sample(50:99, 1)) %>%
  # log_(function() 
    #paste0(get_attribute(env, "dirt_removed"), "% of dirt was removed")) %>%
  release("wash", 1) # %>%
  # log_("leaves the carwash")

NUM_ITERATIONS <- 5   # how many times to run each day to get mean performance

for(num_days in 1:90){
  SIM_TIME <- (num_days) * 24 * 60 
  start_time <- Sys.time()
  for(i in 1:NUM_ITERATIONS){
    env <- simmer()
    env %>%
    add_resource("wash", NUM_MACHINES) %>%
    # feed the trajectory with 4 initial cars
    add_generator("car_initial", car, at(rep(0, 4))) %>%
    # new cars approx. every T_INTER minutes
    add_generator("car", car, function() runif(1) * T_INTER) %>%
    # start the simulation
    run(SIM_TIME)  
  }
  run_time = (Sys.time() - start_time) / NUM_ITERATIONS
  print(sprintf("Sim-Days: %.2f, Mean run-time: %.2f seconds, %.2f sec/day", num_days, run_time, run_time /num_days))
}
