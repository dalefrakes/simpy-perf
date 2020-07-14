"""
Carwash example.

Covers:

- Waiting for other processes
- Resources: Resource

Scenario:
  A carwash has a limited number of washing machines and defines
  a washing processes that takes some (random) time.

  Car processes arrive at the carwash at a random time. If one washing
  machine is available, they start the washing process and wait for it
  to finish. If not, they wait until they an use one.


  Base model as downloaded on 13 July 2020 from: 
      https://simpy.readthedocs.io/en/latest/examples/carwash.html

"""
import random

import simpy
import time

RANDOM_SEED = 42
NUM_MACHINES = 1  # Number of machines in the carwash
WASHTIME = 5      # Minutes it takes to clean a car
T_INTER = 1       # Create a car every ~7 minutes
# SIM_TIME = 90 * 24 * 60     # Simulation time in minutes (90 days)


class Carwash(object):
    """A carwash has a limited number of machines (``NUM_MACHINES``) to
    clean cars in parallel.

    Cars have to request one of the machines. When they got one, they
    can start the washing processes and wait for it to finish (which
    takes ``washtime`` minutes).

    """
    def __init__(self, env, num_machines, washtime):
        self.env = env
        self.machine = simpy.Resource(env, num_machines)
        self.washtime = washtime

    def wash(self, car):
        """The washing processes. It takes a ``car`` processes and tries
        to clean it."""
        yield self.env.timeout(WASHTIME)
        # print("Carwash claned car # %s." %(car))


def car(env, name, cw):
    """The car process (each car has a ``name``) arrives at the carwash
    (``cw``) and requests a cleaning machine.

    It then starts the washing process, waits for it to finish and
    leaves to never come back ...

    """
    # print('%s arrives at the carwash at %.2f.' % (name, env.now))
    with cw.machine.request() as request:
        yield request

        # print('%s enters the carwash at %.2f.' % (name, env.now))
        yield env.process(cw.wash(name))

        # print('%s leaves the carwash at %.2f.' % (name, env.now))


def setup(env, num_machines, washtime, t_inter):
    """Create a carwash, a number of initial cars and keep creating cars
    approx. every ``t_inter`` minutes."""
    # Create the carwash
    carwash = Carwash(env, num_machines, washtime)

    # Create 4 initial cars
    for i in range(4):
        env.process(car(env, 'Car %d' % i, carwash))

    # Create more cars while the simulation is running
    while True:
        yield env.timeout(random.random() * t_inter)
        i += 1
        env.process(car(env, 'Car %d' % i, carwash))


NUM_ITERATIONS = 5   # how many times to run each day to get mean performance

for num_days in range(90):     # rerun the simulation for growing number of days

    SIM_TIME = (num_days + 1) * 24 * 60
    
    start_time = time.perf_counter()   # for timing the simulation

    for i in range(NUM_ITERATIONS):
        # Setup and start the simulation for this day/iteration
    
        #print('Carwash')
        #print('Check out http://youtu.be/fXXmeP9TvBg while simulating ... ;-)')
        random.seed(RANDOM_SEED)  # This helps reproducing the results
        
        # Create an environment and start the setup process
        env = simpy.Environment(initial_time = 0)
        env.process(setup(env, NUM_MACHINES, WASHTIME, T_INTER))
        
        # Execute!
        env.run(until=SIM_TIME)
    
    run_time = (time.perf_counter() - start_time) / NUM_ITERATIONS
    print("Sim-Days: {0}, Mean run-time: {1:0.2f} seconds, {2:0.2f} sec/day".format(
        num_days + 1, run_time, run_time /(num_days +1)))