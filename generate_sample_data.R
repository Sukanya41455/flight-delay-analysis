# Generate Sample Flight Data for Testing
# This script creates synthetic flight data that mimics BTS structure
# Use this if you want to test the analysis pipeline before downloading real data

generate_sample_flights <- function(month = 1, year = 2024, n_flights = 50000, seed = 42) {
  set.seed(seed)
  
  # Major U.S. airports
  major_airports <- c(
    "ATL", "ORD", "DFW", "DEN", "LAX", "CLT", "LAS", "PHX", "MIA", "SEA",
    "IAH", "MCO", "EWR", "MSP", "BOS", "DTW", "PHL", "LGA", "SFO", "BWI",
    "SLC", "DCA", "IAD", "MDW", "SAN", "TPA", "PDX", "STL", "HNL", "AUS",
    "BNA", "OAK", "MSY", "DAL", "SJC", "MCI", "SAT", "SMF", "RSW", "PIT",
    "IND", "CVG", "CMH", "RDU", "JAX", "CLE", "ABQ", "OMA", "MKE", "ONT",
    "BUF", "ANC", "TUS", "BUR", "RNO", "OKC", "SNA", "BDL", "SJU", "ORF",
    "RIC", "DSM", "SYR", "GEG", "PBI", "CHS", "BOI", "ALB", "TUL", "PVD",
    "GRR", "BHM", "ELP", "OGG", "ICT", "LIT", "COS", "MHT", "CAK", "LEX"
  )
  
  # Create hub structure (some airports are more connected)
  hub_weights <- c(rep(10, 10), rep(5, 20), rep(2, 20), rep(1, 30))  # First 10 are major hubs
  
  # Generate origin-destination pairs
  origins <- sample(major_airports, n_flights, replace = TRUE, prob = hub_weights)
  
  # Destinations tend to be different from origins, with hub preference
  dests <- character(n_flights)
  for(i in 1:n_flights) {
    # Don't allow same origin and destination
    available_airports <- major_airports[major_airports != origins[i]]
    available_weights <- hub_weights[major_airports != origins[i]]
    dests[i] <- sample(available_airports, 1, prob = available_weights)
  }
  
  # Generate distances (roughly based on airport pairs)
  # Simplified: random distances with some structure
  distances <- round(runif(n_flights, min = 300, max = 3000))
  
  # Generate arrival delays
  # Model: delays are more likely for:
  # 1. Longer flights (slightly)
  # 2. Flights to/from major hubs (congestion)
  # 3. Random variation
  
  base_delay_prob <- 0.20  # 20% base delay rate
  
  # Hub effect: flights involving major hubs more likely delayed
  major_hubs <- c("ATL", "ORD", "DFW", "DEN", "LAX", "CLT", "LAS", "PHX", "MIA", "SEA")
  hub_effect <- (origins %in% major_hubs | dests %in% major_hubs) * 0.10
  
  # Distance effect (slight)
  distance_effect <- (distances - mean(distances)) / sd(distances) * 0.05
  
  # Calculate delay probability for each flight
  delay_prob <- pmin(pmax(base_delay_prob + hub_effect + distance_effect, 0.05), 0.80)
  
  # Generate actual delays
  is_delayed <- rbinom(n_flights, 1, delay_prob)
  
  # Arrival delay: if delayed, use exponential distribution; if early, small negative
  arr_delays <- ifelse(
    is_delayed,
    rexp(n_flights, rate = 1/30) + 15,  # Delayed: 15+ minutes (exponential tail)
    rnorm(n_flights, mean = -3, sd = 5)  # On-time or early
  )
  arr_delays <- round(arr_delays)
  
  # Departure delays (correlated with arrival delays)
  dep_delays <- arr_delays + rnorm(n_flights, mean = 0, sd = 5)
  dep_delays <- round(dep_delays)
  
  # Generate day of month
  days <- sample(1:28, n_flights, replace = TRUE)  # Avoid Feb 29/30/31 issues
  
  # Simplified carrier codes
  carriers <- sample(c("AA", "DL", "UA", "WN", "AS", "B6", "NK", "F9"), n_flights, replace = TRUE)
  
  # Create dataframe
  flight_data <- data.frame(
    ORIGIN = origins,
    DEST = dests,
    ARR_DELAY = arr_delays,
    DEP_DELAY = dep_delays,
    YEAR = year,
    MONTH = month,
    DAY_OF_MONTH = days,
    DISTANCE = distances,
    CARRIER = carriers,
    stringsAsFactors = FALSE
  )
  
  return(flight_data)
}

# Generate and save sample data if this script is run directly
if(sys.nframe() == 0) {
  cat("Generating sample flight data...\n")
  
  # Generate training month
  jan_data <- generate_sample_flights(month = 1, year = 2024, n_flights = 60000, seed = 42)
  write.csv(jan_data, "data/raw/flights_jan_2024.csv", row.names = FALSE)
  cat("✓ Generated training data:", nrow(jan_data), "flights\n")
  
  # Generate testing month
  feb_data <- generate_sample_flights(month = 2, year = 2024, n_flights = 60000, seed = 123)
  write.csv(feb_data, "data/raw/flights_feb_2024.csv", row.names = FALSE)
  cat("✓ Generated testing data:", nrow(feb_data), "flights\n")
  
  cat("\n✓ Sample data saved to data/raw/\n")
  cat("You can now run the main analysis Rmd file!\n")
}
