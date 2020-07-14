# basic Simmer simulation for testing integration with Python-Dash
#
# Input:  a csv file with name, time, and priority (model-input.csv)
# Ouput:  a csv dataframe with some simulation results (model-output.csv)
#
# Note:  no error checking or logging


library(simmer)

set.seed(1933)

model_input <- read_csv("model-input.csv", col_types = cols(priority = col_integer(), time = col_integer()))

# note, "name" is in the dataframe but can't be used by add_dataframe
model_input <- model_input[c("time","priority")]

bank <- simmer()

customer <-
  trajectory("Customer's path") %>%
  set_attribute("start_time", function() {now(bank)}) %>%
  log_(function() {
    paste("Queue is", get_queue_count(bank, "counter"), "on arrival")
  }) %>%
  seize("counter") %>%
  log_(function() {paste("Waited", now(bank) - get_attribute(bank, "start_time"))}) %>%
  timeout(12) %>%
  release("counter") %>%
  log_("Completed")

bank <-
  simmer("bank") %>%
  add_resource("counter") %>%
  add_generator("Customer", customer, function() {c(0, rexp(4, 1/10), -1)}) %>%
  add_generator("Mario", customer, at(22), priority = 1) %>%
  add_dataframe(name_prefix = "Customer", trajectory=customer, data=model_input, time = "absolute")#,
                #col_attributes = NULL, col_priority = "priority")#,
                #col_preemptible = col_priority, col_restart = "restart")


bank %>% run(until = 400)


df <- bank %>%
  get_mon_arrivals() %>%
  transform(waiting_time = end_time - start_time - activity_time)

write.csv(x = df, file = "model-ouput.csv", row.names = FALSE)